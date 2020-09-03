### 目前自用命令
```
logger -t "【防火墙】" "打开ipv6 80端口"
ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT
ip6tables -A OUTPUT -p tcp --sport 80 -j ACCEPT
logger -t "【BYPA】" "正在下载旁路由辅助脚本"
if [ ! -e "/etc/storage/bypa.sh" ]; then
    curl -k -s -o /etc/storage/bypa.sh --connect-timeout 10 --retry 3 https://raw.githubusercontent.com/Twinzo1/learning/master/padavan/BYPA/bypa.sh -v
    chmod 755 /etc/storage/bypa.sh && mtd_storage.sh save
    /etc/storage/bypa.sh start
else
    logger -t "【BYPA】" "脚本已存在，无需下载"
fi

logger -t "【SAMBA服务器】" "允许SAMBA访问"
iptables -I INPUT 1 -p udp -m multiport --dport 137,138 -j ACCEPT 
iptables -I INPUT 1 -p tcp -m state --state NEW -m multiport --dport 139,445 -j ACCEPT
sed -i 's/interfaces =.*/interfaces = eth2.2 br0/' /etc/smb.conf
/bin/kill -9 `pidof smbd`
smbd -D -s /etc/smb.conf
# logger -t "【SAMBA服务器】" "脚本完成"

logger -t "【交换机】" "打开vlan 37的通道"
switch vlan set 37 1111111 0 0 ttttttt

logger -t "【网路唤醒】" "防止断电，唤醒旁路由"
/usr/sbin/ether-wake -b ff:ff:ff:ff:ff:ff -i eth2 #填写旁路由mac地址
```
