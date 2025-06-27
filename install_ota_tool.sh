#!/bin/bash

# --- Универсальный скрипт установки realme-ota-finder для Debian, Fedora, Arch ---

echo "Этот скрипт установит и настроит realme-ota finder."
read -p "Вы хотите продолжить? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Установка отменена."
    exit 1
fi

# Шаг 1: Определение ОС и установка зависимостей
echo "--------------------------------------------------"
echo "Шаг 1: Определение ОС и установка зависимостей..."
echo "--------------------------------------------------"

# Проверяем наличие /etc/os-release для определения дистрибутива
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Ошибка: Не удалось определить операционную систему. Файл /etc/os-release не найден."
    exit 1
fi

# Устанавливаем зависимости в зависимости от ОС
case "$ID" in
    debian|ubuntu)
        echo "Обнаружен Debian/Ubuntu. Используется apt."
        sudo apt update && sudo apt upgrade -y
        sudo apt install python3 python3-pip python3-venv git -y
        ;;
    fedora)
        echo "Обнаружена Fedora. Используется dnf."
        sudo dnf install python3 python3-pip git -y
        ;;
    arch)
        echo "Обнаружен Arch Linux. Используется pacman."
        sudo pacman -Syu --noconfirm
        sudo pacman -S python python-pip git --noconfirm
        ;;
    *)
        echo "Неподдерживаемая операционная система: $ID."
        echo "Пожалуйста, установите зависимости вручную: python3, pip, venv, git"
        exit 1
        ;;
esac

# Проверяем успешность установки
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось установить зависимости. Прерывание."
    exit 1
fi
echo "Зависимости успешно установлены."


# Переход в домашнюю директорию
cd ~

# Шаг 2: Клонирование репозитория
echo "--------------------------------------------------"
echo "Шаг 2: Клонирование репозитория realme-ota..."
echo "--------------------------------------------------"
if [ -d "realme-ota" ]; then
    echo "Директория 'realme-ota' уже существует. Пропускаем клонирование."
else
    git clone https://github.com/R0rt1z2/realme-ota.git
    if [ $? -ne 0 ]; then
        echo "Ошибка: Не удалось клонировать репозиторий. Прерывание."
        exit 1
    fi
    echo "Репозиторий успешно склонирован."
fi

# Переход в директорию проекта
cd realme-ota

# Шаг 3: Настройка окружения Python и установка пакета
echo "--------------------------------------------------"
echo "Шаг 3: Настройка виртуального окружения Python..."
echo "--------------------------------------------------"
if [ ! -d "venv" ]; then
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo "Ошибка: Не удалось создать виртуальное окружение. Прерывание."
        exit 1
    fi
else
    echo "Виртуальное окружение 'venv' уже существует."
fi

echo "Установка пакета realme-ota..."
venv/bin/pip install . --break-system-packages
if [ $? -ne 0 ]; then
    echo "Ошибка: Не удалось установить пакет. Прерывание."
    exit 1
fi
echo "Пакет успешно установлен."

# Шаг 4: Создание скрипта ota_downloader.sh
echo "--------------------------------------------------"
echo "Шаг 4: Создание файла ota_downloader.sh..."
echo "--------------------------------------------------"
cat > ota_downloader.sh << 'EOF'
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
chmod +x ota_downloader.sh
echo "Файл ota_downloader.sh создан и сделан исполняемым."

# Шаг 5: Создание файла devices.txt
echo "--------------------------------------------------"
echo "Шаг 5: Создание файла devices.txt..."
echo "--------------------------------------------------"
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
echo "Файл devices.txt успешно создан."

# Шаг 6: Настройка псевдонима 'ota' в .bashrc
echo "--------------------------------------------------"
echo "Шаг 6: Настройка псевдонима 'ota'..."
echo "--------------------------------------------------"
ALIAS_CMD="alias ota='cd ~/realme-ota && source venv/bin/activate && bash ota_downloader.sh'"
BASHRC_FILE=~/.bashrc

if ! grep -qF "$ALIAS_CMD" "$BASHRC_FILE"; then
    echo "Добавление псевдонима в $BASHRC_FILE..."
    echo -e "\n# Псевдоним для realme-ota downloader" >> "$BASHRC_FILE"
    echo "$ALIAS_CMD" >> "$BASHRC_FILE"
    echo "Псевдоним 'ota' успешно добавлен."
else
    echo "Псевдоним 'ota' уже существует в $BASHRC_FILE. Пропускаем."
fi

# Заключительные инструкции
echo "=================================================="
echo "✅ Установка завершена!"
echo "=================================================="
echo "Чтобы изменения вступили в силу, выполните одну из команд:"
echo "source ~/.bashrc"
echo "ИЛИ просто откройте новое окно терминала."
echo ""
echo "После этого вы сможете запускать инструмент в любое время, просто введя команду:"
echo "ota"
echo "--------------------------------------------------"
