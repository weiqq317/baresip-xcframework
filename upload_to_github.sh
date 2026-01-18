#!/bin/bash
# GitHub 仓库创建和代码上传脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🚀 Baresip XCFramework - GitHub 上传${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查是否在正确的目录
if [ ! -f "README.md" ] || [ ! -d ".git" ]; then
    echo -e "${RED}❌ 错误: 请在项目根目录运行此脚本${NC}"
    exit 1
fi

# 检查 git 状态
echo -e "${YELLOW}📋 检查 Git 状态...${NC}"
git status

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}请按照以下步骤操作:${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo "步骤 1: 在 GitHub 创建新仓库"
echo "----------------------------------------"
echo "1. 访问: https://github.com/new"
echo "2. 仓库名称: baresip-xcframework"
echo "3. 描述: Lightweight VoIP XCFramework for iOS/macOS with 100% Linphone API compatibility"
echo "4. 可见性: Public 或 Private（根据需求）"
echo "5. ❌ 不要勾选 'Initialize this repository with a README'"
echo "6. 点击 'Create repository'"
echo ""

read -p "按 Enter 继续到步骤 2..."
echo ""

echo "步骤 2: 获取您的 GitHub 用户名"
echo "----------------------------------------"
read -p "请输入您的 GitHub 用户名: " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}❌ 用户名不能为空${NC}"
    exit 1
fi

echo ""
echo "步骤 3: 添加远程仓库"
echo "----------------------------------------"

# 检查是否已有 origin
if git remote | grep -q "^origin$"; then
    echo -e "${YELLOW}⚠️  检测到已存在的 origin，将先删除...${NC}"
    git remote remove origin
fi

# 添加新的 origin
REPO_URL="https://github.com/${GITHUB_USERNAME}/baresip-xcframework.git"
echo "添加远程仓库: $REPO_URL"
git remote add origin "$REPO_URL"

echo -e "${GREEN}✓ 远程仓库已添加${NC}"
echo ""

echo "步骤 4: 推送代码到 GitHub"
echo "----------------------------------------"

# 重命名分支为 main
echo "重命名分支为 main..."
git branch -M main

echo ""
echo "准备推送代码..."
echo "仓库: $REPO_URL"
echo "分支: main"
echo ""

read -p "确认推送? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo -e "${YELLOW}已取消推送${NC}"
    exit 0
fi

echo ""
echo "正在推送代码..."
git push -u origin main

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ 代码已成功上传到 GitHub!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "🔗 仓库地址: https://github.com/${GITHUB_USERNAME}/baresip-xcframework"
echo ""
echo "📝 建议的后续步骤:"
echo "1. 访问仓库页面验证代码已上传"
echo "2. 添加 Topics: voip, sip, ios, macos, xcframework, swift"
echo "3. 创建 Release 并附加 XCFramework"
echo "4. 更新仓库描述和 README"
echo ""
