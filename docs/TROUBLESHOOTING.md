# Baresip XCFramework 故障排查指南

本文档提供常见问题的排查与解决方案。

---

## 📋 目录

- [编译问题](#编译问题)
- [集成问题](#集成问题)
- [运行时问题](#运行时问题)
- [网络问题](#网络问题)
- [音频问题](#音频问题)
- [CallKit 问题](#callkit-问题)
- [PushKit 问题](#pushkit-问题)

---

## 编译问题

### Q1: SDK 路径错误

**症状**:
```
xcrun: error: SDK "iphoneos" cannot be located
```

**原因**: Xcode Command Line Tools 未安装或路径配置错误

**解决方案**:
```bash
# 1. 安装 Command Line Tools
xcode-select --install

# 2. 设置 Xcode 路径
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

# 3. 验证
xcrun --sdk iphoneos --show-sdk-path
```

### Q2: CMake 版本过低

**症状**:
```
CMake 3.20 or higher is required. You are running version 3.19.0
```

**解决方案**:
```bash
# 使用 Homebrew 升级
brew upgrade cmake

# 验证版本
cmake --version
```

### Q3: 编译器找不到头文件

**症状**:
```
fatal error: 're.h' file not found
#include <re.h>
         ^~~~~~
```

**原因**: 依赖库未按顺序编译

**解决方案**:
```bash
# 按正确顺序编译
./scripts/build_libre.sh
./scripts/build_librem.sh
./scripts/build_baresip.sh
```

### Q4: lipo 合并失败

**症状**:
```
lipo: can't open input file: build/iphonesimulator/arm64/lib/libbaresip.a
```

**原因**: 编译产物不存在

**解决方案**:
```bash
# 检查编译产物
ls -la build/iphonesimulator/arm64/lib/

# 重新编译
./scripts/clean.sh
./scripts/build_all.sh
```

---

## 集成问题

### Q5: 桥接头文件找不到

**症状**:
```
'Baresip-Bridging-Header.h' file not found
```

**解决方案**:
1. 在 Xcode 中打开 `Build Settings`
2. 搜索 `Objective-C Bridging Header`
3. 设置路径为 `bridge/SwiftBaresip/Baresip-Bridging-Header.h`（相对于项目根目录）

### Q6: XCFramework 链接失败

**症状**:
```
ld: framework not found Baresip
```

**解决方案**:
1. 确保 `Baresip.xcframework` 已添加到项目
2. 在 `General` → `Frameworks, Libraries, and Embedded Content` 中检查
3. 确保 `Embed` 设置为 `Embed & Sign`

### Q7: Swift 模块导入失败

**症状**:
```
No such module 'SwiftBaresip'
```

**解决方案**:
1. 确保所有 Swift 文件已添加到项目
2. 检查 `Build Phases` → `Compile Sources`
3. 清理并重新构建项目（Cmd+Shift+K，然后 Cmd+B）

---

## 运行时问题

### Q8: 应用启动崩溃

**症状**:
```
dyld: Library not loaded: @rpath/Baresip.framework/Baresip
```

**解决方案**:
1. 检查 XCFramework 是否正确嵌入
2. 在 `Build Settings` → `Runpath Search Paths` 中添加 `@executable_path/Frameworks`

### Q9: SIP 注册失败

**症状**:
```
❌ SIP 注册失败: registrationFailed
```

**排查步骤**:
1. **检查网络连接**:
   ```swift
   // 测试网络可达性
   let reachability = NetworkReachability()
   print("网络可达: \\(reachability.isReachable)")
   ```

2. **验证账号信息**:
   ```swift
   print("SIP URI: \\(account.sipUri)")
   // 确保格式正确: sip:user@domain;transport=udp
   ```

3. **检查服务器端口**:
   ```swift
   // 默认端口 5060，TLS 端口 5061
   let account = BaresipAccount(
       username: "user",
       password: "pass",
       domain: "sip.example.com",
       transport: .udp,
       port: 5060
   )
   ```

4. **查看服务器日志**:
   联系 SIP 服务器管理员查看注册请求日志

### Q10: 呼叫无法建立

**症状**:
```
❌ 呼叫失败: callFailed
```

**排查步骤**:
1. **确保已注册**:
   ```swift
   guard BaresipUA.shared.isRegistered else {
       print("未注册，无法呼叫")
       return
   }
   ```

2. **验证 SIP URI 格式**:
   ```swift
   // 正确格式
   try BaresipUA.shared.inviteAddress("sip:user@domain.com")
   
   // 错误格式
   // try BaresipUA.shared.inviteAddress("user@domain.com") // 缺少 sip:
   ```

3. **检查 NAT 穿透**:
   ```swift
   // 确保 ICE 模块已启用
   // 配置 STUN/TURN 服务器
   ```

---

## 网络问题

### Q11: NAT 穿透失败

**症状**: 通话无法建立，或单向音频

**解决方案**:
1. **配置 STUN 服务器**:
   ```
   stun_server=stun:stun.l.google.com:19302
   ```

2. **配置 TURN 服务器**:
   ```
   turn_server=turn:turn.example.com:3478?transport=udp
   turn_user=username
   turn_pass=password
   ```

3. **使用 TCP/TLS 传输**:
   ```swift
   let account = BaresipAccount(
       username: "user",
       password: "pass",
       domain: "sip.example.com",
       transport: .tcp // 或 .tls
   )
   ```

### Q12: 网络切换导致通话中断

**症状**: Wi-Fi 切换到蜂窝网络时通话断开

**解决方案**:
1. **启用网络漫游**:
   Baresip 的 `netroam` 模块会自动处理网络切换

2. **监听网络状态**:
   ```swift
   func networkReachabilityChanged(isReachable: Bool) {
       if !isReachable {
           // 网络断开，保存通话状态
       } else {
           // 网络恢复，尝试重连
       }
   }
   ```

---

## 音频问题

### Q13: 无法听到对方声音

**排查步骤**:
1. **检查麦克风权限**:
   ```swift
   AVAudioSession.sharedInstance().requestRecordPermission { granted in
       print("麦克风权限: \\(granted)")
   }
   ```

2. **验证音频会话配置**:
   ```swift
   let session = AVAudioSession.sharedInstance()
   print("Category: \\(session.category)")
   print("Mode: \\(session.mode)")
   // 应该是: Category: playAndRecord, Mode: voiceChat
   ```

3. **检查音频路由**:
   ```swift
   let route = AVAudioSession.sharedInstance().currentRoute
   for output in route.outputs {
       print("输出设备: \\(output.portName)")
   }
   ```

### Q14: 回声问题

**症状**: 通话中听到自己的声音

**解决方案**:
1. **启用回声消除**:
   Baresip 的 `auaec` 模块会自动处理回声消除

2. **使用耳机**:
   建议使用耳机进行通话

3. **调整音频会话**:
   ```swift
   try session.setCategory(
       .playAndRecord,
       mode: .voiceChat, // 启用回声消除
       options: [.allowBluetooth]
   )
   ```

### Q15: 音量过小

**解决方案**:
1. **检查系统音量**:
   ```swift
   let volume = AVAudioSession.sharedInstance().outputVolume
   print("系统音量: \\(volume)")
   ```

2. **启用自动增益控制（AGC）**:
   Baresip 的 `auagc` 模块会自动调整音量

---

## CallKit 问题

### Q16: CallKit UI 不显示

**症状**: 来电时没有系统通话界面

**排查步骤**:
1. **检查 Info.plist 配置**:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>voip</string>
   </array>
   ```

2. **验证 CallKit 报告**:
   ```swift
   callKitManager.reportIncomingCall(call) { error in
       if let error = error {
           print("❌ CallKit 报告失败: \\(error)")
       }
   }
   ```

3. **检查通话 UUID**:
   ```swift
   print("通话 UUID: \\(call.uuid)")
   // 确保 UUID 唯一
   ```

### Q17: CallKit 通话记录不显示

**症状**: 系统通话记录中没有记录

**解决方案**:
确保正确报告通话状态：
```swift
// 来电
callKitManager.reportIncomingCall(call)

// 通话建立
callKitManager.reportCallConnected(call)

// 通话结束
callKitManager.reportCallEnded(call)
```

---

## PushKit 问题

### Q18: 无法接收 VoIP 推送

**排查步骤**:
1. **检查 Entitlements**:
   ```xml
   <key>com.apple.developer.pushkit</key>
   <true/>
   ```

2. **验证推送 Token**:
   ```swift
   pushKitManager.onTokenReceived = { token in
       print("📱 Push Token: \\(token)")
       // 确保 Token 已上报到服务器
   }
   ```

3. **测试推送**:
   使用工具（如 Pusher）发送测试推送

### Q19: 后台无法唤醒

**症状**: 应用在后台/终止状态下无法接收来电

**解决方案**:
1. **检查后台模式**:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>voip</string>
       <string>fetch</string>
       <string>remote-notification</string>
   </array>
   ```

2. **实现 PushKit 回调**:
   ```swift
   func pushRegistry(
       _ registry: PKPushRegistry,
       didReceiveIncomingPushWith payload: PKPushPayload,
       for type: PKPushType,
       completion: @escaping () -> Void
   ) {
       // 唤醒 Baresip
       BaresipUA.shared.wakeup()
       
       // 报告来电到 CallKit
       // ...
       
       completion()
   }
   ```

---

## 性能问题

### Q20: CPU 占用率过高

**排查步骤**:
1. **使用 Instruments 分析**:
   - 打开 Xcode → Product → Profile
   - 选择 `Time Profiler`
   - 查找热点函数

2. **检查编译优化**:
   ```bash
   # 确保使用 -O3 优化
   CFLAGS="... -O3 -DNDEBUG ..."
   ```

3. **禁用不需要的模块**:
   仅启用核心模块

### Q21: 内存泄漏

**排查步骤**:
1. **使用 Instruments 检测**:
   - 打开 Xcode → Product → Profile
   - 选择 `Leaks`
   - 运行应用并进行通话

2. **检查 deinit 调用**:
   ```swift
   deinit {
       print("BaresipCall deinit")
       call_destroy(rawPtr)
   }
   ```

3. **避免循环引用**:
   ```swift
   // 使用 weak self
   DispatchQueue.main.async { [weak self] in
       self?.delegate?.callStateChanged(...)
   }
   ```

---

## 调试技巧

### 启用详细日志

```swift
// 在 AppDelegate 中
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 启用 Baresip 日志
    // TODO: 添加日志配置
    
    return true
}
```

### 使用断点调试

1. 在 Xcode 中设置断点
2. 查看变量值
3. 使用 LLDB 命令：
   ```
   po call
   po call.state
   po call.remoteAddress
   ```

### 网络抓包

使用 Wireshark 抓取 SIP 信令：
```bash
# 安装 Wireshark
brew install --cask wireshark

# 过滤 SIP 流量
sip
```

---

## 获取帮助

如果问题仍未解决：

1. **查阅文档**:
   - [README](README.md)
   - [API 参考](API_REFERENCE.md)
   - [编译指南](BUILDING.md)

2. **提交 Issue**:
   - 提供详细的错误信息
   - 附上日志输出
   - 说明复现步骤

3. **联系支持**:
   - 发送邮件到技术支持
   - 提供设备信息与系统版本

---

**提示**: 大部分问题都与配置错误或网络环境有关，请仔细检查配置文件和网络设置。
