//
//  AppDelegate.swift
//  Baresip iOS Example
//
//  演示如何集成 Baresip XCFramework
//

import UIKit
import SwiftBaresip

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 初始化 Baresip
        setupBaresip()
        
        // 注册 PushKit
        setupPushKit()
        
        // 配置 CallKit
        setupCallKit()
        
        return true
    }
    
    // MARK: - Baresip Setup
    
    private func setupBaresip() {
        // 设置代理
        BaresipUA.shared.delegate = self
        
        print("✅ Baresip 初始化完成")
    }
    
    // MARK: - PushKit Setup
    
    private func setupPushKit() {
        let pushKitManager = PushKitManager.shared
        
        // 注册 VoIP 推送
        pushKitManager.registerForPushNotifications()
        
        // 处理推送 Token
        pushKitManager.onTokenReceived = { token in
            print("📱 Push Token: \(token)")
            // TODO: 上报到服务器
        }
        
        // 处理来电推送
        pushKitManager.onPushReceived = { payload in
            print("📞 收到来电推送: \(payload)")
            // CallKit 会自动处理来电 UI
        }
    }
    
    // MARK: - CallKit Setup
    
    private func setupCallKit() {
        // CallKit 已在 CallKitManager 中自动初始化
        print("📞 CallKit 已配置")
    }
    
    // MARK: - UISceneSession Lifecycle (iOS 13+)
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

// MARK: - BaresipUADelegate

extension AppDelegate: BaresipUADelegate {
    func callStateChanged(call: BaresipCall, state: BaresipCallState) {
        print("📞 通话状态变更: \(state.description)")
        
        let callKitManager = CallKitManager.shared
        
        switch state {
        case .incoming:
            // 报告来电
            callKitManager.reportIncomingCall(call) { error in
                if let error = error {
                    print("❌ 报告来电失败: \(error)")
                }
            }
            
        case .connected:
            // 报告通话已连接
            callKitManager.reportCallConnected(call)
            
        case .disconnected:
            // 报告通话已结束
            callKitManager.reportCallEnded(call)
            
        default:
            break
        }
    }
    
    func registrationStateChanged(isRegistered: Bool, error: Error?) {
        if isRegistered {
            print("✅ SIP 注册成功")
        } else {
            print("❌ SIP 注册失败: \(error?.localizedDescription ?? "未知错误")")
        }
    }
}
