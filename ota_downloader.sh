#!/bin/bash

RED="\e[31m"
GREEN="\e[32m"
PURPLE="\e[35m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

declare -A REGIONS=(
    [A4]="APC Global 10100100"
    [A5]="OCA Oce_Cen_Australia 10100101"
    [A6]="MEA Middle_East_Africa 10100110"
    [A7]="ROW Global 10100111"
    [1A]="TW Taiwan 00011010"
    [1B]="IN India 00011011"
    [2C]="SG Singapore 00101100"
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

DEVICES_FILE="devices.txt"

run_ota() {
    if [[ -z "${REGIONS[$region]}" || -z "${VERSIONS[$version]}" ]]; then
        echo -e "${RED}Invalid region or version.${RESET}"
        return 1
    fi

    region_data=(${REGIONS[$region]})
    region_code=${region_data[0]}
    region_name=${region_data[1]}
    nv_id=${region_data[2]}
    server="${SERVERS[$region]:--r 3}"
    ota_model="$device_model"

    for rm in TR RU EEA T2 CN IN ID MY TH EU SG GLO APC; do
        ota_model="${ota_model//$rm/}"
    done

    echo -e "\nModel: ${COLOR}$device_model${RESET}"
    echo -e "Region: ${GREEN}$region_name${RESET} (code: ${YELLOW}$region_code${RESET})"
    echo -e "OTA version: ${BLUE}${VERSIONS[$version]}${RESET}"
    echo -e "Server: ${GREEN}$server${RESET}"

    export PYTHONUTF8=1
    ota_command="python -m realme_ota.main $server $device_model ${ota_model}_11.${version}.01_0001_100001010000 6 $nv_id"

    echo -e "Running: ${BLUE}$ota_command${RESET}"
    output=$(eval "$ota_command")

    if [[ -z "$output" ]]; then
        echo -e "${RED}OTA not found. Check model, region, and version.${RESET}"
        return
    fi

    real_ota_version=$(echo "$output" | grep -o '"realOtaVersion": *"[^"]*"' | cut -d '"' -f4)
    real_version_name=$(echo "$output" | grep -o '"realVersionName": *"[^"]*"' | cut -d '"' -f4)
    ota_f_version=$(echo "$real_ota_version" | grep -oE '_11\.[A-Z]\.[0-9]+' | sed 's/_11\.//')
    ota_date=$(echo "$real_ota_version" | grep -oE '_[0-9]{12}$' | tr -d '_')
    ota_version_full="${ota_model}_11.${ota_f_version}_${region_code}_${ota_date}"
    os_version=$(echo "$output" | grep -o '"realOsVersion": *"[^"]*"' | cut -d '"' -f4)
    security_os=$(echo "$output" | grep -o '"securityPatchVendor": *"[^"]*"' | cut -d '"' -f4)
    android_version=$(echo "$output" | grep -o '"androidVersion": *"[^"]*"' | cut -d '"' -f4)
    about_update_url=$(echo "$output" | grep -oP '"panelUrl"\s*:\s*"\K[^"]+')
    version_type_id=$(echo "$output" | grep -oP '"versionTypeId"\s*:\s*"\K[^"]+')

    echo -e "OTA version: ${YELLOW}$real_ota_version${RESET}"
    echo -e "Firmware: ${PURPLE}$real_version_name${RESET}"
    echo -e "Android: ${YELLOW}$android_version${RESET}"
    echo -e "OS Version: ${YELLOW}$os_version${RESET}"
    echo -e "Security Patch: ${YELLOW}$security_os${RESET}"
    echo -e "Changelog URL: ${GREEN}$about_update_url${RESET}"
    echo -e "OTA Status: ${BLUE}$version_type_id${RESET}"

    download_link=$(echo "$output" | grep -o 'http[s]*://[^"]*' | head -n 1 | sed 's/["\r\n]*$//')
    modified_link=$(echo "$download_link" | sed 's/componentotacostmanual/opexcostmanual/g')

    echo -e "\nOTA Version Name: ${BLUE}$ota_version_full${RESET}"
    if [[ -n "$modified_link" ]]; then
        echo -e "Download URL: ${GREEN}$modified_link${RESET}"
    else
        echo -e "Download URL not found."
    fi

    file="Ota_links.csv"
    if [[ ! -f "$file" ]]; then
        echo "Timestamp,OTA Version,Firmware,Android,OS,Security,URL" > "$file"
    fi
    if ! grep -qF "$modified_link" "$file" && [[ -n "$modified_link" ]]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S")
        echo "$timestamp,\"$ota_version_full\",\"$real_version_name\",\"$android_version\",\"$os_version\",\"$security_os\",\"$modified_link\"" >> "$file"
        echo -e "Saved to ${YELLOW}$file${RESET}"
    fi
}

clear
echo -e "${GREEN}+===================================================================================================================+${RESET}"
echo -e "${GREEN}|======${RESET}    ${CYAN}Universal OTA Finder${RESET}     ${YELLOW}Realme${RESET}  ${GREEN}OPPO${RESET}  ${RED}OnePlus${RESET}           ${PURPLE}by Stano36 & SeRViP${RESET}     ${GREEN}======|${RESET}"
echo -e "${GREEN}+===================================================================================================================+${RESET}"
printf "| %-5s | %-6s | %-18s || %-5s | %-6s | %-18s || %-5s | %-6s | %-18s |\n" "Manif" "R code" "Region" "Manif" "R code" "Region" "Manif" "R code" "Region"
echo -e "+-------------------------------------------------------------------------------------------------------------------+"

keys=("${!REGIONS[@]}"); length=${#keys[@]}
for ((i = 0; i < length; i+=3)); do
    key1="${keys[$i]}"; region_data1=(${REGIONS[$key1]}); region_code1=${region_data1[0]}; region_name1=${region_data1[1]}
    if (( i+1 < length )); then key2="${keys[$i+1]}"; region_data2=(${REGIONS[$key2]}); region_code2=${region_data2[0]}; region_name2=${region_data2[1]}; else key2=""; region_code2=""; region_name2=""; fi
    if (( i+2 < length )); then key3="${keys[$i+2]}"; region_data3=(${REGIONS[$key3]}); region_code3=${region_data3[0]}; region_name3=${region_data3[1]}; else key3=""; region_code3=""; region_name3=""; fi
    printf "|  ${YELLOW}%-4s${RESET} | %-6s | %-18s ||  ${YELLOW}%-4s${RESET} | %-6s | %-18s ||  ${YELLOW}%-4s${RESET} | %-6s | %-18s |\n" "$key1" "$region_code1" "$region_name1" "$key2" "$region_code2" "$region_name2" "$key3" "$region_code3" "$region_name3"
done

echo -e "+-------------------------------------------------------------------------------------------------------------------+"
echo -e "${GREEN}|======  ${RESET}" "OTA version: ${BLUE}A${RESET}=Launch, ${BLUE}C${RESET}=1st, ${BLUE}F${RESET}=2nd, ${BLUE}H${RESET}=3rd"    "${GREEN}=======|${RESET}"
echo -e "${GREEN}+===================================================================================================================+${RESET}"

echo -e "Brand filter:  ${YELLOW}1) All${RESET},  ${GREEN}2) Realme${RESET},  ${BLUE}3) OnePlus${RESET},  ${RED}4) OPPO${RESET}"
read -p "Select brand (1/2/3/4): " brand_choice

case "$brand_choice" in
    2) brand_filter="Realme" ;;
    3) brand_filter="OnePlus" ;;
    4) brand_filter="OPPO" ;;
    *) brand_filter="" ;;
