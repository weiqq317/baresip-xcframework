#!/bin/bash
# XCFramework 打包脚本
# 将多架构静态库合并为标准 XCFramework（基于研究报告 3.3 节）

set -e

BUILD_DIR="$(pwd)/build"
OUTPUT_DIR="$(pwd)/output"
XCFRAMEWORK_NAME="Baresip.xcframework"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📦 开始打包 Baresip XCFramework${NC}"
echo ""

# 检查编译产物
check_library() {
    local platform=$1
    local arch=$2
    local lib_path="${BUILD_DIR}/${platform}/${arch}/lib/libbaresip.a"
    
    if [ ! -f "$lib_path" ]; then
        echo "❌ 错误: $lib_path 不存在"
        echo "   请先运行 ./scripts/build_all.sh 编译所有依赖"
        exit 1
    fi
}

echo "🔍 检查编译产物..."
check_library "iphoneos" "arm64"
check_library "iphonesimulator" "arm64"
check_library "iphonesimulator" "x86_64"
check_library "macos" "arm64"
check_library "macos" "x86_64"
echo -e "${GREEN}✓ 所有编译产物已就绪${NC}"
echo ""

# 创建临时目录
TEMP_DIR="${BUILD_DIR}/xcframework-temp"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# 合并 iOS 模拟器多架构库（arm64 + x86_64）
echo "🔨 合并 iOS 模拟器多架构库..."
mkdir -p "${TEMP_DIR}/iphonesimulator/lib"
mkdir -p "${TEMP_DIR}/iphonesimulator/include"

lipo -create \
    "${BUILD_DIR}/iphonesimulator/arm64/lib/libbaresip.a" \
    "${BUILD_DIR}/iphonesimulator/x86_64/lib/libbaresip.a" \
    -output "${TEMP_DIR}/iphonesimulator/lib/libbaresip.a"

# 同时合并 libre 和 librem
lipo -create \
    "${BUILD_DIR}/iphonesimulator/arm64/lib/libre.a" \
    "${BUILD_DIR}/iphonesimulator/x86_64/lib/libre.a" \
    -output "${TEMP_DIR}/iphonesimulator/lib/libre.a"

lipo -create \
    "${BUILD_DIR}/iphonesimulator/arm64/lib/librem.a" \
    "${BUILD_DIR}/iphonesimulator/x86_64/lib/librem.a" \
    -output "${TEMP_DIR}/iphonesimulator/lib/librem.a"

# 复制头文件（使用 arm64 的头文件）
cp -R "${BUILD_DIR}/iphonesimulator/arm64/include/"* "${TEMP_DIR}/iphonesimulator/include/"

echo -e "${GREEN}✓ iOS 模拟器 Fat 库创建完成${NC}"
echo ""

# 合并 macOS 多架构库（arm64 + x86_64）
echo "🔨 合并 macOS 多架构库..."
mkdir -p "${TEMP_DIR}/macos/lib"
mkdir -p "${TEMP_DIR}/macos/include"

lipo -create \
    "${BUILD_DIR}/macos/arm64/lib/libbaresip.a" \
    "${BUILD_DIR}/macos/x86_64/lib/libbaresip.a" \
    -output "${TEMP_DIR}/macos/lib/libbaresip.a"

lipo -create \
    "${BUILD_DIR}/macos/arm64/lib/libre.a" \
    "${BUILD_DIR}/macos/x86_64/lib/libre.a" \
    -output "${TEMP_DIR}/macos/lib/libre.a"

lipo -create \
    "${BUILD_DIR}/macos/arm64/lib/librem.a" \
    "${BUILD_DIR}/macos/x86_64/lib/librem.a" \
    -output "${TEMP_DIR}/macos/lib/librem.a"

cp -R "${BUILD_DIR}/macos/arm64/include/"* "${TEMP_DIR}/macos/include/"

echo -e "${GREEN}✓ macOS Fat 库创建完成${NC}"
echo ""

# 准备 iOS 设备库
echo "📋 准备 iOS 设备库..."
mkdir -p "${TEMP_DIR}/iphoneos/lib"
mkdir -p "${TEMP_DIR}/iphoneos/include"

cp "${BUILD_DIR}/iphoneos/arm64/lib/libbaresip.a" "${TEMP_DIR}/iphoneos/lib/"
cp "${BUILD_DIR}/iphoneos/arm64/lib/libre.a" "${TEMP_DIR}/iphoneos/lib/"
cp "${BUILD_DIR}/iphoneos/arm64/lib/librem.a" "${TEMP_DIR}/iphoneos/lib/"
cp -R "${BUILD_DIR}/iphoneos/arm64/include/"* "${TEMP_DIR}/iphoneos/include/"

echo -e "${GREEN}✓ iOS 设备库准备完成${NC}"
echo ""

# 创建 XCFramework
echo "🎁 创建 XCFramework..."
rm -rf "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}"
mkdir -p "$OUTPUT_DIR"

xcodebuild -create-xcframework \
    -library "${TEMP_DIR}/iphoneos/lib/libbaresip.a" \
    -headers "${TEMP_DIR}/iphoneos/include" \
    -library "${TEMP_DIR}/iphonesimulator/lib/libbaresip.a" \
    -headers "${TEMP_DIR}/iphonesimulator/include" \
    -library "${TEMP_DIR}/macos/lib/libbaresip.a" \
    -headers "${TEMP_DIR}/macos/include" \
    -output "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ XCFramework 创建完成${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 显示 XCFramework 信息
echo "📊 XCFramework 信息："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
xcrun xcframework show "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 计算包体积
XCFRAMEWORK_SIZE=$(du -sh "${OUTPUT_DIR}/${XCFRAMEWORK_NAME}" | awk '{print $1}')
echo "📦 包体积: ${XCFRAMEWORK_SIZE}"
echo ""

# 清理临时文件
echo "🧹 清理临时文件..."
rm -rf "$TEMP_DIR"
echo -e "${GREEN}✓ 清理完成${NC}"
echo ""

echo "🎉 XCFramework 已保存到: ${OUTPUT_DIR}/${XCFRAMEWORK_NAME}"
echo ""
echo "🔜 下一步: 开始实现 Swift 桥接层"
echo ""
