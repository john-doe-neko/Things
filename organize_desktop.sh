#!/bin/bash

# ============================================
# Организация рабочего стола (а-ля MacOS Stacks)
# ============================================

# 1. Определяем путь к рабочему столу
DESKTOP_DIR="${HOME}/Desktop"
if [ ! -d "$DESKTOP_DIR" ]; then
    DESKTOP_DIR="${HOME}/Рабочий стол"
    if [ ! -d "$DESKTOP_DIR" ]; then
        echo "Did not found Desktop folder!"
        exit 1
    fi
fi

cd "$DESKTOP_DIR" || exit 1

# 2. Категории (названия папок и соответствующие расширения)
declare -A categories
categories["Images"]="jpg jpeg png gif bmp tiff svg webp ico"
categories["Documents"]="txt pdf doc docx xls xlsx ppt pptx odt ods odp rtf md tex"
categories["Archives"]="zip tar gz bz2 7z rar xz zst"
categories["Music"]="mp3 wav flac aac ogg wma m4a"
categories["Videos"]="mp4 avi mkv mov wmv flv webm m4v"
categories["MacOS apps&fonts"]="dmg"
categories["Fonts"]="otf fon ttf TTF"
categories["Libruary"]="cbz mobi f2b cbr epub"
categories["Coding"]="pas c c++ py sh"
categories["Web"]="html css js"

OTHER_DIR="Others"  # для всего остального

# 3. Создаём папки (если их нет)
for cat in "${!categories[@]}"; do
    [ -d "$cat" ] || mkdir "$cat"
done
[ -d "$OTHER_DIR" ] || mkdir "$OTHER_DIR"

# 4. Перемещаем файлы (только из корня, не заходя в подпапки)
count=0
find . -maxdepth 1 -type f -not -name '.*' -print0 | while IFS= read -r -d '' file; do
    # убираем './' в начале
    filename="${file#./}"
    
    # расширение в нижний регистр
    ext="${filename##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    moved=0
    for cat in "${!categories[@]}"; do
        if echo "${categories[$cat]}" | grep -wq "$ext_lower"; then
            # если файл уже лежит в этой папке – пропускаем
            if [ ! -e "$cat/$filename" ]; then
                mv "$filename" "$cat/"
                echo "➜ $filename → $cat/"
                ((count++))
            fi
            moved=1
            break
        fi
    done
    
    # если не нашлось – в Others
    if [ $moved -eq 0 ] && [ ! -e "$OTHER_DIR/$filename" ]; then
        mv "$filename" "$OTHER_DIR/"
        echo "➜ $filename → $OTHER_DIR/"
        ((count++))
    fi
done

# 5. Уведомление
if [ $count -gt 0 ]; then
    notify-send "🧹 Рабочий стол" "Перемещено файлов: $count" -i "user-desktop"
else
    notify-send "Your desk is clean" "Everything is already done" -i "user-desktop"
fi
