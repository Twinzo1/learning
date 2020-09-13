# 旁路由辅助脚本
## 软路由使用技巧
* 若使用U盘启动，只有50多或更少的overlay空间，可以先自己添加一些文件占据usr或其他目录的一些空间，以防有些程序抽风或操作有问题使得overlay空间减少且不知原因
----
# 必须重视的问题
* ~~千万不要填dns为主路由的IP！！！~~
* ~~填了之后将导致不能连接~~
* lan口的物理接口千万不要点错，否则可能导致ipv4链路不通
* ipv4地址上不去，就用ipv6地址上去，在主路由添加hosts```240e:63:42ac::1 bypa.cn```
-----
### 该脚本实现dhcp option的删除与添加自动化，进一步诠释旁路由的“旁”字。
### 旁路由掉线后不影响网络的正常使用，上线后自动使用旁路由的功能
-----
### 设置（网关模式）
* 主路由开dhcp，旁路由关dhcp，旁路由为网关服务器，所有设备自动设置dns和网关
* 主路由什么都不设置，网关和DNS都不需要设置，只需要设置dhcp option 和 ipv6的dns服务器通告
* 旁路由需要新建lan6以使用ipv6地址
* 旁路由设置网关为主路由ip，dns为127.0.0.1
* 均需要在DHCP/DNS处取消勾选“禁用ipv6解析”
------
### 解锁网易云设置
* 使用node版解锁
* 自定义音源：kuwo qq migu kugou xiami baidu netease
* smartdns中屏蔽网易云ipv6地址，或许需要设置一次代理，取消，才能自动解锁（已知windows需要）
* 若只使用AdGuardHome 则添加DNS重写为A记录
* 添加pac文件，在/www 目录中添加 music.pac文件
* 如果使用了AdGuardHome 需要放行网易云域名
----
### rclone挂载
* ```rclone mount teacher: /mnt/teacher --config /mnt/sda3/etc/rclone/rclone.conf --allow-other --allow-non-empty --vfs-cache-mode writes &```
-----
### 进阶设置
* 可用```dhcp-mac```设置标签，实现ssr的走代理模式，适用于有旁路由的模式，具体可参考padavan描述
-----
### 已解决问题
* 有些网站显示ssl错误，```ERR_SSL_PROTOCOL_ERROR```，尝试切换ssr+运行模式
* www.googleapis.com 是youtube app上网的域名
-----
### 已知问题
* 有时不能正确获取旁路由的ipv6地址（主路由的NDP不能正确更新）
* youtube广告走国内通道
* AdGuardHome 暂时不支持ipset，需要设为dnsmasq上游服务器
* ipv6网关还是主路由，可用option6指定网关（暂时没有需求）