esac

echo -e "Input mode:  ${YELLOW}1) Select from list${RESET},  ${GREEN}2) Enter manually${RESET}"
read -p "Select mode (1/2): " input_mode

if [[ "$input_mode" == "1" ]]; then
    if [[ ! -f "$DEVICES_FILE" ]]; then
        echo -e "${RED}File '$DEVICES_FILE' not found.${RESET}"
        exit 1
    fi

    mapfile -t all_devices < <(grep -v '^\s*$' "$DEVICES_FILE")
    if [[ -n "$brand_filter" ]]; then
        devices=()
        for line in "${all_devices[@]}"; do
            if [[ "$line" == *"$brand_filter"* ]]; then
                devices+=("$line")
            fi
        done
    else
        devices=("${all_devices[@]}")
    fi

    if [[ ${#devices[@]} -eq 0 ]]; then
        echo -e "${RED}No devices found for brand '$brand_filter'.${RESET}"
        exit 1
    fi

    total=${#devices[@]}; half=$(( (total + 1) / 2 ))
    echo -e "\n${PURPLE}Device list${RESET} (${#devices[@]} devices):"
    echo -e "${GREEN}+====================================================================================================================+${RESET}"
    printf "| %-2s | %-20s | %-14s | %-6s | %-3s || %-2s | %-20s | %-14s | %-6s | %-3s |\n" "No" "Device" "Model" "Manif" "OTA" "No" "Device" "Model" "Manif" "OTA"
    echo -e "+----+----------------------+----------------+--------+-----||----+----------------------+----------------+--------+-----+"
    for ((i = 0; i < half; i++)); do
        IFS='|' read -r d1 m1 r1 v1 <<< "${devices[$i]}"
        if (( i + half < total )); then
            IFS='|' read -r d2 m2 r2 v2 <<< "${devices[$((i + half))]}"
        else d2=""; m2=""; r2=""; v2=""; fi
        printf "| ${YELLOW}%-2d${RESET} | %-20s | %-14s | %-6s | %-3s || ${YELLOW}%-2d${RESET} | %-20s | %-14s | %-6s | %-3s |\n" $((i+1)) "$d1" "$m1" "$r1" "$v1" $((i+1+half)) "$d2" "$m2" "$r2" "$v2"
    done
    echo -e "${GREEN}+====================================================================================================================+${RESET}"

    read -p "Select device number: " selected
    if ! [[ "$selected" =~ ^[0-9]+$ ]] || (( selected < 1 || selected > total )); then
        echo -e "${RED}Invalid selection.${RESET}"; exit 1
    fi
    IFS='|' read -r selected_name selected_model region version <<< "${devices[$((selected-1))]}"
    device_model="$(echo $selected_model | xargs)"; region="$(echo $region | xargs)"; version="$(echo $version | xargs)"
    echo -e "Selected: ${PURPLE}$selected_name${RESET} -> ${COLOR}$device_model${RESET}, ${GREEN}$region${RESET}, ${YELLOW}$version${RESET}"
else
    echo -e "Prefix: ${YELLOW}1) CPH${RESET}, ${GREEN}2) RMX${RESET}, ${BLUE}3) PJE/PKG/PJZ${RESET}, ${PURPLE}4) Custom${RESET}"
    read -p "Select prefix (1/2/3/4): " prefix_choice
    case "$prefix_choice" in
        1) COLOR=$YELLOW; prefix="CPH" ;;
        2) COLOR=$GREEN; prefix="RMX" ;;
        3) COLOR=$BLUE; read -p "Enter custom prefix: " prefix; [[ -z "$prefix" ]] && { echo -e "${RED}Empty prefix.${RESET}"; exit 1; } ;;
        4) COLOR=$PURPLE; read -p "Enter custom prefix: " prefix; [[ -z "$prefix" ]] && { echo -e "${RED}Empty prefix.${RESET}"; exit 1; } ;;
        *) echo -e "${RED}Invalid choice.${RESET}"; exit 1 ;;
    esac
    read -p "Enter model number: " model_number; device_model="${prefix}${model_number}"
    echo -e "Model: ${COLOR}$device_model${RESET}"
    read -p "Manifest + OTA version (e.g. 44F): " input
    region="${input:0:${#input}-1}"; version="${input: -1}"
    if [[ -z "${REGIONS[$region]}" || -z "${VERSIONS[$version]}" ]]; then
        echo -e "${RED}Invalid input.${RESET}"; exit 1
    fi
