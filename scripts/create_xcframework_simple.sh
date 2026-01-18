#!/bin/bash
# 简化版 XCFramework 创建脚本
# 使用已编译的 libre 静态库

set -e

BUILD_DIR="$(pwd)/build"
OUTPUT_DIR="$(pwd)/output"
XCFRAMEWORK_NAME="Baresip.xcframework"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📦 创建 Baresip XCFramework${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# 删除旧的 XCFramework
if [ -d "$OUTPUT_DIR/$XCFRAMEWORK_NAME" ]; then
    echo "🗑️  删除旧的 XCFramework..."
    rm -rf "$OUTPUT_DIR/$XCFRAMEWORK_NAME"
fi

# 合并 iOS 模拟器架构 (arm64 + x86_64)
echo "🔨 合并 iOS 模拟器架构..."
mkdir -p "$BUILD_DIR/iphonesimulator-universal/lib"
lipo -create \
    "$BUILD_DIR/iphonesimulator/arm64/lib/libre.a" \
    "$BUILD_DIR/iphonesimulator/x86_64/lib/libre.a" \
    -output "$BUILD_DIR/iphonesimulator-universal/lib/libre.a"

# 合并 macOS 架构 (arm64 + x86_64)
echo "🔨 合并 macOS 架构..."
mkdir -p "$BUILD_DIR/macos-universal/lib"
lipo -create \
    "$BUILD_DIR/macos/arm64/lib/libre.a" \
    "$BUILD_DIR/macos/x86_64/lib/libre.a" \
    -output "$BUILD_DIR/macos-universal/lib/libre.a"

# 复制头文件
echo "📋 复制头文件..."
cp -R "$BUILD_DIR/iphoneos/arm64/include" "$BUILD_DIR/iphonesimulator-universal/"
cp -R "$BUILD_DIR/macos/arm64/include" "$BUILD_DIR/macos-universal/"

# 创建 XCFramework
echo "📦 创建 XCFramework..."
xcodebuild -create-xcframework \
    -library "$BUILD_DIR/iphoneos/arm64/lib/libre.a" \
    -headers "$BUILD_DIR/iphoneos/arm64/include" \
    -library "$BUILD_DIR/iphonesimulator-universal/lib/libre.a" \
    -headers "$BUILD_DIR/iphonesimulator-universal/include" \
    -library "$BUILD_DIR/macos-universal/lib/libre.a" \
    -headers "$BUILD_DIR/macos-universal/include" \
    -output "$OUTPUT_DIR/$XCFRAMEWORK_NAME"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ XCFramework 创建完成${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📦 输出位置: $OUTPUT_DIR/$XCFRAMEWORK_NAME"
echo ""
echo "🔍 验证 XCFramework:"
echo "   ./scripts/verify_xcframework.sh"
echo ""
