#!/bin/bash
# XCFramework 结构验证脚本

set -e

XCFRAMEWORK_PATH="./output/Baresip.xcframework"

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🔍 验证 Baresip XCFramework${NC}"
echo ""

# 检查 XCFramework 是否存在
if [ ! -d "$XCFRAMEWORK_PATH" ]; then
    echo -e "${RED}❌ 错误: XCFramework 不存在${NC}"
    echo "   路径: $XCFRAMEWORK_PATH"
    echo "   请先运行 ./scripts/create_xcframework.sh"
    exit 1
fi

echo -e "${GREEN}✓ XCFramework 存在${NC}"
echo ""

# 显示 XCFramework 信息
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 XCFramework 信息:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
xcrun xcframework show "$XCFRAMEWORK_PATH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查 Info.plist
INFO_PLIST="${XCFRAMEWORK_PATH}/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    echo -e "${GREEN}✓ Info.plist 存在${NC}"
else
    echo -e "${RED}✗ Info.plist 缺失${NC}"
    exit 1
fi

# 检查支持的平台
echo ""
echo "📱 支持的平台:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

PLATFORMS=("ios-arm64" "ios-arm64_x86_64-simulator" "macos-arm64_x86_64")
for platform in "${PLATFORMS[@]}"; do
    if [ -d "${XCFRAMEWORK_PATH}/${platform}" ]; then
        echo -e "${GREEN}✓ ${platform}${NC}"
        
        # 检查库文件
        LIB_PATH="${XCFRAMEWORK_PATH}/${platform}/libbaresip.a"
        if [ -f "$LIB_PATH" ]; then
            SIZE=$(du -h "$LIB_PATH" | awk '{print $1}')
            echo "   库文件大小: $SIZE"
        fi
    else
        echo -e "${YELLOW}⚠ ${platform} (未找到)${NC}"
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查头文件
echo "📄 头文件检查:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

HEADERS_DIR="${XCFRAMEWORK_PATH}/ios-arm64/Headers"
if [ -d "$HEADERS_DIR" ]; then
    HEADER_COUNT=$(find "$HEADERS_DIR" -name "*.h" | wc -l | xargs)
    echo -e "${GREEN}✓ 找到 ${HEADER_COUNT} 个头文件${NC}"
    
    # 列出主要头文件
    echo ""
    echo "主要头文件:"
    find "$HEADERS_DIR" -name "*.h" -maxdepth 1 | head -5 | while read file; do
        echo "   - $(basename $file)"
    done
else
    echo -e "${YELLOW}⚠ 头文件目录未找到${NC}"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 计算总体积
TOTAL_SIZE=$(du -sh "$XCFRAMEWORK_PATH" | awk '{print $1}')
echo "📦 总体积: ${TOTAL_SIZE}"
echo ""

# 验证架构
echo "🏗️  架构验证:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for platform in "${PLATFORMS[@]}"; do
    LIB_PATH="${XCFRAMEWORK_PATH}/${platform}/libbaresip.a"
    if [ -f "$LIB_PATH" ]; then
        echo ""
        echo "${platform}:"
        lipo -info "$LIB_PATH" | sed 's/^/   /'
    fi
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo -e "${GREEN}✅ XCFramework 验证完成${NC}"
echo ""
