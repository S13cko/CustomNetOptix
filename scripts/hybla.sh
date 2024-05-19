#!/bin/bash
# Auto install latest kernel for TCP Hybla
# System Required: CentOS 6+, Debian 8+, Ubuntu 16+
# Copyright (C) 2024 Mr.Amini Nezhad
# forked from: https://github.com/MrAminiDev/

display_menu() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root"
        exit 1
    fi
    opsy=$(get_os_info)
    arch=$(uname -m)
    lbit=$(getconf LONG_BIT)
    kern=$(uname -r)
    clear
    echo "---------- System Information ----------"
    echo " OS      : $opsy"
    echo " Arch    : $arch ($lbit Bit)"
    echo " Kernel  : $kern"
    echo "----------------------------------------"
    echo "Automatically enable TCP Hybla and VPN optimizations"
    echo
    echo "Page: https://github.com/S13cko/CustomNetOptix/"
    echo "----------------------------------------"
    echo "Press any key to start...or Press Ctrl+C to cancel"
    read -r -s -n 1 key
}

get_os_info() {
    if [[ -f /etc/redhat-release ]]; then
        awk '{print ($1, $3 ~ /^[0-9]/ ? $3 : $4)}' /etc/redhat-release
    elif [[ -f /etc/os-release ]]; then
        awk -F'[= "]' '/PRETTY_NAME/{print $3, $4, $5}' /etc/os-release
    elif [[ -f /etc/lsb-release ]]; then
        awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release
    fi
}

check_sys() {
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif grep -qi "debian" /etc/issue || grep -qi "debian" /proc/version; then
        release="debian"
    elif grep -qi "ubuntu" /etc/issue || grep -qi "ubuntu" /proc/version; then
        release="ubuntu"
    fi
}

check_version() {
    if [[ -s /etc/redhat-release ]]; then
        version=$(grep -oE "[0-9.]+" /etc/redhat-release | cut -d. -f1)
    else
        version=$(grep -oE "[0-9.]+" /etc/issue | cut -d. -f1)
    fi
    bit=$(uname -m)
    bit=${bit/x86_64/x64}
    bit=${bit/i686/x32}
}

sysctl_config() {
    cat <<EOF >/etc/sysctl.conf
# NetOptix optimize network traffic for VPN
# Github: https://github.com/S13cko/CustomNetOptix
net.ipv4.tcp_congestion_control = hybla
net.core.default_qdisc = fq_codel
net.core.optmem_max = 65535
net.ipv4.ip_no_pmtu_disc = 1
net.ipv4.tcp_ecn = 2
net.ipv4.tcp_frto = 2
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 3
net.ipv4.tcp_keepalive_time = 300
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_delack_min = 5
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_reordering = 3
net.ipv4.tcp_early_retrans = 3
net.ipv4.tcp_ssthresh = 32768
net.ipv4.tcp_frto_response = 2
net.ipv4.tcp_abort_on_overflow = 1
net.core.rmem_default = 4194304
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_autocorking = 1
net.ipv4.tcp_tw_recycle = 1
fs.file-max = 1000000
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_rmem = 16384 262144 8388608
net.ipv4.tcp_wmem = 32768 524288 16777216
net.core.somaxconn = 8192
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.wmem_default = 2097152
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_max_syn_backlog = 10240
net.core.netdev_max_backlog = 10240
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.ip_forward = 1
net.ipv4.tcp_fin_timeout = 25
net.ipv4.tcp_mem = 65536 131072 262144
net.ipv4.tcp_retries2 = 8
net.ipv4.udp_mem = 65536 131072 262144
net.unix.max_dgram_qlen = 50
vm.min_free_kbytes = 65536
vm.swappiness = 10
vm.vfs_cache_pressure = 50
net.ipv6.conf.all.accept_ra = 2
net.ipv6.conf.default.accept_ra = 2
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.all.forwarding = 1
net.ipv6.conf.default.forwarding = 1
net.ipv6.conf.all.autoconf = 1
net.ipv6.conf.default.autoconf = 1
net.ipv6.conf.all.optimistic_dad = 1
net.ipv6.conf.default.optimistic_dad = 1
net.ipv6.conf.all.use_tempaddr = 2
net.ipv6.conf.default.use_tempaddr = 2
net.ipv6.conf.all.max_addresses = 16
net.ipv6.conf.default.max_addresses = 16
net.ipv6.conf.all.router_solicitations = 1
net.ipv6.conf.default.router_solicitations = 1
EOF
    sysctl -p
    sysctl --system
}

save_config() {
    sysctl -p
    sysctl --system
}

end_install() {
    clear
    echo "The script successfully installed Hybla and optimized VPN settings."
    read -r -p "Press Enter to continue..."
}

display_menu
check_sys
check_version
sysctl_config
save_config
end_install
