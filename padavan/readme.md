## padavan脚本
--------
##  [chongshengB的padavan](https://github.com/chongshengB/rt-n56u)
* 很完美，并且会逐步完善，喜欢padavan的同学可以去fork一下
------
## IPTV融合
### 单线复用（只有选中的端口可用，且端口不能上网）
* 选择IPTV STB 端口，填写标记iptv的vid
### 单线复用（每个端口都能用）
* 标记iptv的vid，并执行命令``` switch vlan set 37 1111111 0 0 ttttttt ```
-------
## 问题
1. 路由器无法访问https://raw.githubusercontent.com
* 解决：在 自定义配置文件 "dnsmasq.servers" 中添加``` server=/raw.githubusercontent.com/8.8.8.8#53 ```

