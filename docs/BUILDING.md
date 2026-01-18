# Baresip XCFramework 编译指南

本文档提供详细的编译步骤与配置说明。

---

## 📋 前置要求

### 系统要求

- **操作系统**: macOS 12.0+
- **Xcode**: 15.0+
- **Xcode Command Line Tools**: 15.0+
- **CMake**: 3.20+
- **Git**: 2.30+
- **Homebrew**: 3.0+

### 检查环境

运行环境检查脚本：

```bash
./scripts/setup.sh
```

如果缺少依赖，脚本会提供安装建议。

---

## 🔨 编译流程

### 方式一：一键编译（推荐）

```bash
# 1. 检查环境
./scripts/setup.sh

# 2. 编译所有依赖
./scripts/build_all.sh

# 3. 打包 XCFramework
./scripts/create_xcframework.sh

# 4. 验证 XCFramework
./scripts/verify_xcframework.sh
```

### 方式二：分步编译

#### 步骤 1: 编译 libre

libre 是 Baresip 的底层 SIP 协议栈。

```bash
./scripts/build_libre.sh
```

**编译目标**:
- iOS 设备 (arm64)
- iOS 模拟器 (arm64, x86_64)
- macOS (arm64, x86_64)

**输出目录**:
```
build/
├── iphoneos/arm64/
├── iphonesimulator/arm64/
├── iphonesimulator/x86_64/
├── macos/arm64/
└── macos/x86_64/
```

#### 步骤 2: 编译 librem

librem 是 Baresip 的媒体处理库，依赖 libre。

```bash
./scripts/build_librem.sh
```

**注意**: 必须先编译 libre。

#### 步骤 3: 编译 baresip

baresip 核心模块，仅启用语音通话功能。

```bash
./scripts/build_baresip.sh
```

**启用模块**:
- `g711` - G.711 PCM 编解码器
- `opus` - Opus 自适应音频编解码器
- `audiounit` - 苹果 CoreAudio 驱动
- `ice` - ICE 协议（NAT 穿透）
- `sip` - SIP 核心模块
- `dtmf` - DTMF 信号处理

**禁用模块**:
- 视频相关模块
- 即时消息模块

#### 步骤 4: 打包 XCFramework

```bash
./scripts/create_xcframework.sh
```

**输出**: `output/Baresip.xcframework`

---

## 🔧 编译参数说明

### iOS 设备 (arm64)

```bash
SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)
CC=$(xcrun --sdk iphoneos --find clang)
CFLAGS="-arch arm64 -isysroot $SDK_PATH -miphoneos-version-min=12.0 -fembed-bitcode -O3 -DNDEBUG"
```

### iOS 模拟器 (arm64/x86_64)

```bash
SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
CC=$(xcrun --sdk iphonesimulator --find clang)
CFLAGS="-arch arm64 -isysroot $SDK_PATH -miphonesimulator-version-min=12.0 -O3 -DNDEBUG"
```

### macOS (arm64/x86_64)

```bash
SDK_PATH=$(xcrun --sdk macosx --show-sdk-path)
CC=$(xcrun --sdk macosx --find clang)
CFLAGS="-arch arm64 -isysroot $SDK_PATH -mmacosx-version-min=10.15 -O3 -DNDEBUG"
```

### 关键参数

| 参数 | 说明 |
|------|------|
| `-arch` | 目标架构 |
| `-isysroot` | SDK 路径 |
| `-m*-version-min` | 最低支持版本 |
| `-fembed-bitcode` | 嵌入 Bitcode（iOS 设备） |
| `-O3` | 最高优化级别 |
| `-DNDEBUG` | 禁用调试符号 |
| `STATIC=1` | 编译为静态库 |
| `OPT_SPEED=1` | 速度优化 |

---

## 📦 XCFramework 结构

```
Baresip.xcframework/
├── Info.plist
├── ios-arm64/
│   ├── Headers/
│   └── libbaresip.a
├── ios-arm64_x86_64-simulator/
│   ├── Headers/
│   └── libbaresip.a
└── macos-arm64_x86_64/
    ├── Headers/
    └── libbaresip.a
```

