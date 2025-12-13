#!/usr/bin/env bash
# WARP IPv4 自动安装脚本
# 功能: 检测IPv4支持情况,自动安装WARP并配置IPv4优先

# 颜色输出函数
red() { echo -e "\033[31m\033[01m$*\033[0m"; }
green() { echo -e "\033[32m\033[01m$*\033[0m"; }
yellow() { echo -e "\033[33m\033[01m$*\033[0m"; }


# 检测系统类型
detect_system() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    else
        red "无法检测系统类型"
        exit 1
    fi
    
    green "检测到系统: $OS $VER"
}

# 检测IPv4连接
check_ipv4() {
    green "正在检测IPv4连接..."
    
    # 通过下载GitHub文件测试IPv4
    local test_url="https://github.com/dsadsadsss/vps-argo/releases/download/1/grpcwebproxy-amd64"
    local test_file="/tmp/ipv4_test_$"
    
    yellow "测试下载: $test_url"
    
    # 尝试下载文件(5秒超时)
    if wget -q --timeout=10 --tries=1 -O "$test_file" "$test_url" 2>/dev/null; then
        # 检查文件是否成功下载(大小大于0)
        if [ -s "$test_file" ]; then
            green "✓ IPv4连接正常,无需安装WARP"
            rm -f "$test_file"
            return 0
        fi
    fi
    
    # 清理测试文件
    rm -f "$test_file"
    
    yellow "✗ IPv4连接不可用,需要安装WARP"
    return 1
}

# 安装依赖
install_dependencies() {
    green "正在安装依赖..."
    
    case $OS in
        ubuntu|debian)
            export DEBIAN_FRONTEND=noninteractive
            apt-get update -qq
            apt-get install -y -qq curl wget gpg lsb-release >/dev/null 2>&1
            ;;
        centos|rhel|rocky|almalinux)
            yum install -y -q curl wget >/dev/null 2>&1
            ;;
        *)
            yellow "未知系统类型,尝试继续..."
            ;;
    esac
}

# 下载WARP脚本
download_warp_script() {
    green "正在下载WARP脚本..."
    
    # GitHub代理列表(用于IPv6 only环境)
    local github_proxies=(
        "https://ghproxy.com/"
        "https://mirror.ghproxy.com/"
        "https://gh-proxy.com/"
        ""  # 最后尝试直连
    )
    
    # 原始脚本URL
    local script_urls=(
        "https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh"
        "https://raw.githubusercontent.com/fscarmen/warp-sh/main/menu.sh"
    )
    
    # 先尝试GitLab(通常更稳定)
    for url in "${script_urls[@]}"; do
        # 如果是GitHub URL,尝试使用代理
        if [[ "$url" =~ "github" ]]; then
            for proxy in "${github_proxies[@]}"; do
                local full_url="${proxy}${url}"
                yellow "尝试: $full_url"
                if wget -q --timeout=15 -O /tmp/warp_menu.sh "$full_url" 2>/dev/null; then
                    if [ -s /tmp/warp_menu.sh ] && grep -q "VERSION=" /tmp/warp_menu.sh; then
                        green "✓ 脚本下载成功 (使用${proxy:-直连})"
                        chmod +x /tmp/warp_menu.sh
                        return 0
                    fi
                fi
            done
        else
            # GitLab直接下载
            yellow "尝试: $url"
            if wget -q --timeout=15 -O /tmp/warp_menu.sh "$url" 2>/dev/null; then
                if [ -s /tmp/warp_menu.sh ] && grep -q "VERSION=" /tmp/warp_menu.sh; then
                    green "✓ 脚本下载成功"
                    chmod +x /tmp/warp_menu.sh
                    return 0
                fi
            fi
        fi
    done
    
    red "所有下载源均失败"
    exit 1
}

