#!/bin/bash

# Цвета для вывода
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RED="\e[31m"
RESET="\e[0m"

# Функция для отображения ошибок и выхода
show_error() {
    echo -e "${RED}Ошибка: $1${RESET}" >&2
    exit 1
}

# Функции установки для каждого дистрибутива
install_debian() {
    echo -e "${GREEN}Установка для Debian/Ubuntu...${RESET}"
    sudo apt-get update && sudo apt-get upgrade -y || show_error "Не удалось обновить системные пакеты."
    sudo apt-get install python3 python3-pip python3-venv git -y || show_error "Не удалось установить зависимости."
}

install_arch() {
    echo -e "${GREEN}Установка для Arch Linux...${RESET}"
    sudo pacman -Syu --noconfirm || show_error "Не удалось обновить системные пакеты."
    sudo pacman -S python python-pip git --noconfirm || show_error "Не удалось установить зависимости."
}

install_fedora() {
    echo -e "${GREEN}Установка для Fedora...${RESET}"
    sudo dnf check-update && sudo dnf upgrade -y || show_error "Не удалось обновить системные пакеты."
    sudo dnf install python3 python3-pip git -y || show_error "Не удалось установить зависимости."
}

# Основная логика установки
main_install() {
    clear
    echo -e "${BLUE}+================================================+${RESET}"
    echo -e "${BLUE}|   Скрипт установки инструмента Realme OTA    |${RESET}"
    echo -e "${BLUE}+================================================+${RESET}"
    echo ""

    # --- ИСПРАВЛЕНИЕ 1: Цикл для выбора дистрибутива ---
    while true; do
        echo -e "${YELLOW}Выберите ваш дистрибутив:${RESET}"
        echo "1) Debian / Ubuntu"
        echo "2) Arch Linux"
        echo "3) Fedora"
        read -p "Введите ваш выбор (1-3): " choice

        case $choice in
            1) install_debian; break ;;
            2) install_arch; break ;;
            3) install_fedora; break ;;
            *) echo -e "${RED}Неверный выбор. Пожалуйста, введите 1, 2 или 3.${RESET}" ;;
        esac
    done

    # --- ИСПРАВЛЕНИЕ 2: Проверка существования каталога ---
    if [ -d "realme-ota" ]; then
        echo -e "${YELLOW}Каталог 'realme-ota' уже существует.${RESET}"
        while true; do
            echo "1) Использовать существующий каталог (продолжить установку)"
            echo "2) Удалить каталог и начать установку заново"
            echo "0) Выход"
            read -p "Выберите действие (1, 2 или 0): " dir_choice

            case $dir_choice in
                1)
                    echo "Используется существующий каталог."
                    cd realme-ota || show_error "Не удалось перейти в каталог realme-ota."
                    break
                    ;;
                2)
                    echo "Удаление существующего каталога..."
                    rm -rf realme-ota || show_error "Не удалось удалить каталог 'realme-ota'."
                    echo -e "${GREEN}Клонирование репозитория realme-ota...${RESET}"
                    git clone https://github.com/R0rt1z2/realme-ota.git || show_error "Не удалось клонировать репозиторий."
                    cd realme-ota || show_error "Не удалось перейти в каталог realme-ota."
                    break
                    ;;
                0)
                    echo "Выход из скрипта."
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Неверный выбор. Пожалуйста, введите 1, 2 или 0.${RESET}"
                    ;;
            esac
        done
    else
        echo -e "${GREEN}Клонирование репозитория realme-ota...${RESET}"
        git clone https://github.com/R0rt1z2/realme-ota.git || show_error "Не удалось клонировать репозиторий."
        cd realme-ota || show_error "Не удалось перейти в каталог realme-ota."
    fi

    echo -e "${GREEN}Настройка виртуального окружения Python...${RESET}"
    # Проверяем, не находимся ли мы уже в виртуальном окружении
    if [ -z "$VIRTUAL_ENV" ]; then
        python3 -m venv venv || show_error "Не удалось создать виртуальное окружение."
        source venv/bin/activate || show_error "Не удалось активировать виртуальное окружение."
    else
        echo "Виртуальное окружение уже активировано."
    fi

    echo -e "${GREEN}Установка/обновление realme-ota...${RESET}"
    pip install . --upgrade --break-system-packages || pip install . --upgrade || show_error "Не удалось установить realme-ota."

    echo -e "${GREEN}Создание ota_downloader.sh...${RESET}"
    # Используем cat с EOF для записи скрипта
    cat > ota_downloader.sh << 'EOF'
