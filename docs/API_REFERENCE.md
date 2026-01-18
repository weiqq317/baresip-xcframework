# Baresip XCFramework API 参考文档

本文档提供 Baresip XCFramework 的完整 API 参考。

---

## 核心类

### BaresipUA

用户代理类，对应 Linphone 的 `LinphoneCore`。

#### 属性

```swift
static let shared: BaresipUA
```
单例实例。

```swift
weak var delegate: BaresipUADelegate?
```
状态回调代理。

```swift
private(set) var isRegistered: Bool
```
当前注册状态。

```swift
var calls: [BaresipCall]
```
当前活跃的通话列表。

#### 方法

##### register(with:)

注册 SIP 账号。

```swift
func register(with account: BaresipAccount) throws
```

**参数**:
- `account`: SIP 账号配置

**抛出**:
- `BaresipError` 如果注册失败

**示例**:
```swift
let account = BaresipAccount(
    username: "user",
    password: "password",
    domain: "sip.example.com"
)

do {
    try BaresipUA.shared.register(with: account)
} catch {
    print("注册失败: \\(error)")
}
```

##### unregister()

注销 SIP 账号。

```swift
func unregister() throws
```

**抛出**:
- `BaresipError` 如果注销失败

##### inviteAddress(_:)

发起语音呼叫。

```swift
func inviteAddress(_ address: String) throws -> BaresipCall
```

**参数**:
- `address`: 对方 SIP URI（如 "sip:user@domain"）

**返回**:
- 通话对象

**抛出**:
- `BaresipError` 如果呼叫失败

**示例**:
```swift
do {
    let call = try BaresipUA.shared.inviteAddress("sip:user@example.com")
    print("呼叫已发起: \\(call)")
} catch {
    print("呼叫失败: \\(error)")
}
```

##### call(with:)

根据 UUID 获取通话对象。

```swift
func call(with uuid: UUID) -> BaresipCall?
```

**参数**:
- `uuid`: 通话唯一标识符

**返回**:
- 通话对象（如果存在）

##### wakeup()

唤醒 Baresip（用于 PushKit 后台唤醒）。

```swift
func wakeup()
```

##### registerPushToken(_:)

注册推送 Token。

```swift
func registerPushToken(_ token: String)
```

**参数**:
- `token`: 设备推送 Token

---

### BaresipCall

通话对象类，对应 Linphone 的 `LinphoneCall`。

#### 属性

```swift
let uuid: UUID
```
通话唯一标识符（用于 CallKit 集成）。

```swift
private(set) var state: BaresipCallState
```
当前通话状态。

```swift
var remoteAddress: String
```
对方 SIP URI。

```swift
var localAddress: String
```
本地 SIP URI。

```swift
var duration: Int
```
通话时长（秒）。

```swift
var isOnHold: Bool
```
是否处于保持状态。

#### 方法

##### accept()

接听来电。

```swift
func accept() throws
```

**抛出**:
- `BaresipError` 如果接听失败

##### terminate()

挂断通话。

```swift
func terminate() throws
```

**抛出**:
- `BaresipError` 如果挂断失败

##### putOnHold()

呼叫保持。

```swift
func putOnHold() throws
```

**抛出**:
- `BaresipError` 如果保持失败

##### resume()

恢复呼叫。

```swift
func resume() throws
```

**抛出**:
- `BaresipError` 如果恢复失败

##### sendDTMF(_:)

发送 DTMF 信号。

```swift
func sendDTMF(_ digit: Character) throws
```

**参数**:
- `digit`: DTMF 数字（0-9, *, #, A-D）

**抛出**:
- `BaresipError` 如果发送失败

---

### BaresipAccount

SIP 账号配置结构体。

#### 属性

```swift
let username: String
```
SIP 用户名。

```swift
let password: String
```
SIP 密码。

```swift
let domain: String
```
SIP 域名（服务器地址）。

```swift
let transport: BaresipTransportType
```
传输协议（UDP/TCP/TLS）。

```swift
let port: UInt16
```
端口号（默认 5060）。

```swift
let displayName: String?
```
显示名称。

```swift
var sipUri: String
```
完整的 SIP URI（自动生成）。

#### 初始化

```swift
init(
    username: String,
    password: String,
    domain: String,
    transport: BaresipTransportType = .udp,
    port: UInt16 = 5060,
    displayName: String? = nil
)
```

---

## 协议

### BaresipUADelegate

用户代理代理协议，对应 Linphone 的 `LinphoneCoreListener`。

#### 方法

##### callStateChanged(call:state:)

通话状态变更回调。

```swift
func callStateChanged(call: BaresipCall, state: BaresipCallState)
```

**参数**:
- `call`: 通话对象
- `state`: 新的通话状态

##### registrationStateChanged(isRegistered:error:)

SIP 注册状态变更回调（可选）。

```swift
func registrationStateChanged(isRegistered: Bool, error: Error?)
```

**参数**:
- `isRegistered`: 是否已注册
- `error`: 错误信息（如果注册失败）

##### networkReachabilityChanged(isReachable:)

网络状态变更回调（可选）。

```swift
func networkReachabilityChanged(isReachable: Bool)
```

**参数**:
- `isReachable`: 网络是否可达

---

## 枚举

### BaresipCallState

通话状态枚举，对应 Linphone 的 `LinphoneCallState`。

#### 枚举值

```swift
case idle           // 空闲
case incoming       // 来电
case outgoing       // 呼出
case ringing        // 振铃中
case connecting     // 连接中
case connected      // 已连接
case held           // 保持中
case paused         // 暂停
case disconnected   // 已断开
case error          // 错误
```

