# Baresip iOS Example

完整的 VoIP 示例应用，展示 Baresip XCFramework 的所有功能。

## 功能特性

### ✅ 核心功能
- [x] SIP 注册/注销
- [x] 发起呼叫
- [x] 接听来电
- [x] 挂断通话
- [x] 保持/恢复通话
- [x] 静音/取消静音
- [x] 扬声器切换
- [x] DTMF 拨号

### ✅ 系统集成
- [x] CallKit 集成（系统通话界面）
- [x] PushKit 集成（VoIP 推送）
- [x] 音频会话管理
- [x] 后台模式支持

### ✅ 用户界面
- [x] 主界面（注册+拨号）
- [x] 通话界面（完整控制）
- [x] 设置界面（音频/网络配置）
- [x] 快速拨号
- [x] 状态指示器

## 文件结构

```
examples/iOS/
├── AppDelegate.swift          # 应用生命周期
├── SceneDelegate.swift        # Scene 生命周期（iOS 13+）
├── ContentView.swift          # 主界面
├── CallView.swift             # 通话界面
├── SettingsView.swift         # 设置界面
├── Info.plist                 # 应用配置
└── Entitlements.plist         # 权限配置
```

## 编译步骤

### 1. 创建 Xcode 项目

```bash
# 在 Xcode 中创建新项目
# File -> New -> Project
# iOS -> App
# Interface: SwiftUI
# Language: Swift
```

### 2. 添加文件

将以下文件添加到项目：
- `AppDelegate.swift`
- `SceneDelegate.swift`
- `ContentView.swift`
- `CallView.swift`
- `SettingsView.swift`
- `Info.plist`
- `Entitlements.plist`

### 3. 集成 XCFramework

1. 将 `output/Baresip.xcframework` 拖入项目
2. 在 Target -> General -> Frameworks, Libraries, and Embedded Content 中添加
3. 设置为 "Embed & Sign"

### 4. 添加 Swift 桥接层

将 `bridge/SwiftBaresip/` 目录中的所有文件添加到项目：
- `Core/` - 核心类
- `CallKit/` - CallKit 集成
- `PushKit/` - PushKit 集成
- `Audio/` - 音频管理
- `Baresip-Bridging-Header.h` - C 桥接头文件

### 5. 配置项目设置

#### Build Settings
- **Bridging Header**: 设置为 `Baresip-Bridging-Header.h` 的路径
- **Swift Language Version**: Swift 5
- **iOS Deployment Target**: 12.0 或更高

#### Signing & Capabilities
- 添加 **Background Modes**:
  - Voice over IP
  - Audio, AirPlay, and Picture in Picture
- 添加 **Push Notifications**

#### Info.plist
确保包含以下权限：
- `NSMicrophoneUsageDescription`
- `UIBackgroundModes`

### 6. 编译运行

```bash
# 选择真实设备或模拟器
# Product -> Run (⌘R)
```

## 使用说明

### 1. 配置 SIP 账号

在主界面输入：
- 用户名
- 密码
- 服务器域名

点击"注册"按钮。

### 2. 发起呼叫

1. 在"拨号"区域输入 SIP URI
2. 点击"呼叫"按钮
3. 进入通话界面

### 3. 通话控制

在通话界面可以：
- 静音/取消静音
- 切换扬声器
- 保持/恢复通话
- 发送 DTMF
- 挂断通话

### 4. 设置

点击右上角齿轮图标进入设置：
- 音频编解码器选择
- 回声消除/噪音抑制
- 网络协议配置
- STUN/ICE 设置

## 测试建议

### 真实设备测试

1. **注册测试**
   - 测试正确的账号信息
   - 测试错误的账号信息
   - 测试网络断开重连

2. **呼叫测试**
   - 发起呼叫
   - 接听来电
   - 拒绝来电
   - 呼叫超时

3. **通话功能测试**
   - 静音/取消静音
   - 保持/恢复
   - DTMF 发送
   - 扬声器切换

4. **系统集成测试**
   - CallKit 来电显示
   - PushKit 后台唤醒
   - 音频中断处理
   - 蓝牙设备切换

### 模拟器测试

注意：某些功能在模拟器上不可用：
- ❌ PushKit（需要真实设备）
- ❌ CallKit（部分功能受限）
- ✅ SIP 注册和呼叫
- ✅ UI 和交互

## 故障排查

### 编译错误

**问题**: 找不到 SwiftBaresip 模块
**解决**: 确保已正确添加 XCFramework 和 Swift 桥接文件

**问题**: Bridging header not found
**解决**: 检查 Build Settings 中的 Bridging Header 路径

### 运行时错误

**问题**: 注册失败
**解决**: 
- 检查网络连接
- 验证 SIP 服务器地址
- 检查账号密码

**问题**: 无法接听来电
**解决**:
- 确保已配置 CallKit
- 检查 Info.plist 中的权限
- 验证 PushKit 注册

## 下一步

- [ ] 添加通话历史记录
- [ ] 添加联系人管理
- [ ] 添加通话录音
- [ ] 添加视频通话（可选）
- [ ] 添加群组通话（可选）

## 许可证

BSD 3-Clause License

---

**需要帮助？** 查看 `docs/TROUBLESHOOTING.md`
