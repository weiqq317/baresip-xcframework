//
//  BaresipCallState.swift
//  Baresip 通话状态枚举
//
//  对应 Linphone 的 LinphoneCallState
//

import Foundation

/// Baresip 通话状态，对应 LinphoneCallState
public enum BaresipCallState: Int32 {
    case idle = 0           // 空闲
    case incoming = 1       // 来电
    case outgoing = 2       // 呼出
    case ringing = 3        // 振铃中
    case connecting = 4     // 连接中
    case connected = 5      // 已连接
    case held = 6           // 保持中
    case paused = 7         // 暂停
    case disconnected = 8   // 已断开
    case error = 9          // 错误
    
    /// 从 Baresip C 事件转换
    init(fromCallEvent event: Int32) {
        switch event {
        case 0: // CALL_EVENT_INCOMING
            self = .incoming
        case 1: // CALL_EVENT_RINGING
            self = .ringing
        case 2: // CALL_EVENT_PROGRESS
            self = .connecting
        case 3: // CALL_EVENT_ESTABLISHED
            self = .connected
        case 4: // CALL_EVENT_CLOSED
            self = .disconnected
        default:
            self = .idle
        }
    }
    
    /// 是否为活跃通话状态
    public var isActive: Bool {
        switch self {
        case .connecting, .connected, .held:
            return true
        default:
            return false
        }
    }
    
    /// 是否为结束状态
    public var isEnded: Bool {
        return self == .disconnected || self == .error
    }
    
    /// 状态描述
    public var description: String {
        switch self {
        case .idle:
            return "空闲"
        case .incoming:
            return "来电"
        case .outgoing:
            return "呼出"
        case .ringing:
            return "振铃中"
        case .connecting:
            return "连接中"
        case .connected:
            return "通话中"
        case .held:
            return "保持中"
        case .paused:
            return "暂停"
        case .disconnected:
            return "已断开"
        case .error:
            return "错误"
        }
    }
}
