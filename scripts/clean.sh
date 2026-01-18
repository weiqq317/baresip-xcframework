#!/bin/bash
# 清理编译产物脚本

set -e

echo "🧹 清理 Baresip 编译产物..."

# 清理 build 目录
if [ -d "build" ]; then
    echo "   清理 build/ 目录..."
    rm -rf build/*
fi

# 清理 output 目录
if [ -d "output" ]; then
    echo "   清理 output/ 目录..."
    rm -rf output/*
fi

# 清理临时文件
echo "   清理临时文件..."
find . -name ".DS_Store" -delete
find . -name "*.o" -delete
find . -name "*.a" -delete

echo "✅ 清理完成"
echo ""
