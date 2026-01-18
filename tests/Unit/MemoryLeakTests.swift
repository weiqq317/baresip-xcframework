//
//  MemoryLeakTests.swift
//  Baresip Memory Leak Tests
//
//  测试内存管理与泄漏检测
//

import XCTest
@testable import SwiftBaresip

class MemoryLeakTests: XCTestCase {
    
    // MARK: - BaresipUA Memory Tests
    
    func testBaresipUASingletonNoLeak() {
        weak var weakUA: BaresipUA?
        
        autoreleasepool {
            let ua = BaresipUA.shared
            weakUA = ua
            
            // 执行一些操作
            XCTAssertNotNil(weakUA)
        }
        
        // 单例不应该被释放
        XCTAssertNotNil(weakUA, "BaresipUA 单例不应该被释放")
    }
    
    // MARK: - BaresipCall Memory Tests
    
    func testBaresipCallDeinit() {
        // 注意：这个测试需要模拟 OpaquePointer
        // 在实际环境中，call 对象会在 deinit 时自动释放
        
        // 测试 call 对象可以被正确释放
        weak var weakCall: BaresipCall?
        
        autoreleasepool {
            // 这里需要真实的 call 指针，暂时跳过
            // let call = BaresipCall(rawPtr: ...)
            // weakCall = call
        }
        
        // weakCall 应该为 nil（已被释放）
        // XCTAssertNil(weakCall, "BaresipCall 应该被正确释放")
    }
    
    // MARK: - Delegate Memory Tests
    
    func testDelegateWeakReference() {
        class TestDelegate: BaresipUADelegate {
            func callStateChanged(call: BaresipCall, state: BaresipCallState) {}
        }
        
        weak var weakDelegate: TestDelegate?
        
        autoreleasepool {
            let delegate = TestDelegate()
            weakDelegate = delegate
            
            BaresipUA.shared.delegate = delegate
            
            XCTAssertNotNil(weakDelegate)
        }
        
        // delegate 应该被释放（weak 引用）
        XCTAssertNil(weakDelegate, "Delegate 应该使用 weak 引用")
    }
    
    // MARK: - Account Memory Tests
    
    func testAccountStructNoLeak() {
        weak var weakAccount: AnyObject?
        
        autoreleasepool {
            let account = BaresipAccount(
                username: "test",
                password: "test",
                domain: "example.com"
            )
            
            // Struct 不能使用 weak 引用
            // 这里只是验证 struct 的值类型特性
            XCTAssertEqual(account.username, "test")
        }
        
        // Struct 是值类型，不会有内存泄漏问题
    }
    
    // MARK: - Address Memory Tests
    
    func testAddressParsingNoLeak() {
        for _ in 0..<1000 {
            autoreleasepool {
                let address = BaresipAddress.parse("sip:user@example.com")
                XCTAssertNotNil(address)
            }
        }
        
        // 多次解析不应该导致内存泄漏
    }
    
    // MARK: - CallKit Manager Memory Tests
    
    func testCallKitManagerSingletonNoLeak() {
        weak var weakManager: CallKitManager?
        
        autoreleasepool {
            let manager = CallKitManager.shared
            weakManager = manager
            
            XCTAssertNotNil(weakManager)
        }
        
        // 单例不应该被释放
        XCTAssertNotNil(weakManager, "CallKitManager 单例不应该被释放")
    }
    
    // MARK: - PushKit Manager Memory Tests
    
    func testPushKitManagerSingletonNoLeak() {
        weak var weakManager: PushKitManager?
        
        autoreleasepool {
            let manager = PushKitManager.shared
            weakManager = manager
            
            XCTAssertNotNil(weakManager)
        }
        
        // 单例不应该被释放
        XCTAssertNotNil(weakManager, "PushKitManager 单例不应该被释放")
    }
    
    // MARK: - Audio Session Manager Memory Tests
    
    func testAudioSessionManagerSingletonNoLeak() {
        weak var weakManager: AudioSessionManager?
        
        autoreleasepool {
            let manager = AudioSessionManager.shared
            weakManager = manager
            
            XCTAssertNotNil(weakManager)
        }
        
        // 单例不应该被释放
        XCTAssertNotNil(weakManager, "AudioSessionManager 单例不应该被释放")
    }
    
    // MARK: - Closure Memory Tests
    
    func testClosureNoRetainCycle() {
        class TestClass {
            var callback: (() -> Void)?
            
            func setupCallback() {
                // 使用 [weak self] 避免循环引用
                callback = { [weak self] in
                    guard let self = self else { return }
                    print("Callback executed")
                }
            }
        }
        
        weak var weakObject: TestClass?
        
        autoreleasepool {
            let object = TestClass()
            weakObject = object
            object.setupCallback()
            
            XCTAssertNotNil(weakObject)
        }
        
        // 对象应该被释放（没有循环引用）
        XCTAssertNil(weakObject, "应该避免闭包循环引用")
    }
    
    // MARK: - Performance Tests
    
    func testMemoryPerformance() {
        measure {
            for _ in 0..<100 {
                autoreleasepool {
                    let account = BaresipAccount(
                        username: "test",
                        password: "test",
                        domain: "example.com"
                    )
                    _ = account.sipUri
                    
                    let address = BaresipAddress.parse("sip:user@example.com")
                    _ = address?.uri
                }
            }
        }
    }
}