#!/bin/bash
# ... (здесь содержимое вашего файла script.txt) ...
# ВАЖНО: Весь текст из файла script.txt должен быть вставлен сюда.
# Из-за ограничений по длине я не буду вставлять его снова, 
# но вы должны скопировать его сюда, как в предыдущем ответе.
#!/bin/bash

# 🎨 Farby pre výstup
  RED="\e[31m"; 
  GREEN="\e[32m"; 
  PURPLE="\e[35m"; 
  YELLOW="\e[33m"; 
  BLUE="\e[34m";
RESET="\e[0m"

# 📌 Regióny, verzie a servery
declare -A REGIONS=(
    [A4]="APC Global 10100100"
    [A5]="OCA Oce_Cen_Australia 10100101"
    [A6]="MEA Middle_East_Africa 10100110"
    [A7]="ROW Global 10100111"  
    [1A]="TW Taiwan 00011010" 
    [1B]="IN India 00011011"
    [2C]="SG Singapure 00101100"
    [3C]="VN Vietnam 00111100" 
    [3E]="PH Philippines 00111110"
    [33]="ID Indonesia 00110011" 
    [37]="RU Russia 00110111" 
    [38]="MY Malaysia 00111000"
    [39]="TH Thailand 00111001" 
    [44]="EUEX Europe 01000100" 
 
   [51]="TR Turkey 01010001"
    [75]="EG Egypt 01110101" 
    [82]="HK Hong_Kong 10000010"
    [83]="SA Saudi_Arabia 10000011" 
    [9A]="LATAM Latin_America 10011010" 
    [97]="CN China 10010111"
)
declare -A VERSIONS=(
  [A]="Launch version" 
  [C]="First update" 
  [F]="Second update" 
  [H]="Third update"
)
declare -A SERVERS=(
  [97]="-r 1" 
  [44]="-r 0" 
  [51]="-r 0"
)

