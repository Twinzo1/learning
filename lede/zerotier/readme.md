## zerotier使用问题
------------
### arp发现远程ip没有正确的mac地址和出口,但ping值正常时
* 例
```
root@ZSH:/# arp | grep 10.0.0.2
10.0.0.2         0x1         0x0         00:00:00:00:00:00     *        br-lan
```
* 使用命令
```
# ip neigh del 10.0.0.2 dev br-lan
ip neigh add 10.0.0.2 lladdr 36:31:0e:cc:ae:e5 dev zt7nngkq5o nud perm
```
* 删了```ip neigh del 10.0.0.2 dev br-lan```后还是会出现，所以就不删了
-------------
