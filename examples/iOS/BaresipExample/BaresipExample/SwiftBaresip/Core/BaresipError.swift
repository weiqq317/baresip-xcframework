//
//  BaresipError.swift
//  Baresip 错误类型定义
//
//  对应 Linphone 的错误码系统
//

import Foundation

/// Baresip 错误类型，对应 Linphone 的错误码
public enum BaresipError: Int32, Error, LocalizedError {
    case registrationFailed = -1
    case callFailed = -2
    case invalidAddress = -3
    case networkError = -4
    case authenticationFailed = -5
    case timeout = -6
    case notFound = -7
    case busy = -8
    case declined = -9
    case notAcceptable = -10
    case serverError = -11
    case unknown = -99
    
    public var errorDescription: String? {
        switch self {
        case .registrationFailed:
            return "SIP 注册失败"
        case .callFailed:
            return "呼叫失败"
        case .invalidAddress:
            return "无效的 SIP 地址"
        case .networkError:
            return "网络错误"
        case .authenticationFailed:
            return "认证失败"
        case .timeout:
            return "请求超时"
        case .notFound:
            return "用户不存在"
        case .busy:
            return "用户忙"
        case .declined:
            return "呼叫被拒绝"
        case .notAcceptable:
            return "不可接受的请求"
        case .serverError:
            return "服务器错误"
        case .unknown:
            return "未知错误"
        }
    }
    
    /// 从 C 语言错误码转换
    public init(code: Int32) {
        self = BaresipError(rawValue: code) ?? .unknown
    }
}
