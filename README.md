#LSNR
当前脚本适用于 [routeros-mipsbe-6.37](http://download2.mikrotik.com/routeros/6.37/routeros-mipsbe-6.37.npk)  版本 
 LSNR.rsc 适配设备型号：
```
 hEX lite
 hEX PoE lite
 hEX
 hAP
 hAP ac lite
 hAP ac
 RB951Ui-2HnD
 RB951G-2HnD
 RB850G
```

##变量设定 
```
:global w1mode 0; 		# 说明 W1 接入模式 PPPoe = 0 dynamicIP = 1 StaticIP = 2
:global w1usr w1user; 		# 说明 W1 pppoe 账号
:global w1pw w1password;	# 说明 W1 pppoe 密码
:global w1ip 111.30.64.211/29; 	# 说明 W1 Static IP
:global w1gw 111.30.64.210;	# 说明 W1 Static GW
:global w1ssid i1-189;		# 说明 W1 无线 SSID
:global w1ssidpw Hello189;	# 说明 W1 无线 密码
:global w1disabled no;		# 说明 W1 是否禁用

:global w2mode 1		# 说明 W1 接入模式 PPPoe = 0 dynamicIP = 1 StaticIP = 2
:global w2usr w2user;		# 说明 W2 pppoe 账号
:global w2pw w1password;	# 说明 W2 pppoe 密码
:global w2ip 111.30.213.211/29; # 说明 W2 Static IP
:global w2gw 111.30.213.210;	# 说明 W2 Static GW
:global w2ssid i2-139;		# 说明 W2 无线 SSID
:global w2ssidpw Hello189;	# 说明 W2 无线 密码
:global w2disabled no;		# 说明 W2 是否禁用

:global cn2usr lsnuser;		# 说明 LSN 账号
:global cn2pw lsnpassword;	# 说明 LSN 密码
:global cn2ssid LSN;		# 说明 LSN 无线名称
:global cn2ssidpw Hello189;	# 说明 LSN 无线密码
:global cn2disabled no;		# 说明 是否禁用VPN服务
:global cn2server ca17.189lab.cn;# 说明 VPN接入服务器地址
:global cn2mode 3;		# 说明 VPN接入协议 PPTP = 1 L2TP = 2 SSTP = 3
:global cn2secret ca17;		# 说明 L2TP 预知共享密钥
  
```


##使用说明
  设备版本升级至 6.37 ，把LSNR.rsc 拖放到 flash/ 目录下。
```
/system reset-configuration no-defaults=yes run-after-reset=flash/LSNR.rsc
```
  执行以上命令进行配置导入