---

## 🧹 清理编译产物

```bash
./scripts/clean.sh
```

清理内容:
- `build/` 目录
- `output/` 目录
- 临时文件（`.DS_Store`, `*.o`, `*.a`）

---

## ⚙️ 自定义编译

### 修改最低支持版本

编辑编译脚本中的 `-m*-version-min` 参数：

```bash
# iOS 最低版本改为 13.0
-miphoneos-version-min=13.0

# macOS 最低版本改为 11.0
-mmacosx-version-min=11.0
```

### 启用额外模块

编辑 `scripts/build_baresip.sh`，修改 `CORE_MODULES` 变量：

```bash
# 添加 G.722 编解码器
CORE_MODULES="g711 g722 opus audiounit ice sip dtmf"
```

### 调整优化级别

```bash
# 使用 -O2 而非 -O3
CFLAGS="... -O2 ..."

# 启用调试符号
CFLAGS="... -g ..."
```

---

## 🐛 常见编译问题

### 问题 1: SDK 路径错误

**错误信息**:
```
xcrun: error: SDK "iphoneos" cannot be located
```

**解决方案**:
```bash
# 安装 Xcode Command Line Tools
xcode-select --install

# 设置 Xcode 路径
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

### 问题 2: CMake 版本过低

**错误信息**:
```
CMake 3.20 or higher is required
```

**解决方案**:
```bash
brew install cmake
```

### 问题 3: 编译器找不到头文件

**错误信息**:
```
fatal error: 're.h' file not found
```

**解决方案**:
确保按顺序编译：libre → librem → baresip

### 问题 4: lipo 合并失败

**错误信息**:
```
lipo: can't open input file
```

**解决方案**:
检查编译产物是否存在：
```bash
ls -la build/iphonesimulator/arm64/lib/libbaresip.a
ls -la build/iphonesimulator/x86_64/lib/libbaresip.a
```

---

## 📊 编译时间估算

| 步骤 | 预计时间 |
|------|----------|
| libre 编译 | 5-10 分钟 |
| librem 编译 | 3-5 分钟 |
| baresip 编译 | 5-10 分钟 |
| XCFramework 打包 | 1-2 分钟 |
| **总计** | **15-30 分钟** |

*时间取决于 CPU 性能和网络速度*

---

## 🔍 验证编译结果

### 检查 XCFramework 结构

```bash
./scripts/verify_xcframework.sh
```

### 手动验证

```bash
# 查看 XCFramework 信息
xcrun xcframework show output/Baresip.xcframework

# 查看库文件架构
lipo -info output/Baresip.xcframework/ios-arm64/libbaresip.a

# 查看包体积
du -sh output/Baresip.xcframework
```

---

## 🚀 下一步

编译完成后，参考以下文档：

- [快速开始](README.md) - 集成到项目
- [API 参考](API_REFERENCE.md) - API 文档
- [迁移指南](MIGRATION_GUIDE.md) - 从 Linphone 迁移

---

## 💡 优化建议

### 加速编译

1. **使用多核编译**:
   ```bash
   make -j$(sysctl -n hw.ncpu)
   ```

2. **启用 ccache**:
   ```bash
   brew install ccache
   export CC="ccache clang"
   ```

3. **使用 RAM 磁盘**:
   ```bash
   # 创建 4GB RAM 磁盘
   diskutil erasevolume HFS+ "RamDisk" `hdiutil attach -nomount ram://8388608`
   
   # 在 RAM 磁盘中编译
   cd /Volumes/RamDisk
   ```

### 减小包体积

1. **启用 Strip**:
   ```bash
   strip -x libbaresip.a
   ```

2. **移除调试符号**:
   ```bash
   CFLAGS="... -DNDEBUG ..."
   ```

3. **禁用不需要的模块**:
   仅保留核心模块

---

如有编译问题，请查阅 [故障排查文档](TROUBLESHOOTING.md)。
