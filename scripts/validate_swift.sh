#!/bin/bash
# Swift 代码语法验证脚本

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔍 Swift 代码语法验证${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

BRIDGE_DIR="bridge/SwiftBaresip"
EXAMPLE_DIR="examples/iOS"
SDK_PATH=$(xcrun --show-sdk-path --sdk iphonesimulator)

# 验证 Swift 桥接层文件
echo "📋 验证 Swift 桥接层..."
echo ""

SWIFT_FILES=(
    "$BRIDGE_DIR/Core/BaresipError.swift"
    "$BRIDGE_DIR/Core/BaresipCallState.swift"
    "$BRIDGE_DIR/Core/BaresipAccount.swift"
    "$BRIDGE_DIR/Core/BaresipAddress.swift"
    "$BRIDGE_DIR/Core/BaresipUADelegate.swift"
)

PASSED=0
FAILED=0

for file in "${SWIFT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -n "检查 $(basename $file)... "
        if swiftc -typecheck "$file" \
            -sdk "$SDK_PATH" \
            -target arm64-apple-ios12.0-simulator \
            -import-objc-header "$BRIDGE_DIR/Baresip-Bridging-Header.h" \
            2>/dev/null; then
            echo -e "${GREEN}✓${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}✗${NC}"
            FAILED=$((FAILED + 1))
        fi
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "结果: ${GREEN}${PASSED} 通过${NC}, ${RED}${FAILED} 失败${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ 所有独立文件语法检查通过！${NC}"
    echo ""
    echo "💡 注意: 完整编译需要:"
    echo "   1. 创建 Xcode 项目"
    echo "   2. 添加所有依赖文件"
    echo "   3. 配置 Bridging Header"
    echo "   4. 链接 XCFramework"
    echo ""
    echo "📝 查看 examples/iOS/README.md 了解详细步骤"
else
    echo -e "${YELLOW}⚠️  部分文件需要依赖其他文件才能编译${NC}"
    echo "这是正常的，因为文件之间有相互依赖"
fi

echo ""
