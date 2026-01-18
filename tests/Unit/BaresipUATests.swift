//
//  BaresipUATests.swift
//  Baresip Unit Tests
//
//  测试 BaresipUA 核心功能
//

import XCTest
@testable import SwiftBaresip

class BaresipUATests: XCTestCase {
    
    var ua: BaresipUA!
    
    override func setUpWithError() throws {
        ua = BaresipUA.shared
    }
    
    override func tearDownWithError() throws {
        // 清理
        if ua.isRegistered {
            try? ua.unregister()
        }
    }
    
    // MARK: - Initialization Tests
    
    func testSingletonInstance() {
        let instance1 = BaresipUA.shared
        let instance2 = BaresipUA.shared
        
        XCTAssertTrue(instance1 === instance2, "BaresipUA 应该是单例")
    }
    
    func testInitialState() {
        XCTAssertFalse(ua.isRegistered, "初始状态应该未注册")
        XCTAssertEqual(ua.calls.count, 0, "初始状态应该没有通话")
    }
    
    // MARK: - Registration Tests
    
    func testSIPRegistration() throws {
        let account = BaresipAccount(
            username: "test",
            password: "test123",
            domain: "sip.example.com"
        )
        
        // 注意：这需要真实的 SIP 服务器
        // 在单元测试中，我们只测试 API 调用不会崩溃
        XCTAssertNoThrow(try ua.register(with: account))
    }
    
    func testSIPUnregistration() throws {
        // 测试注销不会崩溃
        XCTAssertNoThrow(try ua.unregister())
    }
    
    func testAccountConfiguration() {
        let account = BaresipAccount(
            username: "user",
            password: "pass",
            domain: "example.com",
            transport: .udp,
            port: 5060
        )
        
        XCTAssertEqual(account.username, "user")
        XCTAssertEqual(account.password, "pass")
        XCTAssertEqual(account.domain, "example.com")
        XCTAssertEqual(account.transport, .udp)
        XCTAssertEqual(account.port, 5060)
        XCTAssertEqual(account.sipUri, "sip:user@example.com;transport=udp")
    }
    
    // MARK: - Call Tests
    
    func testInviteAddress() {
        // 测试呼叫 API 不会崩溃
        XCTAssertNoThrow(try ua.inviteAddress("sip:user@example.com"))
    }
    
    func testCallLookup() {
        let uuid = UUID()
        let call = ua.call(with: uuid)
        
        XCTAssertNil(call, "不存在的 UUID 应该返回 nil")
    }
    
    // MARK: - PushKit Tests
    
    func testWakeup() {
        // 测试唤醒不会崩溃
        XCTAssertNoThrow(ua.wakeup())
    }
    
    func testRegisterPushToken() {
        let token = "test_push_token_123456"
        
        // 测试推送 Token 注册不会崩溃
        XCTAssertNoThrow(ua.registerPushToken(token))
    }
    
    // MARK: - Performance Tests
    
    func testRegistrationPerformance() {
        let account = BaresipAccount(
            username: "test",
            password: "test123",
            domain: "sip.example.com"
        )
        
        measure {
            try? ua.register(with: account)
        }
    }
}
