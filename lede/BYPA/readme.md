旁路由辅助脚本

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
* 添加pac文件，在/www 目录中添加 music.pac文件
* 如果使用了AdGuardHome 需要放行网易云域名
----
### 已知问题
* 有时不能正确获取旁路由的ipv6地址（主路由的NDP不能正确更新）
* youtube广告走国内通道