# 📌 Funkcia na spracovanie OTA
run_ota() {
    region_data=(${REGIONS[$region]})
    region_code=${region_data[0]}
    region_name=${region_data[1]}
    nv_id=${region_data[2]}
    server="${SERVERS[$region]:--r 3}"
    ota_model="$device_model"
 
   for rm in TR RU EEA T2 CN IN ID MY TH EU;
do 
    ota_model="${ota_model//$rm/}"; 
done

    echo -e "\n🛠 Model: ${COLOR}$device_model${RESET}"
    echo -e "🛠 Region: ${GREEN}$region_name${RESET} (code: ${YELLOW}$region_code${RESET})"
    echo -e "🛠 OTA version: ${BLUE}${VERSIONS[$version]}${RESET}"
    echo -e "🛠 Server: ${GREEN}$server${RESET}"

    ota_command="realme-ota $server $device_model ${ota_model}_11.${version}.01_0001_100001010000 6 $nv_id"
    echo -e "🔍 Running: ${BLUE}$ota_command${RESET}"
    output=$(eval "$ota_command")

    real_ota_version=$(echo "$output" | grep -o '"realOtaVersion": *"[^"]*"' | cut -d '"' -f4)
    real_version_name=$(echo "$output" | grep -o '"realVersionName": *"[^"]*"' | cut -d '"' -f4)
    ota_f_version=$(echo "$real_ota_version" | 
grep -oE '_11\.[A-Z]\.[0-9]+' | sed 's/_11\.//')
    ota_date=$(echo "$real_ota_version" | grep -oE '_[0-9]{12}$' | tr -d '_')
    ota_version_full="${ota_model}_11.${ota_f_version}_${region_code}_${ota_date}"
	os_version=$(echo "$output" | grep -o '"realOsVersion": *"[^"]*"' | cut -d '"' -f4)
    security_os=$(echo "$output" |
grep -o '"securityPatchVendor": *"[^"]*"' | cut -d '"' -f4)
    android_version=$(echo "$output" | grep -o '"androidVersion": *"[^"]*"' | cut -d '"' -f4)
# Získať URL k About this update
    about_update_url=$(echo "$output" | grep -oP '"panelUrl"\s*:\s*"\K[^"]+')

# Získať VersionTypeId
    version_type_id=$(echo "$output" | grep -oP '"versionTypeId"\s*:\s*"\K[^"]+')

# Výpis
   echo -e "ℹ️   OTA version: ${YELLOW}$real_ota_version${RESET}"
   echo -e "ℹ️   Version Firmware: ${PURPLE}$real_version_name${RESET}"
   echo -e "ℹ️   Android Version: ${YELLOW}$android_version${RESET}"
   echo -e "ℹ️   OS Version: ${YELLOW}$os_version${RESET}"
   echo -e "ℹ️   Security Patch: 
${YELLOW}$security_os${RESET}"
   echo -e "ℹ️   ChangeLoG: ${GREEN}$about_update_url${RESET}"
   echo -e "ℹ️   Status OTA: ${BLUE}$version_type_id${RESET}"
  

    download_link=$(echo "$output" | grep -o 'http[s]*://[^"]*' | head -n 1 | sed 's/["\r\n]*$//')
    modified_link=$(echo "$download_link" |
sed 's/componentotacostmanual/opexcostmanual/g')

    echo -e "\n📥 OTA version: ${BLUE}$ota_version_full${RESET}"
    if [[ -n "$modified_link" ]];
then
        echo -e "📥 Download URL: ${GREEN}$modified_link${RESET}"
    else
        echo -e "❌ Download URL not found."
fi

    echo "$ota_version_full" >> "ota_${device_model}.txt"
    echo "$modified_link" >> "ota_${device_model}.txt"
    echo "" >> "ota_${device_model}.txt"

    [[ !
-f Ota_links.csv ]] && echo "OTA version & URL" > Ota_links.csv
    grep -qF "$modified_link" Ota_links.csv ||
echo "$ota_version_full,$modified_link" >> Ota_links.csv
}

# 📌 Výber prefixu a modelu
clear
echo -e "${GREEN}+===================================================================================================================+${RESET}"
echo -e "${GREEN}|======${RESET}       ${BLUE}Universal${RESET}    ${BLUE}OTA FindeR${RESET}            ${YELLOW}Realme${RESET}   ${GREEN}OPPO${RESET}  ${RED} OnePlus${RESET}            ${BLUE}by ${RESET}${PURPLE}Stano36 & SeRViP${RESET}       ${GREEN}======|${RESET}"
echo -e "${GREEN}+===================================================================================================================+${RESET}"
printf "| %-5s | %-6s | %-18s || %-5s | %-6s | %-18s || %-5s | %-6s | %-18s |\n" "Manif" "R code" "Region" "Manif" "R code" "Region" "Manif" "R code" "Region"
echo -e "+-------------------------------------------------------------------------------------------------------------------+"

