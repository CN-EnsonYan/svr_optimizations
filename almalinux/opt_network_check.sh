echo -e "\n--- [1. 内核与加速算法] ---" && \
uname -r && \
sysctl net.ipv4.tcp_congestion_control net.core.default_qdisc && \
lsmod | grep bbr && \
echo -e "\n--- [2. 关键网络参数] ---" && \
sysctl net.ipv4.tcp_timestamps net.ipv4.tcp_tw_reuse net.ipv4.tcp_syncookies net.ipv4.ip_local_port_range net.core.somaxconn net.core.netdev_max_backlog && \
echo -e "\n--- [3. 资源限制(ULIMIT)] ---" && \
sysctl fs.file-max && ulimit -n && \
echo -e "----------------------------\n"