fi

if [[ "$device_model" == CPH* ]]; then COLOR=$YELLOW; elif [[ "$device_model" == RMX* ]]; then COLOR=$GREEN; else COLOR=$BLUE; fi

run_ota

while true; do
    echo -e "\n1 - Change region/version"
    echo -e "2 - Change device model"
    echo -e "3 - Show links (Ota_links.csv)"
    echo -e "4 - Change brand filter"
    echo -e "0 - Exit"
    read -p "Select option (1/2/3/4/0): " option
    case "$option" in
        1)
            read -p "Manifest + OTA version (e.g. 44F): " input
            region="${input:0:${#input}-1}"; version="${input: -1}"
            if [[ -z "${REGIONS[$region]}" || -z "${VERSIONS[$version]}" ]]; then
                echo -e "${RED}Invalid input.${RESET}"; continue
            fi
            run_ota
            ;;
        2) bash "$0"; exit 0 ;;
        3)
            if [[ -f "Ota_links.csv" ]]; then
                echo -e "\n--- Ota_links.csv ---"; cat Ota_links.csv; echo -e "---------------------\n"
            else
                echo -e "Ota_links.csv not created yet."
            fi
            ;;
        4)
            echo -e "Brand filter:  ${YELLOW}1) All${RESET},  ${GREEN}2) Realme${RESET},  ${BLUE}3) OnePlus${RESET},  ${RED}4) OPPO${RESET}"
            read -p "Select brand (1/2/3/4): " brand_choice
            case "$brand_choice" in
                2) brand_filter="Realme" ;;
                3) brand_filter="OnePlus" ;;
                4) brand_filter="OPPO" ;;
                *) brand_filter="" ;;
            esac
            bash "$0"; exit 0
            ;;
        0) exit 0 ;;
        *) echo -e "${RED}Invalid option.${RESET}" ;;
    esac
done
