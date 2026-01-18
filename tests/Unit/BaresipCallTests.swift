//
//  BaresipCallTests.swift
//  Baresip Unit Tests
//
//  测试 BaresipCall 核心功能
//

import XCTest
@testable import SwiftBaresip

class BaresipCallTests: XCTestCase {
    
    // MARK: - State Tests
    
    func testCallStateEnum() {
        let idle = BaresipCallState.idle
        let connected = BaresipCallState.connected
        let disconnected = BaresipCallState.disconnected
        
        XCTAssertFalse(idle.isActive)
        XCTAssertTrue(connected.isActive)
        XCTAssertFalse(disconnected.isActive)
        
        XCTAssertFalse(idle.isEnded)
        XCTAssertFalse(connected.isEnded)
        XCTAssertTrue(disconnected.isEnded)
    }
    
    func testCallStateDescription() {
        XCTAssertEqual(BaresipCallState.idle.description, "空闲")
        XCTAssertEqual(BaresipCallState.incoming.description, "来电")
        XCTAssertEqual(BaresipCallState.connected.description, "通话中")
        XCTAssertEqual(BaresipCallState.disconnected.description, "已断开")
    }
    
    func testCallStateFromEvent() {
        let incoming = BaresipCallState(fromCallEvent: 0) // CALL_EVENT_INCOMING
        let ringing = BaresipCallState(fromCallEvent: 1) // CALL_EVENT_RINGING
        let connected = BaresipCallState(fromCallEvent: 3) // CALL_EVENT_ESTABLISHED
        let closed = BaresipCallState(fromCallEvent: 4) // CALL_EVENT_CLOSED
        
        XCTAssertEqual(incoming, .incoming)
        XCTAssertEqual(ringing, .ringing)
        XCTAssertEqual(connected, .connected)
        XCTAssertEqual(closed, .disconnected)
    }
    
    // MARK: - Error Tests
    
    func testBaresipError() {
        let regError = BaresipError.registrationFailed
        let callError = BaresipError.callFailed
        let authError = BaresipError.authenticationFailed
        
        XCTAssertNotNil(regError.errorDescription)
        XCTAssertNotNil(callError.errorDescription)
        XCTAssertNotNil(authError.errorDescription)
        
        XCTAssertEqual(regError.errorDescription, "SIP 注册失败")
        XCTAssertEqual(callError.errorDescription, "呼叫失败")
        XCTAssertEqual(authError.errorDescription, "认证失败")
    }
    
    func testErrorFromCode() {
        let error1 = BaresipError(code: -1)
        let error2 = BaresipError(code: -2)
        let error99 = BaresipError(code: -999)
        
        XCTAssertEqual(error1, .registrationFailed)
        XCTAssertEqual(error2, .callFailed)
        XCTAssertEqual(error99, .unknown)
    }
    
    // MARK: - Account Tests
    
    func testAccountSIPUri() {
        let account1 = BaresipAccount(
            username: "user",
            password: "pass",
            domain: "example.com"
        )
        
        XCTAssertEqual(account1.sipUri, "sip:user@example.com;transport=udp")
        
        let account2 = BaresipAccount(
            username: "user",
            password: "pass",
            domain: "example.com",
            transport: .tls,
            port: 5061
        )
        
        XCTAssertEqual(account2.sipUri, "sip:user@example.com:5061;transport=tls")
    }
    
    func testAccountTransportTypes() {
        XCTAssertEqual(BaresipTransportType.udp.rawValue, "udp")
        XCTAssertEqual(BaresipTransportType.tcp.rawValue, "tcp")
        XCTAssertEqual(BaresipTransportType.tls.rawValue, "tls")
    }
}
