## pip安装到指定目录
```
pip install -t /目录 package_name
```
----------
## 添加执行路径
```
在site-package目录添加 *.pth文件，内容为包路径
```
---------------
## python库通用，可以在电脑上安装再放在路由器或其它地方上
* 不需要进行gcc编译的库均可
```
# 寻找安装路径
pip3 show PKG_NAME
# 复制需要的文件到可视目录
cp -r python3.6 /mnt/g/test/py
```
* 直接将```PKG_NAME```和```PKG_NAME.info```复制到设备上并添加```.pth```即可
----------------
