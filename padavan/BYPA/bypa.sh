#!/bin/sh
# versin v2.01
# 定时命令
# */1 * * * * /etc/storage/bypa.sh start

LOGFILE="/tmp/log/bypa.log"
# 获取旁路由mac地址，必填(或填ipv4地址)
BYP_MAC=`nvram get bypa_macaddr_x`

# 获取旁路由ipv4地址
BYP_IP4=`nvram get bypa_ipaddr_x`

# 我的旁路由ip
[ -z "$BYP_IP4" -a -z "$BYP_MAC" ] && logger -t "【BYPA】" "需填写旁路由IP或mac地址，脚本退出" && exit 0
[ -z "$BYP_IP4" ] && BYP_IP4=`cat /proc/net/arp | grep -i "$BYP_MAC" | awk -F " " '{print $1}' 2>/dev/null`

# 通过ipv4地址获取mac
[ -z "$BYP_MAC" ] && BYP_MAC=`cat /proc/net/arp | grep -w "$BYP_IP4" | awk -F " " '{print $4}'`

# 获取旁路由ipv6地址
BYP_IP6=`ip -6 neighbor show | grep -i "$BYP_MAC" | sed -n '1p' | awk -F " " '{print $1}' 2>/dev/null`

# 解锁网易云pac地址
BYP_PAC=`nvram get bypa_pac_url`
#BYP_PAC="http://10.0.0.2/music.pac"

# 添加dhcp_option
add_dhcp()
{
	sed -i "/#added by bypa/d" /etc/storage/dnsmasq/dnsmasq.conf
	# 只指定greatwall的mac网关为旁路由ip，会得不到nat1
	# 使用dhcp-mac=dhcp-mac=set:greatwall,<MAC address>标记需要科学的mac地址
	echo "dhcp-option=greatwall,3,$BYP_IP4" "#added by bypa" > /tmp/bypa.conf
	echo "dhcp-option=lan,6,$BYP_IP4" "#added by bypa" >> /tmp/bypa.conf
	[ ! -z "$BYP_IP6" ] && echo "dhcp-option=lan,option6:23,[$BYP_IP6]" "#added by bypa" >> /tmp/bypa.conf
	[ ! -z "$BYP_PAC" ] && echo "dhcp-option=lan,252,$BYP_PAC" "#added by bypa" >> /tmp/bypa.conf
	# 额外设置，比如指定dhcp-option-force
	extra_setting_num=`nvram show | grep "bypa_ex_set_x"`
	for es in $extra_setting_num
	do 
		[ -n `awk -F "=" '{print $2}'` ] && echo $es "#added by bypa" >> /tmp/bypa.conf
	done
	cat /tmp/bypa.conf >> /etc/storage/dnsmasq/dnsmasq.conf
  	/sbin/restart_dhcpd
	rm /tmp/bypa.conf
	logger -t "【BYPA】" "旁路由上线，开始调整dhcp选项"
}

# 删除dhcp_option
del_dhcp()
{
	sed -i "/#added by bypa/d" /etc/storage/dnsmasq/dnsmasq.conf
	/sbin/restart_dhcpd
}
# 检测旁路由是否上线
byp_online(){
	# 主路由为padavan，配合旁路由ss的脚本，旁路由开ssr服务端，不可用，原因未知，可能是没有从wan口进来
#	gfwlist=`cat /tmp/dnsmasq.dom/gfwlist_list.conf 2>/dev/null | grep 127.0.0.1#`
#	ss_enabled=`ps | grep /usr/bin/ssr-redir 2>/dev/null | grep -v grep`
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
	[ -n "$BYP_IP6" ] && al_exit=`cat /etc/storage/dnsmasq/dnsmasq.conf | grep "23,[$BYP_IP6]"` || al_exit="1"
	(time nslookup www.baidu.com $BYP_IP4 ) 2> /tmp/bypa.log
	time=`cat /tmp/bypa.log | grep real | awk '{print $3}' | awk -F "." '{print $1}'`
	if [ "$time"x == "0"x ]; then
		[ -z "$al_exit" -o -z "$al_online" ] && add_dhcp
		exit 0
	else
		#/usr/sbin/ether-wake -b $BYP_MAC -i eth2 #尝试唤醒
		if [ -n "$al_exit" -a "$al_exit" -ne "1" ] || [ -n "$al_online" ]; then
			logger -t "【BYPA】" "旁路由下线，开始调整dhcp选项" && del_dhcp
		fi
	fi
}

case $1 in
start)
    	byp_online
	;;
*)
	logger -t "【BYPA】" "参数错误"
	;;
esac
