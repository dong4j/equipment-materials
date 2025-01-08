#!/bin/bash

# 获取当前脚本的所在目录
SCRIPT_DIR=$(dirname "$(realpath "$0")")
cd "$SCRIPT_DIR" || exit 1

# 定义原始图片目录和webp目录
ORIGINAL_DIR="original"
WEBP_DIR="webp"

# 确保webp目录存在
mkdir -p "$WEBP_DIR"

# 将图片转换为 webp
webp() {
  ffmpeg -i "$1" -c:v libwebp -q:v 65 "$2" > /dev/null 2>&1
  echo "convert" "$1" 'to' "$2"
}

# 转换并上传
webpp() {
  local input="$1"
  local output="$2"

  # 如果没有提供第二个参数，使用默认输出文件名
  if [ -z "$output" ]; then
    output="${input%.*}.webp"
  fi

  # 调用 webp 函数进行转换
  webp "$input" "$output"

  # 使用 picgo 上传生成的 .webp 文件
  local upload_output=$(picgo upload "$output")
  echo "upload" "$output"

  # 提取上传返回的 URL
  local url=$(echo "$upload_output" | sed -n 's/.*\(https:\/\/.*\)/\1/p')

  # 如果 URL 不为空，复制到剪贴板
  if [[ -n $url ]]; then
    echo "$url" | pbcopy
    echo "URL has been copied to clipboard"
  else
    echo "Error: No URL found in the upload output"
  fi
}

# 遍历原始图片目录中的每个文件
for original_file in "$ORIGINAL_DIR"/*; do
  # 获取文件名（不包含路径）
  filename=$(basename "$original_file")
  # 移除文件扩展名，获取不带扩展名的文件名
  filename_without_extension="${filename%.*}"
  
  # 检查对应的webp文件是否存在
  webp_file="$WEBP_DIR/${filename_without_extension}.webp"
  if [ ! -f "$webp_file" ]; then
    # 如果webp文件不存在，则进行转换
    echo "转换 $original_file 到 webp..."
    
    webpp "$original_file" "$webp_file"
    
    # 检查转换是否成功
    if [ -f "$webp_file" ]; then
      echo "转换成功: $webp_file"
    else
      echo "转换失败: $webp_file"
    fi
  else
    echo "文件已存在，跳过转换: $webp_file"
  fi
done


echo "脚本执行完成。"
