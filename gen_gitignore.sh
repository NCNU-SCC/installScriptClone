#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
FILE=".gitignore"


# 忽略所有文件
echo "/*" > $FILE

echo "!.gitignore" >> $FILE



# 收集目錄和文件
for file in "$SCRIPT_DIR"/*; do
base_file=$(basename $file)
    if [[ -f "$file" ]]; then
        echo "Found file: $base_file"
        echo "!$base_file" >> "$FILE"
    elif [[ -d "$file" ]]; then
      if [[ -f "$base_file/$base_file.sh" ]]; then
        echo "Found file: $base_file/$base_file"
        echo "!$base_file/" >> "$FILE"  # 允許目錄
        echo "$base_file/*" >> "$FILE" # 禁止目錄下的東西
        echo "!$base_file/$base_file.sh" >> "$FILE"
      fi
    fi
done



