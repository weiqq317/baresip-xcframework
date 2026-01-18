//
//  BaresipAccount.swift
//  Baresip SIP 账号配置
//
//  对应 Linphone 的 LinphoneAccount
//

import Foundation

/// Baresip SIP 账号配置，对应 LinphoneAccount
public struct BaresipAccount {
    /// SIP 用户名
    public let username: String
    
    /// SIP 密码
    public let password: String
    
    /// SIP 域名（服务器地址）
    public let domain: String
    
    /// 传输协议（UDP/TCP/TLS）
    public let transport: BaresipTransportType
    
    /// 端口号（默认 5060）
    public let port: UInt16
    
    /// 显示名称
    public let displayName: String?
    
    /// 完整的 SIP URI（自动生成）
    public var sipUri: String {
        let user = username.isEmpty ? "" : "\(username)@"
        let portStr = port == 5060 ? "" : ":\(port)"
        return "sip:\(user)\(domain)\(portStr);transport=\(transport.rawValue)"
    }
    
    /// 初始化 SIP 账号
    /// - Parameters:
    ///   - username: SIP 用户名
    ///   - password: SIP 密码
    ///   - domain: SIP 域名
    ///   - transport: 传输协议（默认 UDP）
    ///   - port: 端口号（默认 5060）
    ///   - displayName: 显示名称（可选）
    public init(
        username: String,
        password: String,
        domain: String,
        transport: BaresipTransportType = .udp,
        port: UInt16 = 5060,
        displayName: String? = nil
    ) {
        self.username = username
        self.password = password
        self.domain = domain
        self.transport = transport
        self.port = port
        self.displayName = displayName
    }
}

/// SIP 传输协议类型
public enum BaresipTransportType: String {
    case udp = "udp"
    case tcp = "tcp"
    case tls = "tls"
}
