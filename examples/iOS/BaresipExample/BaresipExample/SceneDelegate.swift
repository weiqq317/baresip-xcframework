//
//  SceneDelegate.swift
//  Baresip iOS Example
//
//  Scene 生命周期管理（iOS 13+）
//

import UIKit
import SwiftUI

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // 使用 SwiftUI 创建内容视图
        let contentView = ContentView()
        
        // 使用 UIHostingController 作为窗口根视图控制器
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // 场景断开连接时调用
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // 场景变为活跃状态
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // 场景即将进入非活跃状态
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // 场景即将进入前台
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // 场景已进入后台
    }
}
