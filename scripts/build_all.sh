#!/bin/bash
# 一键编译所有依赖（libre + librem + baresip）

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 颜色定义
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Baresip XCFramework 一键编译${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查环境
echo "🔍 检查编译环境..."
"$SCRIPT_DIR/setup.sh"

# 编译 libre
echo ""
echo -e "${GREEN}[1/3] 编译 libre（SIP 协议栈）${NC}"
"$SCRIPT_DIR/build_libre.sh"

# 编译 librem
echo ""
echo -e "${GREEN}[2/3] 编译 librem（媒体处理库）${NC}"
"$SCRIPT_DIR/build_librem.sh"

# 编译 baresip
echo ""
echo -e "${GREEN}[3/3] 编译 baresip（核心模块）${NC}"
"$SCRIPT_DIR/build_baresip.sh"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 所有依赖编译完成${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🔜 下一步: 运行 ./scripts/create_xcframework.sh 打包 XCFramework"
echo ""
