//
//  BaresipAddress.swift
//  Baresip SIP 地址解析
//
//  对应 Linphone 的 LinphoneAddress
//

import Foundation

/// Baresip SIP 地址解析类，对应 LinphoneAddress
public struct BaresipAddress {
    /// 用户名部分
    public let username: String?
    
    /// 域名部分
    public let domain: String
    
    /// 显示名称
    public let displayName: String?
    
    /// 端口号
    public let port: UInt16?
    
    /// 传输协议
    public let transport: BaresipTransportType?
    
    /// 完整的 SIP URI
    public var uri: String {
        var result = "sip:"
        
        if let username = username {
            result += "\(username)@"
        }
        
        result += domain
        
        if let port = port, port != 5060 {
            result += ":\(port)"
        }
        
        if let transport = transport {
            result += ";transport=\(transport.rawValue)"
        }
        
        return result
    }
    
    /// 从 SIP URI 字符串解析
    /// - Parameter uriString: SIP URI 字符串（如 "sip:user@domain:5060;transport=tcp"）
    /// - Returns: 解析后的地址对象，如果解析失败返回 nil
    public static func parse(_ uriString: String) -> BaresipAddress? {
        // 移除 "sip:" 前缀
        var uri = uriString
        if uri.hasPrefix("sip:") {
            uri = String(uri.dropFirst(4))
        } else if uri.hasPrefix("sips:") {
            uri = String(uri.dropFirst(5))
        }
        
        // 分离参数部分
        let components = uri.components(separatedBy: ";")
        let mainPart = components[0]
        
        // 解析传输协议
        var transport: BaresipTransportType?
        for component in components.dropFirst() {
            if component.hasPrefix("transport=") {
                let transportValue = String(component.dropFirst(10))
                transport = BaresipTransportType(rawValue: transportValue)
            }
        }
        
        // 分离用户名和域名
        var username: String?
        var domainAndPort: String
        
        if let atIndex = mainPart.firstIndex(of: "@") {
            username = String(mainPart[..<atIndex])
            domainAndPort = String(mainPart[mainPart.index(after: atIndex)...])
        } else {
            domainAndPort = mainPart
        }
        
        // 分离域名和端口
        var domain: String
        var port: UInt16?
        
        if let colonIndex = domainAndPort.firstIndex(of: ":") {
            domain = String(domainAndPort[..<colonIndex])
            let portString = String(domainAndPort[domainAndPort.index(after: colonIndex)...])
            port = UInt16(portString)
        } else {
            domain = domainAndPort
        }
        
        // 验证域名不为空
        guard !domain.isEmpty else {
            return nil
        }
        
        return BaresipAddress(
            username: username,
            domain: domain,
            displayName: nil,
            port: port,
            transport: transport
        )
    }
    
    /// 初始化 SIP 地址
    /// - Parameters:
    ///   - username: 用户名（可选）
    ///   - domain: 域名
    ///   - displayName: 显示名称（可选）
    ///   - port: 端口号（可选，默认 5060）
    ///   - transport: 传输协议（可选）
    public init(
        username: String? = nil,
        domain: String,
        displayName: String? = nil,
        port: UInt16? = nil,
        transport: BaresipTransportType? = nil
    ) {
        self.username = username
        self.domain = domain
        self.displayName = displayName
        self.port = port
        self.transport = transport
    }
}

// MARK: - Equatable

extension BaresipAddress: Equatable {
    public static func == (lhs: BaresipAddress, rhs: BaresipAddress) -> Bool {
        return lhs.username == rhs.username &&
               lhs.domain == rhs.domain &&
               lhs.port == rhs.port &&
               lhs.transport == rhs.transport
    }
}

// MARK: - CustomStringConvertible

extension BaresipAddress: CustomStringConvertible {
    public var description: String {
        if let displayName = displayName {
            return "\"\(displayName)\" <\(uri)>"
        } else {
            return uri
        }
    }
}
