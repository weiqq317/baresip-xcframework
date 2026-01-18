#!/bin/bash
# baresip 核心模块多架构交叉编译脚本
# 仅启用语音通话核心模块: g711, opus, audiounit, ice, sip, dtmf

set -e

# 配置
BARESIP_VERSION="3.14.0"
BARESIP_URL="https://github.com/baresip/baresip/archive/refs/tags/v${BARESIP_VERSION}.tar.gz"
BUILD_DIR="$(pwd)/build"
SOURCE_DIR="$(pwd)/build/baresip-src"

# 核心模块（基于研究报告 2.1 节）
CORE_MODULES="g711 opus audiounit ice sip dtmf"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🔨 开始编译 baresip ${BARESIP_VERSION}${NC}"
echo ""

# 检查依赖是否已编译
if [ ! -f "${BUILD_DIR}/iphoneos/arm64/lib/libre.a" ]; then
    echo "❌ 错误: libre 尚未编译，请先运行 ./scripts/build_libre.sh"
    exit 1
fi

if [ ! -f "${BUILD_DIR}/iphoneos/arm64/lib/librem.a" ]; then
    echo "❌ 错误: librem 尚未编译，请先运行 ./scripts/build_librem.sh"
    exit 1
fi

# 下载源码
if [ ! -d "$SOURCE_DIR" ]; then
    echo "📥 下载 baresip 源码..."
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    curl -L "$BARESIP_URL" -o baresip.tar.gz
    tar -xzf baresip.tar.gz
    mv "baresip-${BARESIP_VERSION}" baresip-src
    rm baresip.tar.gz
    cd - > /dev/null
fi

# 编译函数
build_baresip() {
    local PLATFORM=$1
    local ARCH=$2
    local SDK=$3
    local MIN_VERSION=$4
    local OUTPUT_DIR="${BUILD_DIR}/${PLATFORM}/${ARCH}"
    local LIBRE_DIR="${BUILD_DIR}/${PLATFORM}/${ARCH}"
    local LIBREM_DIR="${BUILD_DIR}/${PLATFORM}/${ARCH}"
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📱 编译 baresip for ${PLATFORM} (${ARCH})${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # 获取 SDK 路径
    local SDK_PATH=$(xcrun --sdk $SDK --show-sdk-path)
    local CC=$(xcrun --sdk $SDK --find clang)
    
    # 编译参数（基于研究报告 3.2 节）
    local CFLAGS="-arch ${ARCH} -isysroot ${SDK_PATH} -m${SDK}-version-min=${MIN_VERSION} -fembed-bitcode -O3 -DNDEBUG"
    local EXTRA_CFLAGS="-fPIC -fvisibility=hidden -I${LIBRE_DIR}/include -I${LIBREM_DIR}/include"
    local EXTRA_LFLAGS="-L${LIBRE_DIR}/lib -L${LIBREM_DIR}/lib"
    
    # 苹果框架依赖
    local FRAMEWORKS="-framework CoreAudio -framework AudioToolbox -framework AVFoundation -framework Foundation"
    
    echo "🔧 编译配置："
    echo "   SDK:      $SDK_PATH"
    echo "   架构:     $ARCH"
    echo "   最低版本: $MIN_VERSION"
    echo "   libre:    $LIBRE_DIR"
    echo "   librem:   $LIBREM_DIR"
    echo "   模块:     $CORE_MODULES"
    echo "   输出目录: $OUTPUT_DIR"
    echo ""
    
    # 清理并编译
    cd "$SOURCE_DIR"
    make clean > /dev/null 2>&1 || true
    
    # 编译 baresip（静态库，仅启用核心模块）
    echo -e "${YELLOW}⚙️  编译中...${NC}"
    make CC="$CC" \
         CFLAGS="$CFLAGS $EXTRA_CFLAGS" \
         LFLAGS="$EXTRA_LFLAGS $FRAMEWORKS" \
         STATIC=1 \
         OPT_SPEED=1 \
         EXTRA_MODULES="$CORE_MODULES" \
         MOD_AUTODETECT=no \
         USE_VIDEO=no \
         -j$(sysctl -n hw.ncpu)
    
    # 安装到输出目录
    make install DESTDIR="$OUTPUT_DIR" PREFIX=""
    
    echo -e "${GREEN}✓ baresip ${PLATFORM}/${ARCH} 编译完成${NC}"
    
    cd - > /dev/null
}

# iOS 设备 (arm64)
build_baresip "iphoneos" "arm64" "iphoneos" "12.0"

# iOS 模拟器 (arm64)
build_baresip "iphonesimulator" "arm64" "iphonesimulator" "12.0"

# iOS 模拟器 (x86_64)
build_baresip "iphonesimulator" "x86_64" "iphonesimulator" "12.0"

# macOS (arm64)
build_baresip "macos" "arm64" "macosx" "10.15"

# macOS (x86_64)
build_baresip "macos" "x86_64" "macosx" "10.15"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ baresip 所有架构编译完成${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📦 输出目录："
echo "   iOS 设备:      ${BUILD_DIR}/iphoneos/arm64"
echo "   iOS 模拟器:    ${BUILD_DIR}/iphonesimulator/{arm64,x86_64}"
echo "   macOS:         ${BUILD_DIR}/macos/{arm64,x86_64}"
echo ""
echo "🔜 下一步: 运行 ./scripts/create_xcframework.sh 打包 XCFramework"
echo ""
