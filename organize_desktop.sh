#!/bin/bash
#Это русская версия, я сделал уведомления на русском, тк я не знаю, сколько я еще буду большой проект дорабатывать, так что я не заморочился на этим.
#Это довольно большой именно кодовый проект, а привел он меня к еще большему кодовому проекту, так что не знаю сколько времени займен слудеющее обновление
DESKTOP_DIR="${HOME}/Desktop"
[ -d "$DESKTOP_DIR" ] || DESKTOP_DIR="${HOME}/Рабочий стол"
[ -d "$DESKTOP_DIR" ] || { echo "Рабочий стол не найден"; exit 1; }

cd "$DESKTOP_DIR" || exit 1

declare -A categories
categories["Images"]="jpg jpeg png gif bmp tiff svg webp ico"
categories["Documents"]="txt pdf doc docx xls xlsx ppt pptx odt ods odp"
categories["Archives"]="zip tar gz bz2 7z rar xz zst"
categories["Music"]="mp3 wav flac aac ogg wma m4a"
categories["Videos"]="mp4 avi mkv mov wmv flv webm m4v"
categories["Pascal"]="pas"
categories["Web"]="html css js"
categories["Notebook"]="md tex"

OTHER_DIR="Others"


declare -A need_dir
need_count=0
other_count=0


while IFS= read -r -d '' file; do
    filename="${file#./}"
    ext="${filename##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    found=0
    for cat in "${!categories[@]}"; do
        if echo "${categories[$cat]}" | grep -wq "$ext_lower"; then
            need_dir["$cat"]=1
            found=1
            break
        fi
    done
    if [ $found -eq 0 ]; then
        other_count=$((other_count + 1))
    fi
done < <(find . -maxdepth 1 -type f -not -name '.*' -print0)

for cat in "${!need_dir[@]}"; do
    [ -d "$cat" ] || mkdir "$cat"
done

if [ $other_count -gt 0 ] && [ ! -d "$OTHER_DIR" ]; then
    mkdir "$OTHER_DIR"
fi


count=0
find . -maxdepth 1 -type f -not -name '.*' -print0 | while IFS= read -r -d '' file; do
    filename="${file#./}"
    ext="${filename##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
    
    moved=0
    for cat in "${!categories[@]}"; do
        if echo "${categories[$cat]}" | grep -wq "$ext_lower"; then
            if [ -d "$cat" ] && [ ! -e "$cat/$filename" ]; then
                mv "$filename" "$cat/"
                echo "➜ $filename → $cat/"
                ((count++))
            fi
            moved=1
            break
        fi
    done
    
    if [ $moved -eq 0 ] && [ -d "$OTHER_DIR" ] && [ ! -e "$OTHER_DIR/$filename" ]; then
        mv "$filename" "$OTHER_DIR/"
        echo "➜ $filename → $OTHER_DIR/"
        ((count++))
    fi
done

echo Это русская версия, скорее всего вы запустили ее через книпки, а не через терминал, так что вы это не увидите, но если увидели, я рад!
if [ $count -gt 0 ]; then
    notify-send "Рабочий стол" "Перемещено файлов: $count" -i "user-desktop"
else
    notify-send "Рабочий стол" "Ничего не перемещено (уже порядок)" -i "user-desktop"