#### 属性

```swift
var isActive: Bool
```
是否为活跃通话状态。

```swift
var isEnded: Bool
```
是否为结束状态。

```swift
var description: String
```
状态描述。

---

### BaresipError

错误类型枚举。

#### 枚举值

```swift
case registrationFailed     // SIP 注册失败
case callFailed             // 呼叫失败
case invalidAddress         // 无效的 SIP 地址
case networkError           // 网络错误
case authenticationFailed   // 认证失败
case timeout                // 请求超时
case notFound               // 用户不存在
case busy                   // 用户忙
case declined               // 呼叫被拒绝
case notAcceptable          // 不可接受的请求
case serverError            // 服务器错误
case unknown                // 未知错误
```

#### 属性

```swift
var errorDescription: String?
```
错误描述。

---

### BaresipTransportType

SIP 传输协议类型。

#### 枚举值

```swift
case udp    // UDP 传输
case tcp    // TCP 传输
case tls    // TLS 加密传输
```

---

## 苹果生态集成

### CallKitManager

CallKit 集成管理器，实现系统级通话 UI。

#### 属性

```swift
static let shared: CallKitManager
```
单例实例。

#### 方法

##### reportIncomingCall(_:completion:)

报告来电。

```swift
func reportIncomingCall(_ call: BaresipCall, completion: @escaping (Error?) -> Void)
```

##### startOutgoingCall(_:completion:)

开始呼出通话。

```swift
func startOutgoingCall(_ call: BaresipCall, completion: @escaping (Error?) -> Void)
```

##### reportCallConnected(_:)

报告通话已连接。

```swift
func reportCallConnected(_ call: BaresipCall)
```

##### reportCallEnded(_:reason:)

报告通话已结束。

```swift
func reportCallEnded(_ call: BaresipCall, reason: CXCallEndedReason = .remoteEnded)
```

---

### PushKitManager

PushKit 集成管理器，实现后台 VoIP 推送。

#### 属性

```swift
static let shared: PushKitManager
```
单例实例。

```swift
var onTokenReceived: ((String) -> Void)?
```
推送 Token 回调。

```swift
var onPushReceived: (([AnyHashable: Any]) -> Void)?
```
推送接收回调。

#### 方法

##### registerForPushNotifications()

注册 VoIP 推送。

```swift
func registerForPushNotifications()
```

##### unregisterForPushNotifications()

注销 VoIP 推送。

```swift
func unregisterForPushNotifications()
```

---

### AudioSessionManager

音频会话管理器，管理 AVAudioSession。

#### 属性

```swift
static let shared: AudioSessionManager
```
单例实例。

#### 方法

##### configureAudioSession()

配置音频会话为 VoIP 场景。

```swift
func configureAudioSession()
```

##### deconfigureAudioSession()

停用音频会话。

```swift
func deconfigureAudioSession()
```

---

## 使用示例

### 完整的呼叫流程

```swift
import SwiftUI
import SwiftBaresip

class CallManager: ObservableObject, BaresipUADelegate {
    @Published var isRegistered = false
    @Published var currentCall: BaresipCall?
    
    init() {
        BaresipUA.shared.delegate = self
    }
    
    // 注册 SIP 账号
    func register() {
        let account = BaresipAccount(
            username: "user",
            password: "password",
            domain: "sip.example.com"
        )
        
        do {
            try BaresipUA.shared.register(with: account)
        } catch {
            print("注册失败: \\(error)")
        }
    }
    
    // 发起呼叫
    func makeCall(to address: String) {
        do {
            let call = try BaresipUA.shared.inviteAddress(address)
            currentCall = call
        } catch {
            print("呼叫失败: \\(error)")
        }
    }
    
    // 接听来电
    func answerCall() {
        guard let call = currentCall else { return }
        
        do {
            try call.accept()
        } catch {
            print("接听失败: \\(error)")
        }
    }
    
    // 挂断通话
    func hangup() {
        guard let call = currentCall else { return }
        
        do {
            try call.terminate()
        } catch {
            print("挂断失败: \\(error)")
        }
    }
    
    // MARK: - BaresipUADelegate
    
    func callStateChanged(call: BaresipCall, state: BaresipCallState) {
        DispatchQueue.main.async {
            if state.isEnded {
                self.currentCall = nil
            } else {
                self.currentCall = call
            }
        }
    }
    
    func registrationStateChanged(isRegistered: Bool, error: Error?) {
        DispatchQueue.main.async {
            self.isRegistered = isRegistered
        }
    }
}
```

---

## 注意事项

1. **线程安全**: 所有 Baresip API 调用都通过串行队列隔离，确保线程安全
2. **内存管理**: 使用 Opaque Pointer 封装 C 结构体，通过 `deinit` 自动释放
3. **错误处理**: 所有可能失败的操作都使用 Swift 标准错误处理（`try`/`catch`）
4. **回调线程**: 所有代理回调都在主线程执行，可直接更新 UI

---

## 与 Linphone API 对比

| Linphone | Baresip | 差异 |
|----------|---------|------|
| `LinphoneCore` | `BaresipUA` | 类名变更 |
| `LinphoneCall` | `BaresipCall` | 类名变更 |
| `call.accept()` | `try call.accept()` | 增加错误处理 |
| `core.addDelegate()` | `core.delegate =` | 单一代理模式 |

---

更多示例请参考 `examples/` 目录。