keys=("${!REGIONS[@]}")
length=${#keys[@]}

for 
((i = 0; i < length; i+=3)); do
    # 1. stĺpec
    key1="${keys[$i]}"
    region_data1=(${REGIONS[$key1]})
    region_code1=${region_data1[0]}
    region_name1=${region_data1[1]}

    # 2. stĺpec
    if (( i+1 < length ));
then
        key2="${keys[$i+1]}"
        region_data2=(${REGIONS[$key2]})
        region_code2=${region_data2[0]}
        region_name2=${region_data2[1]}
    else
        key2=""
        region_code2=""
        region_name2=""
    fi

    # 3. stĺpec
    if (( i+2 < length ));
then
        key3="${keys[$i+2]}"
        region_data3=(${REGIONS[$key3]})
        region_code3=${region_data3[0]}
        region_name3=${region_data3[1]}
    else
        key3=""
        region_code3=""
        region_name3=""
    fi

    # Výpis riadku tabuľky
    printf "|  ${YELLOW}%-4s${RESET} | %-6s | %-18s ||  ${YELLOW}%-4s${RESET} | %-6s | %-18s ||  ${YELLOW}%-4s${RESET} | %-6s | %-18s |\n" \
  
      "$key1" "$region_code1" "$region_name1" \
        "$key2" "$region_code2" "$region_name2" \
        "$key3" "$region_code3" "$region_name3"
done

echo -e "+-------------------------------------------------------------------------------------------------------------------+"
echo -e "${GREEN}+===================================================================================================================+${RESET}"
echo -e "${GREEN}|======  ${RESET}" "OTA version :  ${BLUE}A${RESET} = Launch version ,   ${BLUE}C${RESET} = First update ,   ${BLUE}F${RESET} = Second update ,   ${BLUE}H${RESET} = Third update "                    "${GREEN}=======|${RESET}"
echo -e "${GREEN}|===========  ${RESET}" "${PURPLE}*#6776#${RESET}    ${GREEN}===============  ${RESET} 
   ${YELLOW}Manifest:Image${RESET}      ${GREEN}===============  ${RESET}     ${BLUE}OTA version${RESET}   "         "${GREEN}============|${RESET}"
echo -e "${GREEN}+===================================================================================================================+${RESET}"
# Zoznam prefixov
echo -e "📦 Choose model prefix:  ${YELLOW}1) CPH${RESET},  ${GREEN}2) RMX${RESET},  ${BLUE}3) Custom${RESET},  ${PURPLE}4) Selected${RESET}"
read -p "💡 Select an option (1/2/3/4): " choice

if [[ "$choice" == "4" ]];
then
    echo -e "\n📱 ${PURPLE}Selected device list :${RESET}"
    echo -e "${GREEN}+====================================================================================================================+${RESET}"
    printf "| %-2s | %-18s | %-14s | %-6s | %-3s || %-2s | %-18s | %-14s | %-6s | %-3s |\n" "No" "Device" "Model" "Manif" "OTA" "No" "Device" "Model" "Manif" "OTA"
    echo -e "+----+--------------------+----------------+--------+-----||----+--------------------+----------------+--------+-----+"

    mapfile -t devices < <(cat devices.txt)
    total=${#devices[@]}
    half=$(( (total + 1) / 2 ))

    for ((i = 0; i < half; i++));
do
        IFS='|' read -r d1 m1 r1 v1 <<< "${devices[$i]}"
        if (( i + half < total ));
then
            IFS='|'
read -r d2 m2 r2 v2 <<< "${devices[$((i + half))]}"
        else
            d2="";
m2=""; r2=""; v2=""
        fi
        printf "| ${YELLOW}%-2d${RESET} | %-18s | %-14s | %-6s | %-3s || ${YELLOW}%-2d${RESET} | %-18s | %-14s | %-6s | %-3s |\n" \
            $((i+1)) "$d1" "$m1" "$r1" "$v1" \
            $((i+1+half)) "$d2" "$m2" "$r2" "$v2"
    done

    echo -e "${GREEN}+====================================================================================================================+${RESET}"
    read -p "🔢 Select device number: " selected

    if !
[[ "$selected" =~ ^[0-9]+$ ]] || (( selected < 1 || selected > total ));
then
        echo "❌ Invalid selection.";
exit 1
    fi

    IFS='|'
read -r selected_name selected_model region version <<< "${devices[$((selected-1))]}"
    device_model="$(echo $selected_model | xargs)"
    region="$(echo $region | xargs)"
    version="$(echo $version | xargs)"
    echo -e "✅ Selected device: ${PURPLE}$selected_name${RESET}  →  ${BLUE}$device_model${RESET}, ${GREEN}$region${RESET}, ${YELLOW}$version${RESET}"

else
    if [[ "$choice" == "1" ]];
then
        COLOR=$YELLOW; prefix="CPH"
    elif [[ "$choice" == "2" ]];
then
        COLOR=$GREEN; prefix="RMX"
    elif [[ "$choice" == "3" ]];
then
        read -p "🧩 Enter your custom prefix (e.g. XYZ): " prefix
        if [[ -z "$prefix" ]];
then
            echo "❌ Prefix cannot be empty.";
exit 1
        fi
    else
        echo "❌ Invalid choice.";
exit 1
    fi

    echo -e "${COLOR}➡️  You selected option $choice${RESET}"

    read -p "🔢 Enter model number : " model_number
    device_model="${prefix}${model_number}"
    echo -e "✅ Selected model: ${COLOR}$device_model${RESET}"

    read -p "📌 Manifest + OTA version : " input
    region="${input:0:${#input}-1}"
    version="${input: -1}"

    if [[ -z "${REGIONS[$region]}" ||
-z "${VERSIONS[$version]}" ]]; then
        echo -e "❌ Invalid input! Exiting."
exit 1
    fi
fi

# ✅ Zavolanie OTA funkcie alebo skriptu
run_ota



# 🔁 Cyklus pre ďalšie voľby
while true;
do
    echo -e "\n🔄 1 - Change only region/version"
    echo -e "🔄 2 - Change device model"
    echo -e "🔄 3 - Open list Links"
    echo -e "⬇️ 4 -${GREEN}$Show URLs${RESET} (long press to open the menu)"
    echo -e "     → More > Select URL"
    echo -e "     → ${PURPLE}Tap to copy the link${RESET}, ${BLUE}long press to open in browser${RESET}"
    echo -e "❌ 0 - End script"
    read 
-p "💡 Select an option (1/2/3): " option
    case "$option" in
        1)
            read -p "📌 Manifest + OTA version : " input
            region="${input:0:${#input}-1}"
            version="${input: -1}"
            if [[ -z "${REGIONS[$region]}" ||
-z "${VERSIONS[$version]}" ]]; then
                echo "❌ Invalid input."
continue
            fi
            run_ota
            ;;
2)
            bash "$0"  # reštart skriptu
            ;;
