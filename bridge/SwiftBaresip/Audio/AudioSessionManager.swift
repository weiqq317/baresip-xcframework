//
//  AudioSessionManager.swift
//  音频会话管理器
//
//  基于研究报告 5.3 节的设计，管理 AVAudioSession
//

import Foundation
import AVFoundation

/// 音频会话管理器，管理 AVAudioSession
public final class AudioSessionManager {
    // MARK: - Singleton
    
    public static let shared = AudioSessionManager()
    
    // MARK: - Properties
    
    /// AVAudioSession 实例
    private let session = AVAudioSession.sharedInstance()
    
    /// 是否已激活
    private var isActive: Bool = false
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 配置音频会话为 VoIP 场景（基于研究报告 5.3 节）
    public func configureAudioSession() {
        guard !isActive else {
            print("🔊 音频会话已激活，跳过配置")
            return
        }
        
        do {
            // 配置音频会话
            // - Category: .playAndRecord - 同时支持播放与采集
            // - Mode: .voiceChat - 优化语音通话（回声消除、AGC）
            // - Options: .allowBluetooth - 支持蓝牙设备
            try session.setCategory(
                .playAndRecord,
                mode: .voiceChat,
                options: [.allowBluetooth, .allowBluetoothA2DP]
            )
            
            // 激活音频会话
            try session.setActive(true, options: [])
            
            isActive = true
            print("🔊 音频会话已配置并激活")
            
            // 注册音频中断通知
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAudioInterruption),
                name: AVAudioSession.interruptionNotification,
                object: session
            )
            
            // 注册音频路由变更通知
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleRouteChange),
                name: AVAudioSession.routeChangeNotification,
                object: session
            )
            
        } catch {
            print("❌ 配置音频会话失败: \(error)")
        }
    }
    
    /// 停用音频会话
    public func deconfigureAudioSession() {
        guard isActive else {
            print("🔇 音频会话未激活，跳过停用")
            return
        }
        
        do {
            // 停用音频会话
            try session.setActive(false, options: [.notifyOthersOnDeactivation])
            
            isActive = false
            print("🔇 音频会话已停用")
            
            // 移除通知监听
            NotificationCenter.default.removeObserver(
                self,
                name: AVAudioSession.interruptionNotification,
                object: session
            )
            NotificationCenter.default.removeObserver(
                self,
                name: AVAudioSession.routeChangeNotification,
                object: session
            )
            
        } catch {
            print("❌ 停用音频会话失败: \(error)")
        }
    }
    
    // MARK: - Audio Interruption Handling
    
    /// 处理音频中断（如来电、闹钟等）
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            print("⚠️ 音频中断开始")
            // 音频中断开始，暂停通话音频
            
        case .ended:
            print("✅ 音频中断结束")
            // 音频中断结束，恢复通话音频
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // 应该恢复音频
                    do {
                        try session.setActive(true)
                        print("🔊 音频会话已恢复")
                    } catch {
                        print("❌ 恢复音频会话失败: \(error)")
                    }
                }
            }
            
        @unknown default:
            break
        }
    }
    
    /// 处理音频路由变更（如插拔耳机、蓝牙连接等）
    @objc private func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        switch reason {
        case .newDeviceAvailable:
            print("🎧 新音频设备可用")
            // 新设备连接（如耳机、蓝牙）
            
        case .oldDeviceUnavailable:
            print("🎧 音频设备断开")
            // 设备断开（如拔出耳机）
            
        case .categoryChange:
            print("🔊 音频类别变更")
            
        case .override:
            print("🔊 音频路由被覆盖")
            
        case .wakeFromSleep:
            print("🔊 从睡眠唤醒")
            
        case .noSuitableRouteForCategory:
            print("⚠️ 没有合适的音频路由")
            
        case .routeConfigurationChange:
            print("🔊 音频路由配置变更")
            
        @unknown default:
            break
        }
        
        // 打印当前音频路由
        let currentRoute = session.currentRoute
        print("🔊 当前音频路由:")
        for output in currentRoute.outputs {
            print("   输出: \(output.portName) (\(output.portType.rawValue))")
        }
        for input in currentRoute.inputs {
            print("   输入: \(input.portName) (\(input.portType.rawValue))")
        }
    }
}
