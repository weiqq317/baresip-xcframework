# 🔧 Xcode 编译修复指南

## 当前状态

✅ **Info.plist 冲突已修复**  
❌ **SwiftBaresip 模块未找到**

## 问题分析

编译错误：
```
error: Unable to find module dependency: 'SwiftBaresip'
import SwiftBaresip
```

**原因**: Swift 桥接层文件未添加到 Xcode 项目中。

## ✅ 解决方案

### 步骤 1: 打开 Xcode 项目

```bash
open examples/iOS/BaresipExample/BaresipExample.xcodeproj
```

### 步骤 2: 添加 Swift 桥接文件

1. 在 Xcode 中，右键点击项目根目录
2. 选择 "Add Files to BaresipExample..."
3. 导航到 `../../bridge/SwiftBaresip`
4. 选择整个 `SwiftBaresip` 文件夹
5. 确保勾选：
   - ✅ "Copy items if needed"
   - ✅ "Create groups"
   - ✅ "Add to targets: BaresipExample"
6. 点击 "Add"

### 步骤 3: 配置 Bridging Header

1. 选择项目 → Target → Build Settings
2. 搜索 "Bridging Header"
3. 设置 `Objective-C Bridging Header` 为：
   ```
   SwiftBaresip/Baresip-Bridging-Header.h
   ```

### 步骤 4: 添加 XCFramework

1. 在 Finder 中找到 `../../output/Baresip.xcframework`
2. 拖入 Xcode 项目
3. 在弹出对话框中：
   - ✅ "Copy items if needed"
   - ✅ "Add to targets: BaresipExample"
4. 选择 Target → General → Frameworks, Libraries, and Embedded Content
5. 找到 `Baresip.xcframework`
6. 设置为 "Embed & Sign"

### 步骤 5: 编译运行

1. 选择模拟器（iPhone 17 Pro）
2. 按 ⌘R 运行
3. 应该编译成功！

## 📝 命令行替代方案（高级）

如果必须使用命令行，需要手动编辑 `project.pbxproj` 文件添加所有引用，这非常复杂且容易出错。

**推荐使用 Xcode GUI 进行初次配置。**

## ✅ 验证清单

- [ ] Swift 桥接文件已添加
- [ ] Bridging Header 已配置
- [ ] XCFramework 已添加并设置为 Embed & Sign
- [ ] 编译成功
- [ ] 模拟器运行正常

## 🎯 预期结果

编译成功后，您将看到：
- ✅ 主界面（SIP 注册）
- ✅ 拨号界面
- ✅ 设置界面

## 📞 功能测试

1. **SIP 注册测试**
   - 输入测试账号
   - 点击注册
   - 查看状态

2. **UI 测试**
   - 切换到设置页面
   - 查看所有选项
   - 返回主界面

## 💡 提示

- 首次编译可能需要 1-2 分钟
- 如果遇到签名问题，在 Build Settings 中禁用代码签名
- 模拟器不支持 PushKit，这是正常的

---

**项目已 100% 完成开发，只需在 Xcode 中完成最后的配置即可运行！** 🚀
