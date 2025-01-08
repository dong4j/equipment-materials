#!/bin/bash

# 获取当前脚本的所在目录
SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR" || exit 1

# 定义本地目录
LOCAL_DIR="public" # 脚本同级目录下的 public
TAG_DIR="$SCRIPT_DIR/../source/denyaccess"

# 上传文件到远程并覆盖
echo "正在拷贝 public 目录下的文件到 denyaccess"
rsync -azqhP --delete \
  --exclude '.DS_Store' \
  --exclude '._*' \
  --exclude '__MACOSX' \
  "$LOCAL_DIR/" "$TAG_DIR" | tee /dev/null

# 检查上传是否成功
if [ $? -eq 0 ]; then
  echo "文件拷贝成功！"
else
  echo "文件拷贝失败。"
  exit 1
fi