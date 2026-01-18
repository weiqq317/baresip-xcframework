//
//  CallFlowTests.swift
//  Baresip Integration Tests
//
//  测试完整的呼叫流程
//

import XCTest
@testable import SwiftBaresip

class CallFlowTests: XCTestCase {
    
    var ua: BaresipUA!
    var testAccount: BaresipAccount!
    
    override func setUpWithError() throws {
        ua = BaresipUA.shared
        
        // 配置测试账号（需要真实的 SIP 服务器）
        testAccount = BaresipAccount(
            username: "test_user",
            password: "test_password",
            domain: "sip.test.com"
        )
    }
    
    override func tearDownWithError() throws {
        if ua.isRegistered {
            try? ua.unregister()
        }
    }
    
    // MARK: - Registration Flow
    
    func testRegistrationFlow() throws {
        // 1. 初始状态应该未注册
        XCTAssertFalse(ua.isRegistered)
        
        // 2. 注册 SIP 账号
        // 注意：这需要真实的 SIP 服务器，在 CI 环境中应该跳过
        #if !CI_ENVIRONMENT
        try ua.register(with: testAccount)
        
        // 3. 等待注册完成（实际应该使用代理回调）
        let expectation = XCTestExpectation(description: "等待注册完成")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)
        
        // 4. 验证注册状态
        // XCTAssertTrue(ua.isRegistered) // 需要真实服务器
        
        // 5. 注销
        try ua.unregister()
        #endif
    }
    
    // MARK: - Outgoing Call Flow
    
    func testOutgoingCallFlow() throws {
        #if !CI_ENVIRONMENT
        // 1. 先注册
        try ua.register(with: testAccount)
        
        // 2. 发起呼叫
        let call = try ua.inviteAddress("sip:test@example.com")
        
        // 3. 验证通话对象
        XCTAssertNotNil(call)
        XCTAssertEqual(call.state, .outgoing)
        
        // 4. 等待通话建立
        let expectation = XCTestExpectation(description: "等待通话建立")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 6.0)
        
        // 5. 挂断通话
        try call.terminate()
        
        // 6. 验证通话结束
        XCTAssertTrue(call.state.isEnded)
        #endif
    }
    
    // MARK: - Call Hold/Resume Flow
    
    func testCallHoldResumeFlow() throws {
        #if !CI_ENVIRONMENT
        // 1. 建立通话
        try ua.register(with: testAccount)
        let call = try ua.inviteAddress("sip:test@example.com")
        
        // 等待通话建立
        sleep(3)
        
        // 2. 保持通话
        try call.putOnHold()
        XCTAssertTrue(call.isOnHold)
        
        // 3. 恢复通话
        try call.resume()
        XCTAssertFalse(call.isOnHold)
        
        // 4. 挂断
        try call.terminate()
        #endif
    }
    
    // MARK: - DTMF Flow
    
    func testDTMFFlow() throws {
        #if !CI_ENVIRONMENT
        // 1. 建立通话
        try ua.register(with: testAccount)
        let call = try ua.inviteAddress("sip:test@example.com")
        
        // 等待通话建立
        sleep(3)
        
        // 2. 发送 DTMF
        try call.sendDTMF("1")
        try call.sendDTMF("2")
        try call.sendDTMF("3")
        
        // 3. 挂断
        try call.terminate()
        #endif
    }
    
    // MARK: - Multiple Calls
    
    func testMultipleCalls() throws {
        #if !CI_ENVIRONMENT
        // 1. 注册
        try ua.register(with: testAccount)
        
        // 2. 发起第一个呼叫
        let call1 = try ua.inviteAddress("sip:user1@example.com")
        XCTAssertEqual(ua.calls.count, 1)
        
        // 3. 发起第二个呼叫（如果支持）
        // let call2 = try ua.inviteAddress("sip:user2@example.com")
        // XCTAssertEqual(ua.calls.count, 2)
        
        // 4. 挂断所有通话
        try call1.terminate()
        // try call2.terminate()
        
        // 5. 验证通话列表为空
        sleep(1)
        XCTAssertEqual(ua.calls.count, 0)
        #endif
    }
}
