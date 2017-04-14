#LSNR
当前脚本适用于 [routeros-mipsbe-6.38.5](http://download2.mikrotik.com/routeros/6.38.5/routeros-mipsbe-6.38.5.npk)  版本 
 LSNR.rsc 适用硬件型号：
```
LSNR.R (主路由器): 750系列（750Gr2、750Gr3)、850G、952Ui系列、962系列、960系列。
LSNR.P (有线与无线扩展):wAP 系列、952Ui系列、962Ui系列。
```

##变量设定 
```
# system 相关函数定义
# 说明 设备名称（客户名称或者其他标记）
:global routeridentity LSNR-Router;
# 说明 设备安装地址 
:global location ShangHai;
# 说明 设备安装人员联系方式 
:global contact 1300000000;
# DNS劫持 开启=0 关闭=1
:global dnsmode 0
# TopUrl 开启=0 关闭=1
:global topurl 0


# w1 相关函数定义
# 说明 W1 接入模式 PPPoe = 0 DHCP = 1 StaticIP = 2 disabled = 3
:global w1mode 0
# 说明 W1 pppoe 账号
:global w1usr pppoeuser;
# 说明 W1 pppoe 密码
:global w1pw pppoepw;
# 说明 W1 Static IP
:global w1ip 192.168.1.189/24;
# 说明 W1 Static GW
:global w1gw 192.168.1.1;
# 说明 W1 无线 SSID
:global w1ssid i189;
# 说明 W1 无线 密码
:global w1ssidpw Hello189;
# 说明 W1 是否禁用
:global w1disabled no;

# cn2 相关函数定义
# 说明 VPN 账号
:global cn2usr lsnuser;
# 说明 VPN 密码
:global cn2pw lsnpw;
# 说明 VPN 无线名称
:global cn2ssid LSN;
# 说明 VPN 无线密码
:global cn2ssidpw Hello189;
# 说明 是否禁用VPN服务
:global cn2disabled no;
# 说明 VPN接入服务器地址
:global cn2server ca17.189lab.cn;
# 说明 VPN接入协议 PPTP = 1 L2TP = 2 SSTP = 3
:global cn2mode 3;
# 说明 L2TP 预知共享密钥
:global cn2secret ca17;
```


##使用说明
  设备版本升级至 6.38 ，把LSNR.rsc 拖放到 flash/ 目录下。
```
/system reset-configuration no-defaults=yes run-after-reset=flash/LSNR.rsc
```
  执行以上命令进行配置导入