# 安装WARP (IPv6单栈添加IPv4)
install_warp_ipv4() {
    green "正在安装WARP IPv4支持..."
    
    # 设置环境变量以实现无交互安装
    export DEBIAN_FRONTEND=noninteractive
    
    # 选项说明:
    # 4 = 安装WARP IPv4
    # [lisence] = 空(使用免费账户)
    # 自动选择语言为英语(1)或中文(2)
    
    cd /tmp
    
    # 模拟输入: 语言选择(默认), IPv4安装, 免费账户, IPv4优先
    echo -e "1\n1\n1\n" | bash /tmp/warp_menu.sh 4 2>/dev/null || {
        # 如果交互式失败,尝试直接调用
        bash /tmp/warp_menu.sh 4 "" "" 2>/dev/null
    }
    
    # 等待安装完成
    sleep 3
}

# 设置IPv4优先
set_ipv4_priority() {
    green "正在设置IPv4优先..."
    
    # 修改gai.conf设置IPv4优先
    if [ -f /etc/gai.conf ]; then
        # 清除旧配置
        sed -i '/^precedence ::ffff:0:0/d' /etc/gai.conf
        sed -i '/^label 2002::/d' /etc/gai.conf
        
        # 添加IPv4优先配置
        echo "precedence ::ffff:0:0/96  100" >> /etc/gai.conf
        green "✓ IPv4优先级设置完成"
    else
        yellow "警告: /etc/gai.conf 不存在,跳过优先级设置"
    fi
}

# 验证WARP安装
verify_warp() {
    green "正在验证WARP安装..."
    
    sleep 5
    
    # 检查wg-quick是否存在
    if ! command -v wg-quick &>/dev/null; then
        red "✗ WARP安装失败: wg-quick命令不存在"
        return 1
    fi
    
    # 检查配置文件
    if [ ! -f /etc/wireguard/warp.conf ]; then
        red "✗ WARP配置文件不存在"
        return 1
    fi
    
    # 检查WARP状态
    if wg show warp &>/dev/null; then
        green "✓ WARP接口已启动"
    else
        yellow "正在启动WARP接口..."
        wg-quick up warp >/dev/null 2>&1 || {
            red "✗ WARP接口启动失败"
            return 1
        }
    fi
    
    # 验证IPv4连接
    sleep 3
    if ping -c 2 -W 5 8.8.8.8 >/dev/null 2>&1; then
        green "✓ IPv4连接验证成功!"
        return 0
    else
        red "✗ IPv4连接验证失败"
        return 1
    fi
}

# 显示结果
show_result() {
    echo ""
    green "======================================"
    green "WARP IPv4 安装完成!"
    green "======================================"
    echo ""
    
    # 获取IP信息
    local ipv4=$(curl -s4m5 ifconfig.me 2>/dev/null || echo "获取失败")
    local ipv6=$(curl -s6m5 ifconfig.me 2>/dev/null || echo "获取失败")
    
    echo "IPv4 地址: $ipv4"
    echo "IPv6 地址: $ipv6"
    echo ""
    echo "WARP管理命令:"
    echo "  启动: wg-quick up warp"
    echo "  停止: wg-quick down warp"
    echo "  状态: wg show warp"
    echo "  快捷: warp (如果已创建)"
    echo ""
}

# 主函数
main() {
    clear
    green "======================================"
    green "WARP IPv4 自动安装脚本"
    green "======================================"
    echo ""
    
    # 执行检查和安装流程
    check_root
    detect_system
    
    # 检查IPv4支持
    if check_ipv4; then
        green "系统已支持IPv4,脚本退出"
        exit 0
    fi
    
    # 不再检查IPv6,直接安装WARP
    
    # 安装依赖
    install_dependencies
    
    # 下载WARP脚本
    download_warp_script
    
    # 安装WARP IPv4
    yellow "开始安装WARP..."
    if install_warp_ipv4; then
        green "✓ WARP安装命令执行完成"
    else
        yellow "安装过程可能遇到问题,继续验证..."
    fi
    
    # 设置IPv4优先
    set_ipv4_priority
    
    # 验证安装
    if verify_warp; then
        show_result
        exit 0
    else
        red "WARP安装或验证失败,请检查日志"
        red "可尝试手动运行: bash /tmp/warp_menu.sh"
        exit 1
    fi
}

# 运行主函数
main "$@"
