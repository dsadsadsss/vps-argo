#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
PLAIN='\033[0m'

echo -e "${CYAN}=======VPS 一键脚本(Tunnel Version)============${PLAIN}"
echo "                      "
echo "                      "

get_system_info() {
    ARCH=$(uname -m)
    VIRT=$(systemd-detect-virt 2>/dev/null || echo "Unknown")
}

install_naray(){
    export ne_file=${ne_file:-'nenether.js'}
    export cff_file=${cff_file:-'cfnfph.js'}
    export web_file=${web_file:-'webssp.js'}
    
    # Set other parameters
    if [[ $PWD == */ ]]; then
      FLIE_PATH="${FLIE_PATH:-${PWD}worlds/}"
    else
      FLIE_PATH="${FLIE_PATH:-${PWD}/worlds/}"
    fi
    
    if [ ! -d "${FLIE_PATH}" ]; then
      if mkdir -p -m 755 "${FLIE_PATH}"; then
        echo ""
      else 
        echo -e "${RED}Insufficient permissions, unable to create file${PLAIN}"
      fi
    fi
    
    if [ -f "/tmp/list.log" ]; then
      rm -rf /tmp/list.log
    fi
    if [ -f "${FLIE_PATH}list.log" ]; then
      rm -rf ${FLIE_PATH}list.log
    fi

    install_config(){
        echo -e -n "${GREEN}请输入节点类型 (可选: vls, vms, rel, hy2, tuic,3x，ech 默认: 3x):${PLAIN}"
        read TMP_ARGO
        export TMP_ARGO=${TMP_ARGO:-'3x'}  

        if [ "${TMP_ARGO}" = "rel" ] || [ "${TMP_ARGO}" = "hy2" ] || [ "${TMP_ARGO}" = "hys" ] || [ "${TMP_ARGO}" = "tuic" ] || [ "${TMP_ARGO}" = "3x" ]; then
        echo -e -n "${GREEN}请输入节点端口 (默认443):${PLAIN}"
        read SERVER_PORT
        SERVER_POT=${SERVER_PORT:-"443"}
        fi

        echo -e -n "${GREEN}请输入节点名称 (默认: vps): ${PLAIN}"
        read SUB_NAME
        SUB_NAME=${SUB_NAME:-"vps"}

        echo -e -n "${GREEN}请输入 NEZHA_SERVER (没有可以不填): ${PLAIN}"
        read NEZHA_SERVER

        echo -e -n "${GREEN}请输入NEZHA_KEY (没有可以不填): ${PLAIN}"
        read NEZHA_KEY

        echo -e -n "${GREEN}请输入 NEZHA_PORT (默认443): ${PLAIN}"
        read NEZHA_PORT
        NEZHA_PORT=${NEZHA_PORT:-"443"}

        echo -e -n "${GREEN}是否启用哪吒tls (1 启用, 0 关闭，默认启用): ${PLAIN}"
        read NEZHA_TLS
        NEZHA_TLS=${NEZHA_TLS:-"1"}
        
        if [ "${TMP_ARGO}" = "vls" ] || [ "${TMP_ARGO}" = "vms" ] || [ "${TMP_ARGO}" = "xhttp" ] || [ "${TMP_ARGO}" = "spl" ] || [ "${TMP_ARGO}" = "3x" ] || [ "${TMP_ARGO}" = "ech" ]; then
        echo -e -n "${GREEN}请输入固定隧道TOKEN(不填，则使用临时隧道): ${PLAIN}"
        read TOK
        echo -e -n "${GREEN}请输入固定隧道域名 (临时隧道不用填): ${PLAIN}"
        read ARGO_DOMAIN
        echo -e -n "${GREEN}请输入cf优选IP或域名(默认 ip.sb): ${PLAIN}"
        read CF_IP
        fi
        CF_IP=${CF_IP:-"ip.sb"}
        echo -e -n "${GREEN}节点上传TG,格式: "CHAT_ID BOT_TOKEN": ${PLAIN}"
        read TG
    }

    install_config2(){
        processes=("$web_file" "$ne_file" "$cff_file" "start.sh" "app" "nxapp")
for process in "${processes[@]}"
do
    pids=$(pgrep -f "$process")
    if [ -n "$pids" ]; then
        echo -e "${YELLOW}Stopping processes matching $process...${PLAIN}"
        for pid in $pids; do
            kill "$pid" &>/dev/null
        done
    fi
done
        echo -e -n "${GREEN}请输入节点类型 (可选: vls, vms, rel, hys,ech 默认: vls):${PLAIN}"
        read TMP_ARGO
        export TMP_ARGO=${TMP_ARGO:-'vls'}

        if [ "${TMP_ARGO}" = "rel" ] || [ "${TMP_ARGO}" = "hy2" ] || [ "${TMP_ARGO}" = "hys" ] || [ "${TMP_ARGO}" = "tuic" ] || [ "${TMP_ARGO}" = "3x" ]; then
        echo -e -n "${GREEN}请输入端口 (default 443, note that nat chicken port should not exceed the range):${PLAIN}"
        read SERVER_PORT
        SERVER_POT=${SERVER_PORT:-"443"}
        fi

        echo -e -n "${GREEN}请输入节点名称 (default: vps): ${PLAIN}"
        read SUB_NAME
        SUB_NAME=${SUB_NAME:-"vps"}

        echo -e -n "${GREEN}Please enter NEZHA_SERVER (没有可以不填): ${PLAIN}"
        read NEZHA_SERVER

        echo -e -n "${GREEN}Please enter NEZHA_KEY (没有可以不填): ${PLAIN}"
        read NEZHA_KEY

        echo -e -n "${GREEN}Please enter NEZHA_PORT (默认: 443): ${PLAIN}"
        read NEZHA_PORT
        NEZHA_PORT=${NEZHA_PORT:-"443"}

        echo -e -n "${GREEN}是否启用 NEZHA TLS? (default: enabled, set 0 to disable): ${PLAIN}"
        read NEZHA_TLS
        NEZHA_TLS=${NEZHA_TLS:-"1"}
        if [ "${TMP_ARGO}" = "vls" ] || [ "${TMP_ARGO}" = "vms" ] || [ "${TMP_ARGO}" = "xhttp" ] || [ "${TMP_ARGO}" = "spl" ] || [ "${TMP_ARGO}" = "3x" ] || [ "${TMP_ARGO}" = "ech" ]; then
        echo -e -n "${GREEN}请输入固定隧道token (不输入则使用临时隧道): ${PLAIN}"
        read TOK
        echo -e -n "${GREEN}请输入固定隧道域名 (临时隧道不用填): ${PLAIN}"
        read ARGO_DOMAIN
        fi
        FLIE_PATH="${FLIE_PATH:-/tmp/worlds/}"
        CF_IP=${CF_IP:-"ip.sb"}
    }

    install_start(){
      cat <<EOL > ${FLIE_PATH}start.sh
#!/bin/bash
## ===========================================Set parameters (delete or add # in front of those not needed)=============================================

# Set ARGO parameters (default uses temporary tunnel, remove # in front to set)
export TOK='$TOK'
export ARGO_DOMAIN='$ARGO_DOMAIN'

# Set NEZHA parameters (NEZHA_TLS='1' to enable TLS, set others to disable TLS)
export NEZHA_SERVER='$NEZHA_SERVER'
export NEZHA_KEY='$NEZHA_KEY'
export NEZHA_PORT='$NEZHA_PORT'
export NEZHA_TLS='$NEZHA_TLS' 

# Set node protocol and reality parameters (vls,vms,rel)
export TMP_ARGO=${TMP_ARGO:-'vls'}  # Set the protocol used by the node
export SERVER_PORT="${SERVER_PORT:-${PORT:-443}}" # IP address cannot be blocked, port cannot be occupied, so cannot open games simultaneously
export SNI=${SNI:-'www.apple.com'} # TLS website

# Set app parameters (default x-ra-y parameters, if you changed the download address, you need to modify UUID and VPATH)
export FLIE_PATH='$FLIE_PATH'
export CF_IP='$CF_IP'
export SUB_NAME='$SUB_NAME'
export SERVER_IP='$SERVER_IP'
## ===========================================Set x-ra-y download address (recommended to use default)===============================
export TG='$TG'
export SUB_URL='$SUB_URL'
## ===================================
export ne_file='$ne_file'
export cff_file='$cff_file'
export web_file='$web_file'
if command -v curl &>/dev/null; then
    DOWNLOAD_CMD="curl -sL"
# Check if wget is available
elif command -v wget &>/dev/null; then
    DOWNLOAD_CMD="wget -qO-"
else
    echo "Error: Neither curl nor wget found. Please install one of them."
    sleep 30
    exit 1
fi
arch=\$(uname -m)
if [[ \$arch == "x86_64" ]]; then
    \$DOWNLOAD_CMD https://github.com/dsadsadsss/plutonodes/releases/download/xr/main-amd > /tmp/nxapp
else
    \$DOWNLOAD_CMD https://github.com/dsadsadsss/plutonodes/releases/download/xr/main-arm > /tmp/nxapp
fi

chmod 777 /tmp/nxapp && /tmp/nxapp
EOL

      # Give start.sh execution permissions
      chmod +x ${FLIE_PATH}start.sh
    }

    # Function: Check and install dependencies
    check_and_install_dependencies() {
        # List of dependencies
        dependencies=("curl" "pgrep" "pidof")

        # Check and install dependencies
        for dep in "${dependencies[@]}"; do
            if ! command -v "$dep" &>/dev/null; then
                echo -e "${YELLOW}$dep command not installed, attempting to install...${PLAIN}"
                if command -v apt-get &>/dev/null; then
                     apt-get update &&  apt-get install -y "$dep"
                elif command -v yum &>/dev/null; then
                     yum install -y "$dep"
                elif command -v apk &>/dev/null; then
                     apk add --no-cache "$dep"
                else
                    echo -e "${RED}Unable to install $dep. Please install it manually.${PLAIN}"
                    echo -e "${YELLOW}Continuing with the script...${PLAIN}"
                    continue
                fi
                if command -v "$dep" &>/dev/null; then
                    echo -e "${GREEN}$dep command has been installed.${PLAIN}"
                else
                    echo -e "${RED}Failed to install $dep. Continuing with the script...${PLAIN}"
                fi
            fi
        done

        echo -e "${GREEN}Dependency check completed${PLAIN}"
    }

    # Function: Configure startup
    configure_startup() {
        # Check and install dependencies
        check_and_install_dependencies
        if [ -s "${FLIE_PATH}start.sh" ]; then
           rm_naray
        fi
        install_config
        install_start
SCRIPT_PATH="${FLIE_PATH}start.sh"
if [ -x "$(command -v systemctl)" ]; then
    echo "Systemd detected. Configuring systemd service..."

    # Create systemd service file
    cat <<EOL > /etc/systemd/system/my_script.service
[Unit]
Description=My Startup Script

[Service]
ExecStart=${SCRIPT_PATH}
Restart=always
User=$(whoami)

[Install]
WantedBy=multi-user.target
EOL

    systemctl daemon-reload
    systemctl enable my_script.service
    systemctl start my_script.service
    echo "Service has been added to systemd startup."
    nohup ${FLIE_PATH}start.sh &
elif [ -x "$(command -v openrc)" ]; then
    echo "OpenRC detected. Configuring startup script..."
   cat <<EOF > /etc/init.d/myservice
#!/sbin/openrc-run
command="${FLIE_PATH}start.sh"
pidfile="${FLIE_PATH}myservice.pid"
command_background=true
start() {
    start-stop-daemon --start --exec \$command --make-pidfile --pidfile \$pidfile
    eend \$?
}
stop() {
    start-stop-daemon --stop --pidfile \$pidfile
    eend \$?
}
EOF
chmod +x /etc/init.d/myservice
rc-update add myservice default
rc-service myservice start
nohup ${FLIE_PATH}start.sh &
echo "Startup script configured via OpenRC."
elif [ -f "/etc/init.d/functions" ]; then
    echo "SysV init detected. Configuring SysV init script..."

    cat <<EOF > /etc/init.d/my_start_script
#!/bin/sh

case "\$1" in
    start)
        echo "Starting my custom startup script"
        $SCRIPT_PATH
        ;;
    stop)
        echo "Stopping my custom startup script"
        killall -9 $(basename $SCRIPT_PATH)
        ;;
    *)
        echo "Usage: \$0 {start|stop}"
        exit 1
        ;;
