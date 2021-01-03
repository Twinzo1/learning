#!/bin/sh
# versin v1.13
# 定时命令
# */1 * * * * /etc/storage/bypa.sh start

LOGFILE="/tmp/log/bypa.log"
# 获取旁路由mac地址，必填(或填ipv4地址)
# BYP_MAC=`nvram get bypa_macaddr_x 2>/dev/null`
BYP_MAC=""

# 获取旁路由ipv4地址
# BYP_IP4=`nvram get bypa_ipaddr_x 2>/dev/null`
BYP_IP4="10.0.0.2"
# 我的旁路由ip
[ -z "$BYP_IP4" -a -z "$BYP_MAC" ] && logger -t "【BYPA】" "需填写IP或mac地址，脚本退出" && exit 0
[ -z "$BYP_IP4" ] && BYP_IP4=`cat /proc/net/arp | grep -i "$BYP_MAC" | awk -F " " '{print $1}' 2>/dev/null`

# 通过ipv4地址获取mac
[ -z "$BYP_MAC" ] && BYP_MAC=`cat /proc/net/arp | grep -w "$BYP_IP4" | awk -F " " '{print $4}'`

# 获取旁路由ipv6地址
BYP_IP6=`ip -6 neighbor show | grep -i "$BYP_MAC" | sed -n '1p' | awk -F " " '{print $1}' 2>/dev/null`

# 解锁网易云pac地址
# BYP_PAC=`nvram get bypa_pac_x 2>/dev/null`
BYP_PAC="http://10.0.0.2/music.pac"

# 添加dhcp_option
add_dhcp()
{
	sed -i "/dhcp-option=greatwall,3,$BYP_IP4/d" /etc/storage/dnsmasq/dnsmasq.conf
	# 只指定greatwall的mac网关为旁路由ip，会得不到nat1
	# 使用dhcp-mac=dhcp-mac=set:greatwall,<MAC address>标记需要科学的mac地址
	sed -i "/dhcp-option=lan,6,$BYP_IP4/d" /etc/storage/dnsmasq/dnsmasq.conf
	sed -i "/dhcp-option=lan,252/d" /etc/storage/dnsmasq/dnsmasq.conf
	nvram set dhcp_dnsv6_x=""
cat >> /etc/storage/dnsmasq/dnsmasq.conf << EOF
dhcp-option=greatwall,3,$BYP_IP4
dhcp-option=lan,6,$BYP_IP4
dhcp-option=lan,252,$BYP_PAC
EOF
	[ -z "$BYP_PAC" ] && sed -i "/dhcp-option=lan,252/d" /etc/storage/dnsmasq/dnsmasq.conf
  	nvram set dhcp_dnsv6_x="$BYP_IP6"
  	nvram commit
  	/sbin/restart_dhcpd
	logger -t "【BYPA】" "旁路由上线，开始调整dhcp选项"
}

# 删除dhcp_option
del_dhcp()
{
	sed -i "/dhcp-option=greatwall,3,$BYP_IP4/d" /etc/storage/dnsmasq/dnsmasq.conf
	sed -i "/dhcp-option=lan,6,$BYP_IP4/d" /etc/storage/dnsmasq/dnsmasq.conf
	sed -i "/dhcp-option=lan,252/d" /etc/storage/dnsmasq/dnsmasq.conf
	nvram set dhcp_dnsv6_x=""
	nvram commit
	/sbin/restart_dhcpd
}
# 检测旁路由是否上线
byp_online(){
	# 主路由为padavan，配合旁路由ss的脚本，旁路由开ssr服务端，不可用，原因未知，可能是没有从wan口进来
	gfwlist=`cat /tmp/dnsmasq.dom/gfwlist_list.conf | grep 127.0.0.1#`
	ss_enabled=`ps | grep /usr/bin/ssr-redir | grep -v grep`
	if [ -n $ss_enabled -a -n "$gfwlist" ]; then
		logger -t "【旁路由ss】" "ss规则有问题，使用旁路由的dns查询"
		awk '!/^$/&&!/^#/{printf("ipset=/%s/'"gfwlist"'\n",$0)}' /etc/storage/gfwlist/gfwlist_list.conf >/tmp/dnsmasq.dom/gfwlist_list.conf
#		awk '!/^$/&&!/^#/{printf("ipset=/%s/'"gfwlist"'\n",$0)}' /etc/storage/ss_dom.sh >/tmp/dnsmasq.dom/ss_dom.conf
#		awk '!/^$/&&!/^#/{printf("ipset=/%s/'"gfwlist"'\n",$0)}' /etc/storage/uss_dom.sh >/tmp/dnsmasq.dom/uss_dom.conf
		awk '!/^$/&&!/^#/{printf("server=/%s/'"10.0.0.2#5335"'\n",$0)}' /etc/storage/gfwlist/gfwlist_list.conf >>/tmp/dnsmasq.dom/gfwlist_list.conf
		sed -i '/no-resolv/d' /etc/storage/dnsmasq/dnsmasq.conf
		sed -i '/server=127.0.0.1/d' /etc/storage/dnsmasq/dnsmasq.conf
		sed -i '/server=10.0.0.2/d' /etc/storage/dnsmasq/dnsmasq.conf
cat >> /etc/storage/dnsmasq/dnsmasq.conf << EOF
no-resolv
server=10.0.0.2#7053
EOF
/sbin/restart_dhcpd
	fi
	al_online=`cat /etc/storage/dnsmasq/dnsmasq.conf | grep "3,$BYP_IP4"`	
	al_exit=`nvram show | grep dhcp_dnsv6_x | grep "$BYP_IP6" | awk -F "=" '{print $2}'`
	(time nslookup www.baidu.com $BYP_IP4 ) 2> /tmp/bypa.log
	time=`cat /tmp/bypa.log | grep real | awk '{print $3}' | awk -F "." '{print $1}'`
	if [ "$time"x == "0"x ] && [ -z "$al_exit" -a -z "$al_online" ]; then
		[ -z "$al_exit" -o -z "$al_online" ] && add_dhcp
		exit 0
	fi
	[ -n "$al_exit" -o -n "$al_online" ] && logger -t "【BYPA】" "旁路由下线，开始调整dhcp选项" && del_dhcp
}

case $1 in
start)
    	byp_online
	;;
*)
	logger -t "【BYPA】" "参数错误"
	;;
esac
