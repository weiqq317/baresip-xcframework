#!/bin/bash
# Baresip XCFramework 环境依赖检查与安装脚本
# 基于研究报告第 3.1 节环境依赖要求

set -e

echo "🔍 检查 Baresip XCFramework 构建环境依赖..."

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查函数
check_command() {
    local cmd=$1
    local name=$2
    local min_version=$3
    
    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n 1)
        echo -e "${GREEN}✓${NC} $name: $version"
        return 0
    else
        echo -e "${RED}✗${NC} $name 未安装 (需要版本 $min_version+)"
        return 1
    fi
}

# 检查 Xcode
check_xcode() {
    if command -v xcodebuild &> /dev/null; then
        local version=$(xcodebuild -version | head -n 1 | awk '{print $2}')
        local major=$(echo $version | cut -d. -f1)
        if [ "$major" -ge 15 ]; then
            echo -e "${GREEN}✓${NC} Xcode: $version"
            return 0
        else
            echo -e "${YELLOW}⚠${NC} Xcode 版本过低: $version (需要 15.0+)"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} Xcode 未安装 (需要 15.0+)"
        return 1
    fi
}

# 检查 Xcode Command Line Tools
check_xcode_tools() {
    if xcode-select -p &> /dev/null; then
        echo -e "${GREEN}✓${NC} Xcode Command Line Tools: $(xcode-select -p)"
        return 0
    else
        echo -e "${RED}✗${NC} Xcode Command Line Tools 未安装"
        return 1
    fi
}

# 检查 CMake
check_cmake() {
    if command -v cmake &> /dev/null; then
        local version=$(cmake --version | head -n 1 | awk '{print $3}')
        local major=$(echo $version | cut -d. -f1)
        local minor=$(echo $version | cut -d. -f2)
        if [ "$major" -ge 3 ] && [ "$minor" -ge 20 ]; then
            echo -e "${GREEN}✓${NC} CMake: $version"
            return 0
        else
            echo -e "${YELLOW}⚠${NC} CMake 版本过低: $version (需要 3.20+)"
            return 1
        fi
    else
        echo -e "${RED}✗${NC} CMake 未安装 (需要 3.20+)"
        return 1
    fi
}

# 主检查流程
MISSING_DEPS=0

echo ""
echo "📋 核心依赖检查："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

check_xcode || MISSING_DEPS=$((MISSING_DEPS + 1))
check_xcode_tools || MISSING_DEPS=$((MISSING_DEPS + 1))
check_cmake || MISSING_DEPS=$((MISSING_DEPS + 1))
check_command git "Git" "2.30" || MISSING_DEPS=$((MISSING_DEPS + 1))
check_command brew "Homebrew" "3.0" || MISSING_DEPS=$((MISSING_DEPS + 1))

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 安装缺失依赖
if [ $MISSING_DEPS -gt 0 ]; then
    echo -e "${YELLOW}⚠ 发现 $MISSING_DEPS 个缺失依赖${NC}"
    echo ""
    echo "🔧 自动安装建议："
    echo ""
    
    if ! command -v brew &> /dev/null; then
        echo "1. 安装 Homebrew:"
        echo '   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        echo ""
    fi
    
    if ! command -v cmake &> /dev/null || ! check_cmake &> /dev/null; then
        echo "2. 安装 CMake:"
        echo "   brew install cmake"
        echo ""
    fi
    
    if ! command -v git &> /dev/null; then
        echo "3. 安装 Git:"
        echo "   brew install git"
        echo ""
    fi
    
    if ! check_xcode &> /dev/null; then
        echo "4. 安装 Xcode:"
        echo "   从 App Store 下载 Xcode 15.0+"
        echo ""
    fi
    
    if ! check_xcode_tools &> /dev/null; then
        echo "5. 安装 Xcode Command Line Tools:"
        echo "   xcode-select --install"
        echo ""
    fi
    
    echo -e "${RED}❌ 环境检查失败，请安装缺失依赖后重新运行${NC}"
    exit 1
else
    echo -e "${GREEN}✅ 所有依赖已满足，可以开始编译 Baresip XCFramework${NC}"
    echo ""
    echo "📦 下一步："
    echo "   运行 ./scripts/build_all.sh 开始编译"
    echo ""
fi

# 检查 SDK 路径
echo "📱 SDK 路径检查："
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "iOS SDK:           $(xcrun --sdk iphoneos --show-sdk-path)"
echo "iOS Simulator SDK: $(xcrun --sdk iphonesimulator --show-sdk-path)"
echo "macOS SDK:         $(xcrun --sdk macosx --show-sdk-path)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exit 0
