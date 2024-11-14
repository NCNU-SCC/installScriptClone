#!/bin/bash

# 該腳本用於執行命令的同時紀錄命令
# 用法: 在/path/to/XX 執行 "doEc 命令"，會生成文件 /path/to/XX/XX 紀錄命令

logfile="$PWD/$(basename "$PWD")"

echo "$@" >> "$logfile"

"$@"

