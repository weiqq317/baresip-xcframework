//
//  BaresipUADelegate.swift
//  Baresip 用户代理代理协议
//
//  对应 Linphone 的 LinphoneCoreListener
//

import Foundation

/// Baresip 用户代理代理协议，对应 LinphoneCoreListener
public protocol BaresipUADelegate: AnyObject {
    /// 通话状态变更回调
    /// - Parameters:
    ///   - call: 通话对象
    ///   - state: 新的通话状态
    func callStateChanged(call: BaresipCall, state: BaresipCallState)
    
    /// SIP 注册状态变更回调
    /// - Parameters:
    ///   - isRegistered: 是否已注册
    ///   - error: 错误信息（如果注册失败）
    func registrationStateChanged(isRegistered: Bool, error: Error?)
    
    /// 网络状态变更回调
    /// - Parameter isReachable: 网络是否可达
    func networkReachabilityChanged(isReachable: Bool)
}

// 提供默认实现（可选方法）
public extension BaresipUADelegate {
    func registrationStateChanged(isRegistered: Bool, error: Error?) {}
    func networkReachabilityChanged(isReachable: Bool) {}
}
