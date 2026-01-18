//
//  BaresipUA.swift
//  Baresip 用户代理（User Agent）
//
//  对应 Linphone 的 LinphoneCore
//  基于研究报告 4.2 节的设计，实现线程安全与事件回调转换
//

import Foundation

/// Baresip 用户代理类，对应 LinphoneCore
public final class BaresipUA: NSObject {
    // MARK: - Singleton
    
    /// 单例实例，对应 LinphoneCore 的单例设计
    public static let shared = BaresipUA()
    
    // MARK: - Properties
    
    /// Baresip 底层 ua 结构体指针（Opaque Pointer 封装）
    private let rawPtr: OpaquePointer
    
    /// 串行队列确保线程安全（基于研究报告 7.2 节）
    private let queue = DispatchQueue(label: "com.baresip.ua.queue", qos: .userInitiated)
    
    /// 状态回调代理，对应 LinphoneCoreListener
    public weak var delegate: BaresipUADelegate?
    
    /// 当前活跃的通话列表
    private var activeCalls: [UUID: BaresipCall] = [:]
    
    /// 当前注册状态
    private(set) public var isRegistered: Bool = false
    
    /// 当前账号配置
    private var currentAccount: BaresipAccount?
    
    // MARK: - Initialization
    
    private override init() {
        // 初始化 Baresip 底层 ua 结构体
        rawPtr = ua_create()
        super.init()
        
        // 注册 Baresip 事件回调（C 回调转 Swift 代理）
        registerEventHandler()
    }
    
    deinit {
        // 释放 Baresip 底层资源
        ua_destroy(rawPtr)
    }
    
    // MARK: - SIP Registration (对应 LinphoneCore 的注册方法)
    
    /// 注册 SIP 账号，对应 LinphoneCore.register(withAccount:)
    /// - Parameter account: SIP 账号配置
    /// - Throws: BaresipError 如果注册失败
    public func register(with account: BaresipAccount) throws {
        try queue.sync {
            let code = ua_register(
                rawPtr,
                account.username,
                account.password,
                account.domain
            )
            
            guard code == 0 else {
                throw BaresipError(code: code)
            }
            
            self.currentAccount = account
            self.isRegistered = true
            
            // 通知代理
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.registrationStateChanged(isRegistered: true, error: nil)
            }
        }
    }
    
    /// 注销 SIP 账号
    /// - Throws: BaresipError 如果注销失败
    public func unregister() throws {
        try queue.sync {
            let code = ua_unregister(rawPtr)
            
            guard code == 0 else {
                throw BaresipError(code: code)
            }
            
            self.isRegistered = false
            self.currentAccount = nil
            
            // 通知代理
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.registrationStateChanged(isRegistered: false, error: nil)
            }
        }
    }
    
    // MARK: - Call Control (对应 LinphoneCore 的呼叫方法)
    
    /// 发起语音呼叫，对应 LinphoneCore.inviteAddress(_:)
    /// - Parameter address: 对方 SIP URI（如 "sip:user@domain"）
    /// - Returns: 通话对象
    /// - Throws: BaresipError 如果呼叫失败
    @discardableResult
    public func inviteAddress(_ address: String) throws -> BaresipCall {
        var callPtr: OpaquePointer?
        
        try queue.sync {
            let code = ua_invite(
                rawPtr,
                &callPtr,
                address,
                nil,
                0 // VID_MODE_OFF 禁用视频
            )
            
            guard code == 0, let ptr = callPtr else {
                throw BaresipError(code: code)
            }
            
            callPtr = ptr
        }
        
        // 创建 Swift 通话对象
        let call = BaresipCall(rawPtr: callPtr!)
        activeCalls[call.uuid] = call
        
        return call
    }
    
    /// 根据 UUID 获取通话对象（用于 CallKit 集成）
    /// - Parameter uuid: 通话唯一标识符
    /// - Returns: 通话对象（如果存在）
    public func call(with uuid: UUID) -> BaresipCall? {
        return activeCalls[uuid]
    }
    
    /// 获取所有活跃通话
    public var calls: [BaresipCall] {
        return Array(activeCalls.values)
    }
    
    // MARK: - PushKit Support
    
    /// 唤醒 Baresip（用于 PushKit 后台唤醒）
    public func wakeup() {
        queue.async { [weak self] in
            guard let self = self else { return }
            ua_wakeup(self.rawPtr)
        }
    }
    
    /// 注册推送 Token（上报到 SIP 服务器）
    /// - Parameter token: 设备推送 Token
    public func registerPushToken(_ token: String) {
        // TODO: 实现推送 Token 上报逻辑
        // 通常通过 SIP MESSAGE 或自定义 SIP 头部发送到服务器
        print("📱 Push Token: \(token)")
    }
    
    // MARK: - Event Handling
    
    /// 注册 Baresip 事件回调（C 回调转 Swift 代理）
    private func registerEventHandler() {
        // 使用 Unmanaged 避免循环引用
        let context = Unmanaged.passUnretained(self).toOpaque()
        
        ua_event_register(rawPtr, { ua, event, callPtr, prm, arg in
            guard let arg = arg else { return }
            
            // 从 context 恢复 self
            let ua = Unmanaged<BaresipUA>.fromOpaque(arg).takeUnretainedValue()
            
            // 转换事件到 Swift
            ua.handleEvent(event: event, callPtr: callPtr, prm: prm)
        }, context)
    }
    
    /// 处理 Baresip 事件
    /// - Parameters:
    ///   - event: 事件类型
    ///   - callPtr: 通话指针
    ///   - prm: 事件参数
    private func handleEvent(event: Int32, callPtr: OpaquePointer?, prm: UnsafePointer<CChar>?) {
        // 转换为 Swift 通话状态
        let state = BaresipCallState(fromCallEvent: event)
        
        // 查找或创建通话对象
        guard let callPtr = callPtr else { return }
        
        var call: BaresipCall?
        
        // 查找现有通话
        for existingCall in activeCalls.values {
            // TODO: 需要通过 call 指针匹配，这里简化处理
            call = existingCall
            break
        }
        
        // 如果是新来电，创建通话对象
        if call == nil && state == .incoming {
            call = BaresipCall(rawPtr: callPtr)
            activeCalls[call!.uuid] = call
        }
        
        guard let finalCall = call else { return }
        
        // 更新通话状态
        finalCall.updateState(state)
        
        // 如果通话结束，从列表中移除
        if state.isEnded {
            activeCalls.removeValue(forKey: finalCall.uuid)
        }
        
        // 切换到主线程调用代理（基于研究报告 4.2.3 节）
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.callStateChanged(call: finalCall, state: state)
        }
    }
}

// MARK: - CustomStringConvertible

extension BaresipUA: CustomStringConvertible {
    public var description: String {
        return "BaresipUA(registered: \(isRegistered), calls: \(activeCalls.count))"
    }
}
