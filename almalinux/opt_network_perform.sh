# --- 1. 立即生效且永久保存 TCP 时间戳 (BBR 精准度) ---
sysctl -w net.ipv4.tcp_timestamps=1 && \
sed -i 's/net.ipv4.tcp_timestamps = 0/net.ipv4.tcp_timestamps = 1/g' /etc/sysctl.conf && \
grep -q "net.ipv4.tcp_timestamps" /etc/sysctl.conf || echo "net.ipv4.tcp_timestamps = 1" >> /etc/sysctl.conf && \

# --- 2. 配置高并发 TCP 网络参数 (写入 sysctl.conf) ---
cat <<EOF >> /etc/sysctl.conf
# Proxy Optimization Start
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_local_port_range = 1024 65000
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.ip_forward = 1
# Proxy Optimization End
EOF
sysctl -p && \

# --- 3. 突破文件句柄限制 (三层覆盖法) ---
# 层级 A: 创建高优先级 limits 文件
cat <<EOF > /etc/security/limits.d/99-proxy-nofile.conf
*               soft    nofile           1000000
*               hard    nofile           1000000
root            soft    nofile           1000000
root            hard    nofile           1000000
EOF

# 层级 B: 覆盖 systemd 全局限制 (保证后台服务生效)
sed -i 's/^#DefaultLimitNOFILE=.*$/DefaultLimitNOFILE=1000000/' /etc/systemd/system.conf && \
grep -q "DefaultLimitNOFILE" /etc/systemd/system.conf || echo "DefaultLimitNOFILE=1000000" >> /etc/systemd/system.conf && \
sed -i 's/^#DefaultLimitNOFILE=.*$/DefaultLimitNOFILE=1000000/' /etc/systemd/user.conf && \
grep -q "DefaultLimitNOFILE" /etc/systemd/user.conf || echo "DefaultLimitNOFILE=1000000" >> /etc/systemd/user.conf && \

# 层级 C: 强制写入 bashrc (保证 TTY 显示生效)
if ! grep -q "ulimit -n 1000000" /root/.bashrc; then echo 'ulimit -n 1000000' >> /root/.bashrc; fi && \

echo -e "\n\033[32m======================================================\033[0m" && \
echo -e "   所有优化项已执行完成！" && \
echo -e "   【重要】请立即重启服务器以使限制生效: \033[31mreboot\033[0m" && \
echo -e "\033[32m======================================================\033[0m"