3)
            cat Ota_links.csv   #open list links
            exit 0
            ;;
0)
            echo -e "👋 Goodbye."
exit 0
            ;;
*)
            echo "❌ Invalid option."
            ;;
    esac
done
EOF
    chmod +x ota_downloader.sh || show_error "Не удалось сделать ota_downloader.sh исполняемым."

    echo -e "${GREEN}Создание devices.txt...${RESET}"
    cat > devices.txt << 'EOF'
OnePlus 13|CPH2649IN|1B|A
OnePlus 13|CPH2653EEA|44|A
OnePlus 13|CPH2653|A7|A
OnePlus 13|PJZ110|97|A
OnePlus 13s|CPH2723IN|1B|A
OnePlus 13T|PKX110|97|A
OnePlus 12|CPH2573IN|1B|C
OnePlus 12|CPH2581EEA|44|C
OnePlus 12|CPH2581|A7|C
OnePlus 12|PJD110|97|C
OPPO Find X8Pro|CPH2659IN|1B|A
OPPO Find N5|CPH2671|2C|A
OPPO Find N5|CPH2671|A4|A
EOF

    echo -e "${GREEN}Настройка псевдонима (alias) 'ota'...${RESET}"
    # Определяем конфигурационный файл оболочки
    SHELL_CONFIG=""
    if [ -n "$BASH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    else
        echo -e "${YELLOW}Не удалось автоматически определить вашу оболочку. Добавьте псевдоним вручную.${RESET}"
    fi

    if [ -n "$SHELL_CONFIG" ]; then
        # Удаляем старый псевдоним, если он есть, чтобы избежать дублирования
        sed -i "/alias ota=/d" "$SHELL_CONFIG"
        # Добавляем новый псевдоним
        echo "alias ota='cd $HOME/realme-ota && source venv/bin/activate && bash ota_downloader.sh'" >> "$SHELL_CONFIG"
        echo "Псевдоним 'ota' добавлен в $SHELL_CONFIG"
    fi

    echo -e "${GREEN}Установка успешно завершена!${RESET}"
    echo ""
    echo -e "Чтобы начать использовать инструмент, выполните ОДНО из следующих действий:"
    echo -e "1. Перезапустите ваш терминал."
    echo -e "2. ИЛИ выполните команду: ${YELLOW}source ${SHELL_CONFIG:-$HOME/.bashrc}${RESET}"
    echo ""
    echo -e "После этого вы сможете запускать инструмент командой: ${YELLOW}ota${RESET}"
    echo ""
    
    # Деактивируем виртуальное окружение, чтобы не оставлять его активным после установки
    if [ -n "$VIRTUAL_ENV" ]; then
        deactivate
    fi
}

main_install
