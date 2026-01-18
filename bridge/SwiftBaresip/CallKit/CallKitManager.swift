//
//  CallKitManager.swift
//  CallKit 集成管理器
//
//  基于研究报告 5.1 节的设计，实现系统级通话体验
//

import Foundation
import CallKit
import AVFoundation

/// CallKit 集成管理器，实现系统级通话 UI
public final class CallKitManager: NSObject {
    // MARK: - Singleton
    
    public static let shared = CallKitManager()
    
    // MARK: - Properties
    
    /// CXProvider 实例
    private let provider: CXProvider
    
    /// CXCallController 实例
    private let callController = CXCallController()
    
    /// 通话 UUID 到 BaresipCall 的映射
    private var callMapping: [UUID: BaresipCall] = [:]
    
    // MARK: - Initialization
    
    private override init() {
        // 配置 CXProvider（基于研究报告 5.1.1 节）
        let configuration = CXProviderConfiguration()
        configuration.supportsVideo = false // 禁用视频
        configuration.maximumCallsPerCallGroup = 1
        configuration.supportedHandleTypes = [.generic]
        configuration.iconTemplateImageData = nil // 可设置应用图标
        
        provider = CXProvider(configuration: configuration)
        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    // MARK: - Incoming Call
    
    /// 报告来电（由 BaresipUA 调用）
    /// - Parameters:
    ///   - call: 通话对象
    ///   - completion: 完成回调
    public func reportIncomingCall(_ call: BaresipCall, completion: @escaping (Error?) -> Void) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: call.remoteAddress)
        update.hasVideo = false
        update.localizedCallerName = call.remoteAddress
        
        // 保存映射
        callMapping[call.uuid] = call
        
        // 报告来电
        provider.reportNewIncomingCall(with: call.uuid, update: update) { error in
            if let error = error {
                print("❌ CallKit 报告来电失败: \(error)")
            }
            completion(error)
        }
    }
    
    // MARK: - Outgoing Call
    
    /// 开始呼出通话
    /// - Parameters:
    ///   - call: 通话对象
    ///   - completion: 完成回调
    public func startOutgoingCall(_ call: BaresipCall, completion: @escaping (Error?) -> Void) {
        let handle = CXHandle(type: .generic, value: call.remoteAddress)
        let startCallAction = CXStartCallAction(call: call.uuid, handle: handle)
        startCallAction.isVideo = false
        
        // 保存映射
        callMapping[call.uuid] = call
        
        let transaction = CXTransaction(action: startCallAction)
        callController.request(transaction) { error in
            if let error = error {
                print("❌ CallKit 开始呼出失败: \(error)")
            }
            completion(error)
        }
    }
    
    // MARK: - Call State Updates
    
    /// 报告通话已连接
    /// - Parameter call: 通话对象
    public func reportCallConnected(_ call: BaresipCall) {
        provider.reportOutgoingCall(with: call.uuid, connectedAt: Date())
    }
    
    /// 报告通话已结束
    /// - Parameters:
    ///   - call: 通话对象
    ///   - reason: 结束原因
    public func reportCallEnded(_ call: BaresipCall, reason: CXCallEndedReason = .remoteEnded) {
        provider.reportCall(with: call.uuid, endedAt: Date(), reason: reason)
        callMapping.removeValue(forKey: call.uuid)
    }
    
    // MARK: - Call Actions
    
    /// 挂断通话
    /// - Parameters:
    ///   - call: 通话对象
    ///   - completion: 完成回调
    public func endCall(_ call: BaresipCall, completion: @escaping (Error?) -> Void) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: endCallAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("❌ CallKit 挂断通话失败: \(error)")
            }
            completion(error)
        }
    }
    
    /// 保持通话
    /// - Parameters:
    ///   - call: 通话对象
    ///   - onHold: 是否保持
    ///   - completion: 完成回调
    public func setHeld(_ call: BaresipCall, onHold: Bool, completion: @escaping (Error?) -> Void) {
        let setHeldAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction(action: setHeldAction)
        
        callController.request(transaction) { error in
            if let error = error {
                print("❌ CallKit 保持通话失败: \(error)")
            }
            completion(error)
        }
    }
}

// MARK: - CXProviderDelegate

extension CallKitManager: CXProviderDelegate {
    /// 提供者配置
    public func providerDidReset(_ provider: CXProvider) {
        print("📞 CallKit Provider 重置")
        callMapping.removeAll()
    }
    
    /// 接听来电
    public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = callMapping[action.callUUID] else {
            action.fail()
            return
        }
        
        do {
            try call.accept()
            action.fulfill()
        } catch {
            print("❌ 接听来电失败: \(error)")
            action.fail()
        }
    }
    
    /// 挂断通话
    public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = callMapping[action.callUUID] else {
            action.fail()
            return
        }
        
        do {
            try call.terminate()
            action.fulfill()
            callMapping.removeValue(forKey: action.callUUID)
        } catch {
            print("❌ 挂断通话失败: \(error)")
            action.fail()
        }
    }
    
    /// 保持通话
    public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        guard let call = callMapping[action.callUUID] else {
            action.fail()
            return
        }
        
        do {
            if action.isOnHold {
                try call.putOnHold()
            } else {
                try call.resume()
            }
            action.fulfill()
        } catch {
            print("❌ 保持/恢复通话失败: \(error)")
            action.fail()
        }
    }
    
    /// 开始呼出
    public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        // 呼出通话已在 startOutgoingCall 中处理
        action.fulfill()
    }
    
    /// 音频会话激活
    public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("🔊 CallKit 音频会话已激活")
        // 配置音频会话（基于研究报告 5.3 节）
        AudioSessionManager.shared.configureAudioSession()
    }
    
    /// 音频会话停用
    public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("🔇 CallKit 音频会话已停用")
        AudioSessionManager.shared.deconfigureAudioSession()
    }
}