esac
exit 0
EOF

    chmod +x /etc/init.d/my_start_script
    update-rc.d my_start_script defaults
    echo "Startup script configured via SysV init."
    chmod +x $SCRIPT_PATH
    echo "Setup complete. Reboot your system to test the startup script."
    nohup ${FLIE_PATH}start.sh &
elif [ -d "/etc/supervisor/conf.d" ]; then
    echo "Supervisor detected. Configuring supervisor..."

    cat <<EOF > /etc/supervisor/conf.d/my_start_script.conf
[program:my_start_script]
command=$SCRIPT_PATH
autostart=true
autorestart=true
stderr_logfile=/var/log/my_start_script.err.log
stdout_logfile=/var/log/my_start_script.out.log
EOF

    supervisorctl reread
    supervisorctl update
    nohup ${FLIE_PATH}start.sh &
    echo "Startup script configured via Supervisor."

elif grep -q "alpine" /etc/os-release; then
    echo "Alpine Linux detected. Configuring /etc/inittab for startup script..."

    if ! grep -q "$SCRIPT_PATH" /etc/inittab; then
        echo "::sysinit:$SCRIPT_PATH" >> /etc/inittab
        echo "Startup script added to /etc/inittab."
    else
        echo "Startup script already exists in /etc/inittab."
    fi
    chmod +x $SCRIPT_PATH
    echo "Setup complete. Reboot your system to test the startup script."
    nohup ${FLIE_PATH}start.sh &
