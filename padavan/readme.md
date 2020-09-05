## padavan脚本
--------
##  [chongshengB的padavan](https://github.com/chongshengB/rt-n56u)
* 很完美，并且会逐步完善，喜欢padavan的同学可以去fork一下
------
## IPTV融合
### 单线复用（只有选中的端口可用，且端口不能上网）
* 选择IPTV STB 端口，填写标记iptv的vid
### 单线复用（每个端口都能用ao）
* 标记iptv的vid，并执行命令``` switch vlan set 37 1111111 0 0 ttttttt ```
* 37 是我的IPTV VID
* 不需要在wan口设置添加vlan
-------
## 放行wan口samba访问
* 在防火墙后面添加
```
logger -t "【SAMBA服务器】" "允许SAMBA访问"
iptables -I INPUT 1 -p udp -m multiport --dport 137,138 -j ACCEPT 
iptables -I INPUT 1 -p tcp -m state --state NEW -m multiport --dport 139,445 -j ACCEPT
sed -i 's/interfaces =.*/interfaces = eth2.2 br0/' /etc/smb.conf
/bin/kill -9 `pidof smbd`
smbd -D -s /etc/smb.conf
```
-----
## 问题
1. 路由器无法访问https://raw.githubusercontent.com
* 解决：在 自定义配置文件 "dnsmasq.servers" 中添加``` server=/raw.githubusercontent.com/8.8.8.8#53 ```
~~* 不能nat1~~
