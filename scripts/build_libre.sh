#!/bin/bash
# libre 多架构交叉编译脚本
# libre 是 Baresip 的底层 SIP 协议栈，负责 SIP 信令处理、STUN/TURN/ICE 穿透与异步 IO

set -e

# 配置
LIBRE_VERSION="3.14.0"
LIBRE_URL="https://github.com/baresip/re/archive/refs/tags/v${LIBRE_VERSION}.tar.gz"
BUILD_DIR="$(pwd)/build"
SOURCE_DIR="$(pwd)/build/libre-src"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔨 开始编译 libre ${LIBRE_VERSION}${NC}"
echo ""

# 下载源码
if [ ! -d "$SOURCE_DIR" ]; then
    echo "📥 下载 libre 源码..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    curl -L "$LIBRE_URL" -o libre.tar.gz
    tar -xzf libre.tar.gz
    mv "re-${LIBRE_VERSION}" libre-src
    rm libre.tar.gz
    cd - > /dev/null
fi

# 编译函数
build_libre() {
    local PLATFORM=$1
    local ARCH=$2
    local SDK=$3
    local MIN_VERSION=$4
    local OUTPUT_DIR="${BUILD_DIR}/${PLATFORM}/${ARCH}"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📱 编译 libre for ${PLATFORM} (${ARCH})${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 获取 SDK 路径
    local SDK_PATH=$(xcrun --sdk $SDK --show-sdk-path)
    local CC=$(xcrun --sdk $SDK --find clang)
    local CXX=$(xcrun --sdk $SDK --find clang++)
    
    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"
    
    # 清理之前的构建
    cd "$SOURCE_DIR"
    rm -rf build
    
    echo "🔧 编译配置："
    echo "   SDK:      $SDK_PATH"
    echo "   架构:     $ARCH"
    echo "   最低版本: $MIN_VERSION"
    echo "   输出目录: $OUTPUT_DIR"
    echo ""
    
    # CMake 配置参数
    local CMAKE_ARGS=(
        -DCMAKE_BUILD_TYPE=Release
        -DBUILD_SHARED_LIBS=OFF
        -DCMAKE_C_COMPILER="$CC"
        -DCMAKE_CXX_COMPILER="$CXX"
        -DCMAKE_OSX_SYSROOT="$SDK_PATH"
        -DCMAKE_OSX_ARCHITECTURES="$ARCH"
        -DCMAKE_C_FLAGS="-O3 -DNDEBUG -fPIC"
        -DCMAKE_INSTALL_PREFIX="$OUTPUT_DIR"
        -DCMAKE_OSX_DEPLOYMENT_TARGET="$MIN_VERSION"
        -DUSE_OPENSSL=OFF
        -DBUILD_TESTING=OFF
    )
    
    # 根据平台设置系统名称
    if [[ "$SDK" == "iphoneos" || "$SDK" == "iphonesimulator" ]]; then
        # 设置为 iOS 以便 CMake 正确识别平台
        CMAKE_ARGS+=(-DCMAKE_SYSTEM_NAME=iOS)
    fi
    
    # 配置 CMake
    echo "⚙️  配置 CMake..."
    cmake -B build "${CMAKE_ARGS[@]}"
    
    # 编译
    echo "🔨 编译中..."
    cmake --build build --parallel $(sysctl -n hw.ncpu)
    
    # 安装到输出目录
    echo "📦 安装到输出目录..."
    cmake --install build
    
    echo -e "${GREEN}✓ libre ${PLATFORM}/${ARCH} 编译完成${NC}"
    
    cd - > /dev/null
}

# iOS 设备 (arm64)
build_libre "iphoneos" "arm64" "iphoneos" "12.0"

# iOS 模拟器 (arm64)
build_libre "iphonesimulator" "arm64" "iphonesimulator" "12.0"

# iOS 模拟器 (x86_64)
build_libre "iphonesimulator" "x86_64" "iphonesimulator" "12.0"

# macOS (arm64)
build_libre "macos" "arm64" "macosx" "10.15"

# macOS (x86_64)
build_libre "macos" "x86_64" "macosx" "10.15"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ libre 所有架构编译完成${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📦 输出目录："
echo "   iOS 设备:      ${BUILD_DIR}/iphoneos/arm64"
echo "   iOS 模拟器:    ${BUILD_DIR}/iphonesimulator/{arm64,x86_64}"
echo "   macOS:         ${BUILD_DIR}/macos/{arm64,x86_64}"
echo ""
echo "🔜 下一步: 运行 ./scripts/build_librem.sh 编译 librem"
echo ""
