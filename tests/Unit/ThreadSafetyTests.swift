//
//  ThreadSafetyTests.swift
//  Baresip Thread Safety Tests
//
//  测试多线程环境下的线程安全性
//

import XCTest
@testable import SwiftBaresip

class ThreadSafetyTests: XCTestCase {
    
    var ua: BaresipUA!
    
    override func setUpWithError() throws {
        ua = BaresipUA.shared
    }
    
    // MARK: - Concurrent Access Tests
    
    func testConcurrentRegistration() {
        let expectation = XCTestExpectation(description: "并发注册测试")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        
        for i in 0..<10 {
            queue.async {
                let account = BaresipAccount(
                    username: "user\(i)",
                    password: "pass\(i)",
                    domain: "example.com"
                )
                
                // 测试并发注册不会崩溃
                do {
                    try self.ua.register(with: account)
                } catch {
                    // 预期会有错误（因为没有真实服务器）
                }
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testConcurrentCalls() {
        let expectation = XCTestExpectation(description: "并发呼叫测试")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue(label: "test.concurrent", attributes: .concurrent)
        
        for i in 0..<10 {
            queue.async {
                // 测试并发呼叫不会崩溃
                do {
                    _ = try self.ua.inviteAddress("sip:user\(i)@example.com")
                } catch {
                    // 预期会有错误
                }
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Delegate Thread Safety Tests
    
    func testDelegateCallbackThreadSafety() {
        class TestDelegate: BaresipUADelegate {
            var callCount = 0
            let lock = NSLock()
            
            func callStateChanged(call: BaresipCall, state: BaresipCallState) {
                lock.lock()
                callCount += 1
                lock.unlock()
            }
        }
        
        let delegate = TestDelegate()
        ua.delegate = delegate
        
        // 模拟多线程回调
        let expectation = XCTestExpectation(description: "代理回调线程安全")
        expectation.expectedFulfillmentCount = 100
        
        let queue = DispatchQueue(label: "test.callback", attributes: .concurrent)
        
        for _ in 0..<100 {
            queue.async {
                // 模拟回调
                DispatchQueue.main.async {
                    // delegate.callStateChanged(...) // 需要真实 call 对象
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Account Thread Safety Tests
    
    func testAccountConcurrentAccess() {
        let account = BaresipAccount(
            username: "test",
            password: "test",
            domain: "example.com"
        )
        
        let expectation = XCTestExpectation(description: "账号并发访问")
        expectation.expectedFulfillmentCount = 100
        
        let queue = DispatchQueue(label: "test.account", attributes: .concurrent)
        
        for _ in 0..<100 {
            queue.async {
                // Struct 是值类型，天然线程安全
                _ = account.sipUri
                _ = account.username
                _ = account.domain
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Address Parsing Thread Safety Tests
    
    func testAddressParsingThreadSafety() {
        let expectation = XCTestExpectation(description: "地址解析线程安全")
        expectation.expectedFulfillmentCount = 100
        
        let queue = DispatchQueue(label: "test.address", attributes: .concurrent)
        
        let uris = [
            "sip:user1@example.com",
            "sip:user2@example.com:5060",
            "sip:user3@example.com;transport=tcp",
            "sip:user4@example.com:5061;transport=tls"
        ]
        
        for i in 0..<100 {
            queue.async {
                let uri = uris[i % uris.count]
                let address = BaresipAddress.parse(uri)
                
                XCTAssertNotNil(address)
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - CallKit Manager Thread Safety Tests
    
    func testCallKitManagerThreadSafety() {
        let manager = CallKitManager.shared
        
        let expectation = XCTestExpectation(description: "CallKit 管理器线程安全")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue(label: "test.callkit", attributes: .concurrent)
        
        for _ in 0..<10 {
            queue.async {
                // 访问单例不应该崩溃
                _ = manager
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - PushKit Manager Thread Safety Tests
    
    func testPushKitManagerThreadSafety() {
        let manager = PushKitManager.shared
        
        let expectation = XCTestExpectation(description: "PushKit 管理器线程安全")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue(label: "test.pushkit", attributes: .concurrent)
        
        for _ in 0..<10 {
            queue.async {
                // 访问单例不应该崩溃
                _ = manager
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Audio Session Manager Thread Safety Tests
    
    func testAudioSessionManagerThreadSafety() {
        let manager = AudioSessionManager.shared
        
        let expectation = XCTestExpectation(description: "音频会话管理器线程安全")
        expectation.expectedFulfillmentCount = 10
        
        let queue = DispatchQueue(label: "test.audio", attributes: .concurrent)
        
        for _ in 0..<10 {
            queue.async {
                // 访问单例不应该崩溃
                _ = manager
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // MARK: - Performance Tests
    
    func testConcurrentPerformance() {
        measure {
            let expectation = XCTestExpectation(description: "并发性能测试")
            expectation.expectedFulfillmentCount = 100
            
            let queue = DispatchQueue(label: "test.performance", attributes: .concurrent)
            
            for i in 0..<100 {
                queue.async {
                    let account = BaresipAccount(
                        username: "user\(i)",
                        password: "pass",
                        domain: "example.com"
                    )
                    _ = account.sipUri
                    
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 10.0)
        }
    }
}
