#!/bin/bash
# 使用 swift package 创建 iOS 示例项目

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📱 准备 Baresip iOS 示例项目${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PROJECT_DIR="$(pwd)/examples/iOS"
BRIDGE_DIR="$(pwd)/bridge/SwiftBaresip"

cd "$PROJECT_DIR"

echo "📋 项目文件检查..."
echo ""

# 检查必要文件
FILES=(
    "AppDelegate.swift"
    "SceneDelegate.swift"
    "ContentView.swift"
    "CallView.swift"
    "SettingsView.swift"
    "Info.plist"
    "Entitlements.plist"
)

MISSING_FILES=0
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file (缺失)"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

echo ""

if [ $MISSING_FILES -gt 0 ]; then
    echo -e "${RED}❌ 缺少 $MISSING_FILES 个文件${NC}"
    exit 1
fi

# 检查 Swift 桥接文件
echo "📋 Swift 桥接层检查..."
echo ""

BRIDGE_FILES=(
    "Core/BaresipUA.swift"
    "Core/BaresipCall.swift"
    "Core/BaresipAccount.swift"
    "Core/BaresipAddress.swift"
    "Core/BaresipCallState.swift"
    "Core/BaresipError.swift"
    "Core/BaresipUADelegate.swift"
    "CallKit/CallKitManager.swift"
    "PushKit/PushKitManager.swift"
    "Audio/AudioSessionManager.swift"
    "Baresip-Bridging-Header.h"
)

MISSING_BRIDGE=0
for file in "${BRIDGE_FILES[@]}"; do
    if [ -f "$BRIDGE_DIR/$file" ]; then
        echo -e "${GREEN}✓${NC} $file"
    else
        echo -e "${RED}✗${NC} $file (缺失)"
        MISSING_BRIDGE=$((MISSING_BRIDGE + 1))
    fi
done

echo ""

if [ $MISSING_BRIDGE -gt 0 ]; then
    echo -e "${RED}❌ 缺少 $MISSING_BRIDGE 个桥接文件${NC}"
    exit 1
fi

# 检查 XCFramework
echo "📦 XCFramework 检查..."
echo ""

XCFRAMEWORK_PATH="$(pwd)/../../output/Baresip.xcframework"
if [ -d "$XCFRAMEWORK_PATH" ]; then
    echo -e "${GREEN}✓${NC} Baresip.xcframework 存在"
    
    # 显示 XCFramework 信息
    echo ""
    echo "📊 XCFramework 详情:"
    find "$XCFRAMEWORK_PATH" -name "*.a" -exec ls -lh {} \; | while read line; do
        echo "  $line"
    done
else
    echo -e "${RED}✗${NC} Baresip.xcframework 不存在"
    echo ""
    echo "请先编译 XCFramework:"
    echo "  cd $(pwd)/../.."
    echo "  ./scripts/create_xcframework_simple.sh"
    exit 1
fi

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 所有文件检查通过！${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🚀 创建 Xcode 项目的步骤："
echo ""
echo "1. 打开 Xcode"
echo "2. File -> New -> Project"
echo "3. 选择 iOS -> App"
echo "4. 填写信息:"
echo "   - Product Name: BaresipExample"
echo "   - Organization Identifier: com.baresip"
echo "   - Interface: SwiftUI"
echo "   - Language: Swift"
echo "5. 保存到: $PROJECT_DIR"
echo ""
echo "6. 添加文件到项目:"
echo "   - 拖入所有 .swift 文件"
echo "   - 替换 Info.plist 和 Entitlements.plist"
echo ""
echo "7. 添加 Swift 桥接层:"
echo "   - 拖入 $BRIDGE_DIR 中的所有文件"
echo ""
echo "8. 添加 XCFramework:"
echo "   - 拖入 $XCFRAMEWORK_PATH"
echo "   - 在 Target -> General -> Frameworks 中设置为 'Embed & Sign'"
echo ""
echo "9. 配置 Build Settings:"
echo "   - Bridging Header: 设置为桥接头文件路径"
echo "   - iOS Deployment Target: 12.0"
echo ""
echo "10. 编译运行!"
echo ""
echo "💡 提示: 查看 README.md 获取详细说明"
echo ""