else
    echo "No standard init system detected. Attempting to use /etc/rc.local..."

    if [ -f "/etc/rc.local" ]; then
        if ! grep -q "$SCRIPT_PATH" /etc/rc.local; then
            sed -i -e '$i '"$SCRIPT_PATH"'\n' /etc/rc.local
            echo "Startup script added to /etc/rc.local."
        else
            echo "Startup script already exists in /etc/rc.local."
        fi
    else
        echo "#!/bin/sh" > /etc/rc.local
        echo "$SCRIPT_PATH" >> /etc/rc.local
        chmod +x /etc/rc.local
        echo "Created /etc/rc.local and added startup script."
    fi
    chmod +x $SCRIPT_PATH
    echo "Setup complete. Reboot your system to test the startup script."
    nohup ${FLIE_PATH}start.sh &
fi

        echo -e "${YELLOW}Waiting for the script to start... If the wait time is too long, the judgment may be inaccurate. You can observe NEZHA to judge by yourself or try restarting.${PLAIN}"
        echo "......等待节点信息.....约30S左右......"
        while [ ! -f "./tmp/list.log" ] && [ ! -f "${FLIE_PATH}list.log" ] ; do
        sleep 1  # 每秒检查一次文件是否存在
        done
        keyword="$web_file"
        max_attempts=5
        counter=0

        while [ $counter -lt $max_attempts ]; do
          if command -v pgrep > /dev/null && pgrep -f "$keyword" > /dev/null && [ -s /tmp/list.log ]; then
            echo -e "${CYAN}***************************************************${PLAIN}"
            echo "                          "
            echo -e "${GREEN}       Script started successfully${PLAIN}"
            echo "                          "
            break
          elif ps aux | grep "$keyword" | grep -v grep > /dev/null && [ -s /tmp/list.log ]; then
            echo -e "${CYAN}***************************************************${PLAIN}"
            echo "                          "
            echo -e "${GREEN}        Script started successfully${PLAIN}"
            echo "                          "
            break
          else
            sleep 10
            ((counter++))
          fi
        done

        echo "                         "
        echo -e "${CYAN}************Node Information****************${PLAIN}"
        echo "                         "
        if [ -s "${FLIE_PATH}list.log" ]; then
          sed 's/{PASS}/vless/g' ${FLIE_PATH}list.log | cat
        else
          if [ -s "/tmp/list.log" ]; then
            sed 's/{PASS}/vless/g' /tmp/list.log | cat
          fi
        fi
        echo "                         "
        echo -e "${CYAN}***************************************************${PLAIN}"
    }

    # Output menu for user to choose whether to start directly or add to startup and then start
    start_menu2(){
    echo -e "${CYAN}>>>>>>>>Please select an operation:${PLAIN}"
    echo "       "
    echo -e "${GREEN}       1. 开机启动 (需要root)${PLAIN}"
    echo "       "
    echo -e "${GREEN}       2. 临时启动 (无需root)${PLAIN}"
    echo "       "
    echo -e "${GREEN}       0. 退出${PLAIN}"
    read choice

    case $choice in
        2)
            # Temporary start
            echo -e "${YELLOW}Starting temporarily...${PLAIN}"
            install_config2
            install_start
            nohup ${FLIE_PATH}start.sh 2>/dev/null 2>&1 &
    echo -e "${YELLOW}Waiting for start... If wait time too long, you can reboot${PLAIN}"
    while [ ! -f "./tmp/list.log" ] && [ ! -f "${FLIE_PATH}list.log" ] ; do
    sleep 1  # 每秒检查一次文件是否存在
    done
    keyword="$web_file"
    max_attempts=5
    counter=0

    while [ $counter -lt $max_attempts ]; do
      if command -v pgrep > /dev/null && pgrep -f "$keyword" > /dev/null && [ -s /tmp/list.log ]; then
        echo -e "${CYAN}***************************************************${PLAIN}"
        echo "                          "
        echo -e "${GREEN}        Script started successfully${PLAIN}"
        echo "                          "
        break
      elif ps aux | grep "$keyword" | grep -v grep > /dev/null && [ -s /tmp/list.log ]; then
        echo -e "${CYAN}***************************************************${PLAIN}"
        echo "                          "
        echo -e "${GREEN}       Script started successfully${PLAIN}"
        echo "                          "
        
        break
      else
        sleep 10
        ((counter++))
      fi
    done

    echo "                         "
    echo -e "${CYAN}************Node Information******************${PLAIN}"
    echo "                         "
    if [ -s "${FLIE_PATH}list.log" ]; then
      sed 's/{PASS}/vless/g' ${FLIE_PATH}list.log | cat
    else
      if [ -s "/tmp/list.log" ]; then
        sed 's/{PASS}/vless/g' /tmp/list.log | cat
      fi
    fi
    echo "                         "
    echo -e "${CYAN}***************************************************${PLAIN}"
            ;;
        1)
            # Add to startup and then start
            echo -e "${YELLOW}      Adding to startup...${PLAIN}"
            configure_startup
            echo -e "${GREEN}      Added to startup${PLAIN}"
            ;;
          0)
            exit 1
            ;;
          *)
          clear
          echo -e "${RED}Error: Please enter the correct number [0-2]${PLAIN}"
          sleep 5s
          start_menu2
          ;;
    esac
    }
    start_menu2
}

