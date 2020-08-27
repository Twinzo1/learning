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
    curl -k -s -o /etc/storage/bypa.sh --connect-timeout 10 --retry 3 https://raw.githubusercontent.com/Twinzo1/learning/master/padavan/BYPA/bypa.sh
    mtd_storage.sh save
    chmod 755 /etc/storage/bypa.sh && /etc/storage/bypa.sh check
else
    logger -t "【BYPA】" "脚本已存在，无需下载"
fi
```
------------
### 添加定时命令
* ``` */1 * * * * /etc/storage/bypa.sh check ```
