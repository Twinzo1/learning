#!/bin/sh
# 定时命令
# */1 * * * * /etc/storage/bypa.sh check

LOGFILE="/tmp/log/bypa.log"
# 获取旁路由mac地址，必填(或填ipv4地址)
# BYP_MAC=`nvram get bypa_macaddr_x 2>/dev/null`
BYP_MAC=""

# 获取旁路由ipv4地址
# BYP_IP4=`nvram get bypa_ipaddr_x 2>/dev/null`
BYP_IP4="10.0.0.2"
# 我的旁路由ip
[ -z "$BYP_IP4" ] && BYP_IP4=`cat /proc/net/arp | grep -i "$BYP_MAC" | awk -F " " '{print $1}' 2>/dev/null`

# 通过ipv4地址获取mac
[ -z "$BYP_MAC" ] && BYP_MAC=`cat /proc/net/arp | grep -w "$BYP_IP4" | awk -F " " '{print $4}'`

# 获取旁路由ipv6地址
BYP_IP6=`ip -6 neighbor show | grep -i "$BYP_MAC" | sed -n '1p' | awk -F " " '{print $1}' 2>/dev/null`

# 解锁网易云pac地址
# BYP_PAC=`nvram get bypa_pac_x 2>/dev/null`
BYP_PAC=""

# 添加dhcp_option
add_dhcp()
{
	sed -i '/dhcp-option=lan,3,"$BYP_IP4"/d' /etc/storage/dnsmasq/dnsmasq.conf
	sed -i '/dhcp-option=lan,6,"$BYP_IP4"/d' /etc/storage/dnsmasq/dnsmasq.conf
	sed -i '/dhcp-option=lan,252,"$BYP_PAC"/d' /etc/storage/dnsmasq/dnsmasq.conf
	nvram set dhcp_dnsv6_x=""
cat >> /etc/storage/dnsmasq/dnsmasq.conf << EOF
dhcp-option=lan,3,"$BYP_IP4"
dhcp-option=lan,6,"$BYP_IP4"
dhcp-option=lan,252,"$BYP_PAC"
EOF
  	nvram set dhcp_dnsv6_x="$BYP_IP6"
  	nvram commit
  	/sbin/restart_dhcpd
	logger -t "【BYPA】" 旁路由上线，开始调整dhcp选项"
}

# 删除dhcp_option
del_dhcp()
{
	sed -i '/dhcp-option=lan,3,"$BYP_IP4"/d' /etc/storage/dnsmasq/dnsmasq.conf
	sed -i '/dhcp-option=lan,6,"$BYP_IP4"/d' /etc/storage/dnsmasq/dnsmasq.conf
	sed -i '/dhcp-option=lan,252,"$BYP_PAC"/d' /etc/storage/dnsmasq/dnsmasq.conf
	nvram set dhcp_dnsv6_x=""
	nvram commit
	/sbin/restart_dhcpd
}
# 检测旁路由是否上线
byp_online()
{
	tries=0
	while [[ $tries -lt 3 ]]
	do
		if /bin/ping -c 1 $BYP_IP4 >/dev/null
		then
			al_online=`cat /etc/storage/dnsmasq/dnsmasq.conf | grep "3,$BYP_IP4"`	
			al_exit=`nvram show | grep dhcp_dnsv6_x | grep "$BYP_IP6"`
			[ -z "$al_exit" -o -z "$al_online" ] && add_dhcp
	      		exit 0
		fi
        	tries=$((tries+1))
	done
	logger -t "【BYPA】" 旁路由下线，开始调整dhcp选项"
	del_dhcp
}

[ "$1" = "check" ] && byp_online || logger -t "【BYPA】" "参数错误"
