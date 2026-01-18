#!/bin/bash
# 创建 Baresip iOS 示例应用的 Xcode 项目

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📱 创建 Baresip iOS 示例 Xcode 项目${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

PROJECT_DIR="$(pwd)/examples/iOS"
PROJECT_NAME="BaresipExample"
BUNDLE_ID="com.baresip.example"

cd "$PROJECT_DIR"

# 检查是否已有 Xcode 项目
if [ -d "${PROJECT_NAME}.xcodeproj" ]; then
    echo -e "${YELLOW}⚠️  检测到已存在的 Xcode 项目${NC}"
    read -p "是否删除并重新创建? (y/n): " CONFIRM
    if [ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ]; then
        rm -rf "${PROJECT_NAME}.xcodeproj"
        echo -e "${GREEN}✓ 已删除旧项目${NC}"
    else
        echo "已取消"
        exit 0
    fi
fi

echo "📝 使用 xcodegen 创建项目..."
echo ""

# 检查 xcodegen 是否安装
if ! command -v xcodegen &> /dev/null; then
    echo -e "${YELLOW}⚠️  xcodegen 未安装${NC}"
    echo "正在安装 xcodegen..."
    brew install xcodegen
fi

# 创建 project.yml 配置文件
cat > project.yml << 'EOF'
name: BaresipExample
options:
  bundleIdPrefix: com.baresip
  deploymentTarget:
    iOS: "12.0"
  
targets:
  BaresipExample:
    type: application
    platform: iOS
    sources:
      - path: .
        excludes:
          - "*.md"
          - "*.plist"
          - "project.yml"
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.baresip.example
        SWIFT_VERSION: "5.0"
        INFOPLIST_FILE: Info.plist
        CODE_SIGN_ENTITLEMENTS: Entitlements.plist
        SWIFT_OBJC_BRIDGING_HEADER: "../../bridge/SwiftBaresip/Baresip-Bridging-Header.h"
        FRAMEWORK_SEARCH_PATHS:
          - "$(inherited)"
          - "$(PROJECT_DIR)/../../output"
        HEADER_SEARCH_PATHS:
          - "$(inherited)"
          - "$(PROJECT_DIR)/../../output/Baresip.xcframework/ios-arm64/Headers"
      configs:
        Debug:
          SWIFT_OPTIMIZATION_LEVEL: "-Onone"
        Release:
          SWIFT_OPTIMIZATION_LEVEL: "-O"
    dependencies:
      - framework: ../../output/Baresip.xcframework
        embed: true
    scheme:
      testTargets: []
      gatherCoverageData: false
EOF

# 生成 Xcode 项目
echo "🔨 生成 Xcode 项目..."
xcodegen generate

if [ -d "${PROJECT_NAME}.xcodeproj" ]; then
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Xcode 项目创建成功！${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "📂 项目位置: ${PROJECT_DIR}/${PROJECT_NAME}.xcodeproj"
    echo ""
    echo "🚀 下一步："
    echo "1. 打开项目: open ${PROJECT_NAME}.xcodeproj"
    echo "2. 添加 Swift 桥接文件到项目"
    echo "3. 配置签名和证书"
    echo "4. 选择真实设备或模拟器"
    echo "5. 编译运行 (⌘R)"
    echo ""
else
    echo -e "${RED}❌ 项目创建失败${NC}"
    exit 1
fi
