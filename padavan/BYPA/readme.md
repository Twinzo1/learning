## 旁路由设置（padavan主路由）
* 其它设置可参照lede版

----
### 如何添加进路由器
#### 方法一：本地
* 使用ttyd，vi /etc/storage/bypa.sh
* 复制bypa.sh的内容进去
* :wq 保存退出
* chmod 755 /etc/storage/bypa.sh
* mtd_storage.sh save

#### 方法二：远程下载
* 在自定义脚本防火墙前或开机启动后执行添加:
```
logger -t "【BYPA】" "正在下载旁路由辅助脚本"
if [ ! -e "/etc/storage/bypa.sh" ]; then
    curl -k -s -o /etc/storage/bypa.sh --connect-timeout 10 --retry 3 https://raw.githubusercontent.com/Twinzo1/learning/master/padavan/BYPA/bypa.sh -v
    chmod 755 /etc/storage/bypa.sh && mtd_storage.sh save
    /etc/storage/bypa.sh start
else
    logger -t "【BYPA】" "脚本已存在，无需下载"
fi
```
------------
### 添加定时命令
* ``` */1 * * * * /etc/storage/bypa.sh start ```
-----
### 指定不同网关
* ```dhcp-mac=set:<tag>,<MAC address>```设置标签
* ```dhcp-option=<tag>,3,10.0.0.02```设置网关为10.0.0.2
* openwrt同样适用
### 重要
* 使用旁路由网关，网速会下降，上行为0，。需要旁路由添加```iptables -t nat -I POSTROUTING -j MASQUERADE```
* 当不能上国内网时，重启防火墙
* 若非单网卡，需指定```-o eth0```网卡，添加之后同样下行降低，但上行不变（或许是本来就低）
* 脚本内容需要填写
* 不能实现nat1，~~目前方式是旁路由也打开fullcone nat，但电脑开了防火墙后不能检测出nat类型，关闭则是fullcone nat~~，尚待商榷
* 若要nat1，则主路由使用openwrt
