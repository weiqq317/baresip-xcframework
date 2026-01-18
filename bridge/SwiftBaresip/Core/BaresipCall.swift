//
//  BaresipCall.swift
//  Baresip 通话对象
//
//  对应 Linphone 的 LinphoneCall
//  基于研究报告 4.2.1 节的设计，实现内存管理与线程安全
//

import Foundation

/// Baresip 通话对象，对应 LinphoneCall
public final class BaresipCall {
    // MARK: - Properties
    
    /// Baresip 底层 call 结构体指针（Opaque Pointer 封装）
    private let rawPtr: OpaquePointer
    
    /// 通话唯一标识符（用于 CallKit 集成）
    public let uuid: UUID
    
    /// 当前通话状态
    private(set) public var state: BaresipCallState = .idle
    
    /// 对方 SIP URI
    public var remoteAddress: String {
        guard let uri = call_peeruri(rawPtr) else {
            return ""
        }
        return String(cString: uri)
    }
    
    /// 本地 SIP URI
    public var localAddress: String {
        guard let uri = call_localuri(rawPtr) else {
            return ""
        }
        return String(cString: uri)
    }
    
    /// 通话时长（秒）
    public var duration: Int {
        return Int(call_duration(rawPtr))
    }
    
    /// 是否处于保持状态
    public var isOnHold: Bool {
        return call_is_onhold(rawPtr)
    }
    
    // MARK: - Initialization
    
    /// 初始化通话对象
    /// - Parameters:
    ///   - rawPtr: Baresip 底层 call 指针
    ///   - uuid: 通话唯一标识符（默认自动生成）
    init(rawPtr: OpaquePointer, uuid: UUID = UUID()) {
        self.rawPtr = rawPtr
        self.uuid = uuid
    }
    
    deinit {
        // 自动释放 Baresip 底层资源（基于研究报告 7.1 节）
        call_destroy(rawPtr)
    }
    
    // MARK: - Call Control (对应 LinphoneCall 的方法)
    
    /// 接听来电，对应 LinphoneCall.accept()
    /// - Throws: BaresipError 如果接听失败
    public func accept() throws {
        let code = call_answer(rawPtr, 200) // 200 OK 响应
        guard code == 0 else {
            throw BaresipError(code: code)
        }
    }
    
    /// 挂断通话，对应 LinphoneCall.terminate()
    /// - Throws: BaresipError 如果挂断失败
    public func terminate() throws {
        let code = call_hangup(rawPtr, 603) // 603 Declined 响应
        guard code == 0 else {
            throw BaresipError(code: code)
        }
    }
    
    /// 呼叫保持，对应 LinphoneCall.putOnHold()
    /// - Throws: BaresipError 如果保持失败
    public func putOnHold() throws {
        let code = call_hold(rawPtr)
        guard code == 0 else {
            throw BaresipError(code: code)
        }
    }
    
    /// 恢复呼叫，对应 LinphoneCall.resume()
    /// - Throws: BaresipError 如果恢复失败
    public func resume() throws {
        let code = call_resume(rawPtr)
        guard code == 0 else {
            throw BaresipError(code: code)
        }
    }
    
    /// 发送 DTMF 信号
    /// - Parameter digit: DTMF 数字（0-9, *, #, A-D）
    /// - Throws: BaresipError 如果发送失败
    public func sendDTMF(_ digit: Character) throws {
        let code = call_send_digit(rawPtr, Int8(digit.asciiValue ?? 0))
        guard code == 0 else {
            throw BaresipError(code: code)
        }
    }
    
    // MARK: - Internal Methods
    
    /// 更新通话状态（内部方法，由 BaresipUA 调用）
    /// - Parameter state: 新的通话状态
    func updateState(_ state: BaresipCallState) {
        self.state = state
    }
}

// MARK: - Equatable

extension BaresipCall: Equatable {
    public static func == (lhs: BaresipCall, rhs: BaresipCall) -> Bool {
        return lhs.uuid == rhs.uuid
    }
}

// MARK: - Hashable

extension BaresipCall: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

// MARK: - CustomStringConvertible

extension BaresipCall: CustomStringConvertible {
    public var description: String {
        return "BaresipCall(uuid: \(uuid), state: \(state.description), remote: \(remoteAddress))"
    }
}
