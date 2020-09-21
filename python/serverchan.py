# encoding:utf-8
import requests
SCKEY = ""
api = "https://sc.ftqq.com/" + SCKEY + ".send"
title = u"紧急通知"
content = """
---------
#服务器又炸啦！
---------
##请尽快修复服务器
--------
"""
data = {
   "text":title,
   "desp":content
}
req = requests.post(api,data = data)