install_bbr(){
    if command -v curl &>/dev/null; then
        bash <(curl -sL https://git.io/kernel.sh)
    elif command -v wget &>/dev/null; then
       bash <(wget -qO- https://git.io/kernel.sh)
    else
        echo -e "${RED}Error: Neither curl nor wget found. Please install one of them.${PLAIN}"
        sleep 30
    fi
}

reinstall_naray(){
    if command -v systemctl &>/dev/null && systemctl is-active my_script.service &>/dev/null; then
        systemctl stop my_script.service &
        echo -e "${GREEN}Service has been stopped.${PLAIN}"
    fi
    processes=("$web_file" "$ne_file" "$cff_file" "start.sh" "app" "nxapp")
    for process in "${processes[@]}"
    do
     pids=$(pgrep -f "$process")
     if [ -n "$pids" ]; then
        echo -e "${YELLOW}Stopping processes matching $process...${PLAIN}"
        for pid in $pids; do
            kill "$pid" &>/dev/null
        done
     fi
     done
     install_naray
}

rm_naray(){
    SCRIPT_PATH="${FLIE_PATH}start.sh"

    # Check for systemd
    if command -v systemctl &>/dev/null; then
        service_name="my_script.service"
        if systemctl is-active --quiet $service_name; then
            echo -e "${YELLOW}Service $service_name is active. Stopping...${PLAIN}"
            systemctl stop $service_name
        fi
        if systemctl is-enabled --quiet $service_name; then
            echo -e "${YELLOW}Disabling $service_name...${PLAIN}"
            systemctl disable $service_name  
        fi
        if [ -f "/etc/systemd/system/$service_name" ]; then
            echo -e "${YELLOW}Removing service file /etc/systemd/system/$service_name...${PLAIN}"
            rm "/etc/systemd/system/$service_name"
        elif [ -f "/lib/systemd/system/$service_name" ]; then
            echo -e "${YELLOW}Removing service file /lib/systemd/system/$service_name...${PLAIN}"
            rm "/lib/systemd/system/$service_name"
        fi
        echo -e "${GREEN}Systemd service removed.${PLAIN}"
    fi
    # Check for SysV init
    if [ -f "/etc/init.d/my_start_script" ]; then
        echo -e "${YELLOW}Removing SysV init script...${PLAIN}"
        update-rc.d -f my_start_script remove
        rm "/etc/init.d/my_start_script"
        echo -e "${GREEN}SysV init script removed.${PLAIN}"
    fi
    # Stop running processes
    processes=("$web_file" "$ne_file" "$cff_file" "start.sh" "app" "nxapp")
    for process in "${processes[@]}"
    do
    pids=$(pgrep -f "$process")
      if [ -n "$pids" ]; then
        echo -e "${YELLOW}Stopping processes matching $process...${PLAIN}"
        for pid in $pids; do
            kill "$pid" &>/dev/null
        done
      fi
    done
    # Remove script file
    if [ -f "$SCRIPT_PATH" ]; then
        echo -e "${YELLOW}Removing startup script $SCRIPT_PATH...${PLAIN}"
        rm -rf "$SCRIPT_PATH"
        echo -e "${GREEN}Startup script removed.${PLAIN}"
    fi

    echo -e "${GREEN}Uninstallation completed.${PLAIN}"
}
start_menu1(){
clear
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${PLAIN}"
echo -e "${PURPLE}VPS 一键脚本 (Tunnel Version)${PLAIN}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${PLAIN}"
echo -e " ${GREEN}System Info:${PLAIN} $(uname -s) $(uname -m)"
echo -e " ${GREEN}Virtualization:${PLAIN} $VIRT"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${PLAIN}"
echo -e " ${GREEN}1.${PLAIN} 安装 ${YELLOW}X-R-A-Y${PLAIN}"
echo -e " ${GREEN}2.${PLAIN} 安装 ${YELLOW}BBR和WARP${PLAIN}"
echo -e " ${GREEN}3.${PLAIN} 卸载 ${YELLOW}X-R-A-Y${PLAIN}"
echo -e " ${GREEN}0.${PLAIN} 退出脚本"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${PLAIN}"
read -p " Please enter your choice [0-3]: " choice
case "$choice" in
    1)
    install_naray
    ;;
    2)
    install_bbr
    ;;
    3)
    rm_naray
    ;;
    0)
    exit 1
    ;;
    *)
    clear
    echo -e "${RED}Please enter the correct number [0-3]${PLAIN}"
    sleep 5
    start_menu1
    ;;
esac
}

# Get system information at the start of the script
get_system_info

# Start the main menu
start_menu1
