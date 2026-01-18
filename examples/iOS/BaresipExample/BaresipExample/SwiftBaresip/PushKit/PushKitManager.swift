//
//  PushKitManager.swift
//  PushKit 集成管理器
//
//  基于研究报告 5.2 节的设计，实现后台 VoIP 推送
//

import Foundation
import PushKit

/// PushKit 集成管理器，实现后台 VoIP 推送
public final class PushKitManager: NSObject {
    // MARK: - Singleton
    
    public static let shared = PushKitManager()
    
    // MARK: - Properties
    
    /// PKPushRegistry 实例
    private let registry: PKPushRegistry
    
    /// 推送 Token 回调
    public var onTokenReceived: ((String) -> Void)?
    
    /// 推送接收回调
    public var onPushReceived: (([AnyHashable: Any]) -> Void)?
    
    // MARK: - Initialization
    
    private override init() {
        registry = PKPushRegistry(queue: DispatchQueue.main)
        super.init()
        
        registry.delegate = self
        registry.desiredPushTypes = [.voIP]
    }
    
    // MARK: - Public Methods
    
    /// 注册 VoIP 推送
    public func registerForPushNotifications() {
        print("📱 注册 VoIP 推送...")
        // desiredPushTypes 已在 init 中设置，这里会自动触发注册
    }
    
    /// 注销 VoIP 推送
    public func unregisterForPushNotifications() {
        print("📱 注销 VoIP 推送...")
        registry.desiredPushTypes = []
    }
}

// MARK: - PKPushRegistryDelegate

extension PushKitManager: PKPushRegistryDelegate {
    /// 推送 Token 更新
    public func pushRegistry(
        _ registry: PKPushRegistry,
        didUpdate pushCredentials: PKPushCredentials,
        for type: PKPushType
    ) {
        guard type == .voIP else { return }
        
        // 转换 Token 为十六进制字符串
        let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        print("📱 VoIP Push Token: \(token)")
        
        // 上报到 SIP 服务器
        BaresipUA.shared.registerPushToken(token)
        
        // 触发回调
        onTokenReceived?(token)
    }
    
    /// 接收 VoIP 推送
    public func pushRegistry(
        _ registry: PKPushRegistry,
        didReceiveIncomingPushWith payload: PKPushPayload,
        for type: PKPushType,
        completion: @escaping () -> Void
    ) {
        guard type == .voIP else {
            completion()
            return
        }
        
        print("📱 收到 VoIP 推送: \(payload.dictionaryPayload)")
        
        // 唤醒 Baresip（基于研究报告 5.2.1 节）
        BaresipUA.shared.wakeup()
        
        // 解析推送 Payload
        let payloadDict = payload.dictionaryPayload
        
        // 提取呼叫信息
        guard let callerUri = payloadDict["caller_uri"] as? String else {
            print("⚠️ 推送 Payload 缺少 caller_uri")
            completion()
            return
        }
        
        let callerName = payloadDict["caller_name"] as? String ?? callerUri
        
        // 延迟 0.5 秒执行呼叫逻辑，确保 Baresip 初始化完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // 创建虚拟来电（实际来电会通过 SIP 信令到达）
            // 这里仅用于触发 CallKit UI
            print("📞 处理来电: \(callerName) (\(callerUri))")
            
            // 触发回调
            self.onPushReceived?(payloadDict)
            
            completion()
        }
    }
    
    /// 推送 Token 失效
    public func pushRegistry(
        _ registry: PKPushRegistry,
        didInvalidatePushTokenFor type: PKPushType
    ) {
        guard type == .voIP else { return }
        print("⚠️ VoIP Push Token 已失效")
    }
}
