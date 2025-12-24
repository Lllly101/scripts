#!/bin/bash

# 获取当前目录名
dirname=$(basename "$(pwd)")

# 构造压缩包文件名
tarpackage="${dirname}.tar.gz"

echo "正在压缩当前目录: $(pwd)"
echo "压缩包名称: ${tarpackage}"
echo "排除内容: .git, .DS_Store, package.sh, ${tarpackage}"

#---------------------------------------------------------
#核心修复：
#1. --exclude 必须放在 -czf 之前（最佳实践，兼容性更好）
#2. 显式排除 .git 目录
#3. 显式排除 .DS_Store (macOS 常见垃圾文件)
#4. 显式排除输出文件本身 (防止“file changed as we read it”错误)
#---------------------------------------------------------
tar --exclude='.git'
--exclude='.DS_Store'
--exclude='package.sh'
--exclude="${tarpackage}"
-czf "${tarpackage}" .

# 检查退出码
tar_exit_code=$?

# 0 = 成功, 1 = 警告 (如文件在读取时发生变化)
if [ $tar_exit_code -eq 0 ] || [ $tar_exit_code -eq 1 ]; then
echo "----------------------------------------"
echo "✅ 压缩成功: ${tarpackage}"

# 获取文件大小 (兼容 Mac/Linux)
filesize=$(du -h "${tarpackage}" | awk '{print $1}')
echo "📦 文件大小: ${filesize}"

# 计算校验和
echo -n "🔑 MD5: "
if command -v md5sum >/dev/null 2>&1; then
    md5sum "${tarpackage}" | awk '{print $1}'
elif command -v md5 >/dev/null 2>&1; then
    md5 -q "${tarpackage}"
else
    echo "(未找到 md5 命令)"
fi
else
echo "❌ 压缩失败 (退出码: $tar_exit_code)" >&2
exit 1
fi
