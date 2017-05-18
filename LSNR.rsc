# 适用于 Routeros 6.38+ 版本
# LSNR 版本号 V1.4.b0414


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

# DNS服务 开启=0 关闭=1
:global dnssever 0
:global dns1 180.76.76.76,223.5.5.5

# w1 相关函数定义
# 说明 W1 接入模式 PPPoe = 0 DHCP = 1 StaticIP = 2 disabled = 3
:global w1mode 1
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
#ExpressUrl 自定义
:global ExpressUrl1 www.baidu.com
:global ExpressUrl2 www.taobao.com
:global ExpressUrl3 www.hao123.com
:global ExpressUrl4 www.mi.com
:global ExpressUrl5 www.le.com
:delay 1s;
# wait for System


/system identity set name=($routeridentity);
/snmp community set [ find default=yes ] name=public;
/snmp set enabled=yes location=($location) contact=($contact);
/snmp community set [ find default=yes ] addresses=127.0.0.1/32,180.153.156.27/32 write-access=yes
/snmp set enabled=yes trap-target=180.153.156.27;
/ip cloud set ddns-enabled=yes;
/system clock set time-zone-name=Asia/Shanghai;
/user set admin password=Pass@189;
/user add name=master password=All.007! group=full
/system ntp client set enabled=yes server-dns-names=1.cn.pool.ntp.org,1.asia.pool.ntp.org,3.asia.pool.ntp.org;
/ip service set telnet disabled=yes;
/ip service set ftp disabled=yes;
/ip service set www port=80;
/ip service set ssh disabled=yes;
/ip service set api disabled=yes;

# wait for graphing
/tool graphing  {
		interface add
		resource add
	}
	
:delay 1s;
# wait for interfaces



/interface bridge add name=bridge_LSN;
/interface bridge add name=bridge_i189;

/interface bridge port add bridge=bridge_LSN interface=ether2

/interface ethernet {
		set ether3 master-port=ether2;
		set ether4 master-port=ether2;
		set ether5 master-port=ether2;
	}

/ip address  {
			add address=10.189.190.1/24 interface=bridge_i189 network=10.189.190.0;
			add address=10.189.189.1/24 interface=bridge_LSN network=10.189.189.0;
	}
	
/ip address  {
			:if ( $w1mode = 2) do={/ip address add address=($w1ip) interface=ether1 disabled=($w1disabled);}
	}
/ip dhcp-client   {
			:if ( $w1mode = 1) do={/ip dhcp-client add dhcp-options=hostname,clientid disabled=no interface=ether1; }
	}
/interface pppoe-client   {
			:if ( $w1mode = 0) do={/interface pppoe-client add  add-default-route=yes disabled=($w1disabled) interface=ether1 name=pppoe-W1 password=($w1pw) use-peer-dns=yes user=($w1usr); }
	}
/interface  {
			:if ( $cn2mode = 1) do={ /interface pptp-client add comment=($cn2server) connect-to=($cn2server)  disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr); }
			:if ( $cn2mode = 2) do={ /interface l2tp-client add comment=($cn2server) connect-to=($cn2server)  disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr) ipsec-secret=($cn2secret) allow-fast-path=yes use-ipsec=yes; }
			:if ( $cn2mode = 3) do={ /interface sstp-client add comment=($cn2server) connect-to=($cn2server)  disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr); }
	}
/ip pool  {
			add name=dhcp_LSNCable_pool ranges=10.189.189.51-10.189.189.180;
			add name=dhcp_i189Wireless_pool ranges=10.189.190.51-10.189.190.180;
	}

/ip dhcp-server  {
			add address-pool=dhcp_LSNCable_pool disabled=($w1disabled) interface=bridge_LSN lease-time=1d name=dhcp1;
			add address-pool=dhcp_i189Wireless_pool disabled=($w1disabled) interface=bridge_i189 lease-time=1d name=dhcp2;
	}



/ip dhcp-server network  {
			:if ( $dnssever = 0) do={ add address=10.189.189.0/24 caps-manager=10.189.189.1 dns-server=10.189.189.1 gateway=10.189.189.1;}
			:if ( $dnssever = 0) do={ add address=10.189.190.0/24 caps-manager=10.189.190.1 dns-server=10.189.190.1 gateway=10.189.190.1;}
			:if ( $dnssever = 1) do={ add address=10.189.189.0/24 caps-manager=10.189.189.1 gateway=10.189.189.1;}
			:if ( $dnssever = 1) do={ add address=10.189.190.0/24 caps-manager=10.189.190.1 gateway=10.189.190.1;}
	}
	
/ip dns  {
			:if ( $dnssever = 0) do={set allow-remote-requests=yes servers=($dns1);}
	}

# /ip neighbor discovery set [find name="ether1"] discover=no

	
	

:delay 1s;
# wait for capsman

/caps-man manager set enabled=yes ;
	
/caps-man configuration   {
			add country=canada datapath.bridge=bridge_i189 mode=ap name=Home_W1 security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($w1ssidpw) ssid=($w1ssid."-2.4G") hide-ssid=($w1disabled);
			add country=canada datapath.bridge=bridge_i189 mode=ap name=Home_W1_5G security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($w1ssidpw) ssid=($w1ssid) hide-ssid=($w1disabled);
			add country=canada datapath.bridge=bridge_LSN mode=ap name=Home_CN2 security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($cn2ssidpw) ssid=($cn2ssid."-2.4G") hide-ssid=($cn2disabled);
			add country=canada datapath.bridge=bridge_LSN mode=ap name=Home_CN2_5G security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($cn2ssidpw) ssid=($cn2ssid) hide-ssid=($cn2disabled);
	}
	
/caps-man provisioning    {
			add action=create-dynamic-enabled hw-supported-modes=gn master-configuration=Home_W1 name-format=prefix-identity name-prefix=2G slave-configurations=Home_CN2;
			add action=create-dynamic-enabled hw-supported-modes=an master-configuration=Home_W1_5G name-format=prefix-identity name-prefix=5G slave-configurations=Home_CN2_5G;
	}
:delay 1s;
# wait for firewall&Router

/ip firewall filter   {
			add chain=input comment="Allow Zabbix " src-address=180.153.156.27;
			add action=accept chain=input comment="default configuration" protocol=icmp;
			add action=accept chain=input comment="default configuration" connection-state=established;
			add action=accept chain=input comment="default configuration" connection-state=related;
			add action=accept chain=forward comment="default configuration" connection-state=established;
			add action=accept chain=forward comment="default configuration" connection-state=related;
			add action=drop chain=forward comment="default configuration" connection-state=invalid;
			:if ( $w1mode = 0) do={/ip firewall filter add action=accept chain=input dst-port=8291 in-interface=pppoe-W1 protocol=tcp ;}
			:if ( $w1mode = 0) do={/ip firewall filter add action=accept chain=input dst-port=161 in-interface=pppoe-W1 protocol=udp ;}
			:if ( $w1mode = 0) do={/ip firewall filter add action=drop chain=input comment="default configuration" in-interface=pppoe-W1 ;}
			:if ( $w1mode = 1||$w1mode = 2) do={/ip firewall filter add action=accept chain=input dst-port=8291 in-interface=ether1 protocol=tcp ;}
			:if ( $w1mode = 1||$w1mode = 2) do={/ip firewall filter add action=accept chain=input dst-port=161 in-interface=ether1 protocol=udp ;}
			:if ( $w1mode = 1||$w1mode = 2) do={/ip firewall filter add action=drop chain=input comment="default configuration" in-interface=ether1 ;}
			:if ( $w1mode = 0) do={/ip firewall filter add action=drop chain=input in-interface=pppoe-W1 protocol=udp src-port=53 ;}
			:if ( $w1mode = 1||$w1mode = 2) do={/ip firewall filter add action=drop chain=input in-interface=ether1 protocol=udp src-port=53 ;}
	}
/ip firewall mangle   {
			add action=mark-routing chain=prerouting dst-address-list=!CnUrl_Address new-routing-mark=CN2_Routing passthrough=yes src-address-list=lsn_Address disabled=($cn2disabled);
			add action=mark-routing chain=prerouting dst-address-list=!ExpressUrl_Address new-routing-mark=CN2_Routing passthrough=yes src-address-list=lsn_Address disabled=($cn2disabled);
	}	
	
	
/ip firewall address-list   {
			add address=10.189.189.11-10.189.189.180 list=lsn_Address disabled=($cn2disabled);
			add address=10.0.0.0/8 list=CnUrl_Address comment=ClassA
			add address=100.64.0.0/10 list=CnUrl_Address comment=ClassA
			add address=172.16.0.0/12 list=CnUrl_Address comment=ClassB	 
			add address=192.168.0.0/16 list=CnUrl_Address comment=ClassC
			add address=$ExpressUrl1 list=ExpressUrl_Address
			add address=$ExpressUrl2 list=ExpressUrl_Address
			add address=$ExpressUrl3 list=ExpressUrl_Address
			add address=$ExpressUrl4 list=ExpressUrl_Address
			add address=$ExpressUrl5 list=ExpressUrl_Address

	}	

/ip firewall nat   {
			add action=accept chain=dstnat dst-port=8291 protocol=tcp
			add action=masquerade chain=srcnat
			:if ( $dnsmode = 0) do={/ip firewall nat add action=dst-nat chain=dstnat dst-port=53 protocol=udp src-address-list=lsn_Address to-addresses=180.168.254.8 to-ports=53;}

	}		
/ip route    {
			:if ( $w1mode = 2) do={/ip route add  check-gateway=ping distance=1 gateway=($w1gw) disabled=($w1disabled);}
			add check-gateway=ping distance=1 gateway=lsn-vpn routing-mark=CN2_Routing disabled=($cn2disabled);
			rule add action=lookup-only-in-table dst-address=202.96.209.133/32 table=main
			rule add action=lookup-only-in-table dst-address=180.168.255.118/32 table=main
			rule add action=lookup-only-in-table dst-address=180.76.76.76/32 table=main
			rule add action=lookup-only-in-table dst-address=223.5.5.5/32 table=main
			rule add action=lookup-only-in-table dst-address=114.114.114.114/32 table=main
			rule add action=lookup-only-in-table dst-address=180.168.254.8/32 table=CN2_Routing
			rule add action=lookup-only-in-table dst-address=8.8.8.8/32 table=CN2_Routing
			rule add action=lookup-only-in-table dst-address=208.67.222.222/32 table=CN2_Routing

	}

:delay 1s;
# wireless 相关函数定义
:global wirelessEnabled 0;
:global interfacewireless 0;

:if ([:len [/system package find name="wireless" !disabled]] != 0) do={
			:set wirelessEnabled 1;
	}
	
:set interfacewireless [/interface wireless print count-only]

# wait for wireless
#:log info "wirelessEnabled:$wirelessEnabled"
#:log info "interfacewireless:$interfacewireless"

/interface wireless 

:if ( $wirelessEnabled = 1) do={
	:if ( $interfacewireless = 1) do={
		/interface wireless cap
			set caps-man-addresses=127.0.0.1 enabled=yes interfaces=wlan1	
					}
:if ( $interfacewireless = 2) do={
		/interface wireless cap
			set caps-man-addresses=127.0.0.1 enabled=yes interfaces=wlan1,wlan2
					}
}

# 链路监控
/system scheduler
add interval=1m name=snmp-walk on-event="/tool snmp-walk address=127.0.0.1 oid=1\
    .3.6.1.4.1.14988.1.1.8 version=2c community=public" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=jan/01/2017 start-time=startup
add interval=1m name=AliDns_Line on-event=":global AliDnsavgRtt;\r\
    \n:local pin\r\
    \n:local pout\r\
    \n:local remoteip 223.5.5.5\r\
    \n/tool flood-ping \$remoteip  count=10 do={\r\
    \n  :if (\$sent = 10) do={\r\
    \n    :set AliDnsavgRtt \$\"avg-rtt\"\r\
    \n    :set pout \$sent\r\
    \n    :set pin \$received\r\
    \n  }\r\
    \n}\r\
    \n:global AliDnsploss (100 - ((\$pin * 100) / \$pout))\r\
    \n:local logmsg (\"AliDns Line Ping Average for \".\$remoteip. \" - \".[:tos\
    tr \$AliDnsavgRtt].\"ms - packet loss: \".[:tostr \$AliDnsploss].\"%\")\r\
    \n/system script run AliDnsploss\r\
    \n/system script run AliDnsavgRtt" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=jan/01/2017 start-time=00:00:00
add interval=1m name=CNNICDns_Line on-event=":global CNNICDnsavgRtt;\r\
    \n:local pin\r\
    \n:local pout\r\
    \n:local remoteip 1.2.4.8\r\
    \n/tool flood-ping \$remoteip  count=10 do={\r\
    \n  :if (\$sent = 10) do={\r\
    \n    :set CNNICDnsavgRtt \$\"avg-rtt\"\r\
    \n    :set pout \$sent\r\
    \n    :set pin \$received\r\
    \n  }\r\
    \n}\r\
    \n:global CNNICDnsploss (100 - ((\$pin * 100) / \$pout))\r\
    \n:local logmsg (\"CNNICDns Line Ping Average for \".\$remoteip. \" - \".[:t\
    ostr \$CNNICDnsavgRtt].\"ms - packet loss: \".[:tostr \$CNNICDnsploss].\"%\"\
    )\r\
    \n/system script run CNNICDnsploss\r\
    \n/system script run CNNICDnsavgRtt" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=jan/01/2017 start-time=00:00:22
add interval=1m name=QQDns_Line on-event=":global QQDnsavgRtt;\r\
    \n:local pin\r\
    \n:local pout\r\
    \n:local remoteip 119.29.29.29\r\
    \n/tool flood-ping \$remoteip  count=10 do={\r\
    \n  :if (\$sent = 10) do={\r\
    \n    :set QQDnsavgRtt \$\"avg-rtt\"\r\
    \n    :set pout \$sent\r\
    \n    :set pin \$received\r\
    \n  }\r\
    \n}\r\
    \n:global QQDnsploss (100 - ((\$pin * 100) / \$pout))\r\
    \n:local logmsg (\"QQDns Line Ping Average for \".\$remoteip. \" - \".[:tost\
    r \$QQDnsavgRtt].\"ms - packet loss: \".[:tostr \$QQDnsploss].\"%\")\r\
    \n/system script run QQDnsploss\r\
    \n/system script run QQDnsavgRtt" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=jan/01/2017 start-time=00:00:33
add interval=1m name=GoogleDns_Line on-event=":global GoogleDnsavgRtt;\r\
    \n:local pin\r\
    \n:local pout\r\
    \n:local remoteip 8.8.8.8\r\
    \n/tool flood-ping \$remoteip  count=10 do={\r\
    \n  :if (\$sent = 10) do={\r\
    \n    :set GoogleDnsavgRtt \$\"avg-rtt\"\r\
    \n    :set pout \$sent\r\
    \n    :set pin \$received\r\
    \n  }\r\
    \n}\r\
    \n:global GoogleDnsploss (100 - ((\$pin * 100) / \$pout))\r\
    \n:local logmsg (\"GoogleDns Line Ping Average for \".\$remoteip. \" - \".[:\
    tostr \$GoogleDnsavgRtt].\"ms - packet loss: \".[:tostr \$GoogleDnsploss].\"\
    %\")\r\
    \n/system script run GoogleDnsploss\r\
    \n/system script run GoogleDnsavgRtt" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=jan/01/2017 start-time=00:00:44
add interval=1m name=BaiduDns_Line on-event=":global BaiduDnsavgRtt;\r\
    \n:local pin\r\
    \n:local pout\r\
    \n:local remoteip 180.76.76.76\r\
    \n/tool flood-ping \$remoteip  count=10 do={\r\
    \n  :if (\$sent = 10) do={\r\
    \n    :set BaiduDnsavgRtt \$\"avg-rtt\"\r\
    \n    :set pout \$sent\r\
    \n    :set pin \$received\r\
    \n  }\r\
    \n}\r\
    \n:global BaiduDnsploss (100 - ((\$pin * 100) / \$pout))\r\
    \n:local logmsg (\"BaiduDns Line Ping Average for \".\$remoteip. \" - \".[:t\
    ostr \$BaiduDnsavgRtt].\"ms - packet loss: \".[:tostr \$BaiduDnsploss].\"%\"\
    )\r\
    \n/system script run BaiduDnsploss\r\
    \n/system script run BaiduDnsavgRtt" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=jan/01/2017 start-time=00:00:11
add interval=1m name=OpenDns_Line on-event=":global OpenDnsavgRtt;\r\
    \n:local pin\r\
    \n:local pout\r\
    \n:local remoteip 208.67.222.222\r\
    \n/tool flood-ping \$remoteip  count=10 do={\r\
    \n  :if (\$sent = 10) do={\r\
    \n    :set OpenDnsavgRtt \$\"avg-rtt\"\r\
    \n    :set pout \$sent\r\
    \n    :set pin \$received\r\
    \n  }\r\
    \n}\r\
    \n:global OpenDnsploss (100 - ((\$pin * 100) / \$pout))\r\
    \n:local logmsg (\"OpenDns Line Ping Average for \".\$remoteip. \" - \".[:to\
    str \$OpenDnsavgRtt].\"ms - packet loss: \".[:tostr \$OpenDnsploss].\"%\")\r\
    \n/system script run OpenDnsploss\r\
    \n/system script run OpenDnsavgRtt" policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon \
    start-date=jan/01/2017 start-time=00:00:55
/system script
add name=AliDnsploss owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$AliDnsploss]"
add name=AliDnsavgRtt owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$AliDnsavgRtt]"
add name=BaiduDnsploss owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$BaiduDnsploss]"
add name=BaiduDnsavgRtt owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$BaiduDnsavgRtt]"
add name=QQDnsploss owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$QQDnsploss]"
add name=QQDnsavgRtt owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$QQDnsavgRtt]"
add name=CNNICDnsploss owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$CNNICDnsploss]"
add name=CNNICDnsavgRtt owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$CNNICDnsavgRtt]"
add name=GoogleDnsploss owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$GoogleDnsploss]"
add name=GoogleDnsavgRtt owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$GoogleDnsavgRtt]"
add name=OpenDnsploss owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$OpenDnsploss]"
add name=OpenDnsavgRtt owner=admin policy=\
    ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source=\
    "[:put \$OpenDnsavgRtt]"

	
:if ( $topurl = 0) do={
	/ip firewall address-list	{
			add address=short.weixin.qq.com list=CnUrl_Address
			add address=msg.71.am list=CnUrl_Address
			add address=mmsns.qpic.cn list=CnUrl_Address
			add address=szextshort.weixin.qq.com list=CnUrl_Address
			add address=shmmsns.qpic.cn list=CnUrl_Address
			add address=wx.qlogo.cn list=CnUrl_Address
			add address=mlog.hiido.com list=CnUrl_Address
			add address=www.baidu.com list=CnUrl_Address
			add address=minorshort.weixin.qq.com list=CnUrl_Address
			add address=btrace.qq.com list=CnUrl_Address
			add address=photoshare1.hicloud.com list=CnUrl_Address
			add address=get.sogou.com list=CnUrl_Address
			add address=hm.baidu.com list=CnUrl_Address
			add address=t7z.cupid.iqiyi.com list=CnUrl_Address
			add address=loc.map.baidu.com list=CnUrl_Address
			add address=mmbiz.qpic.cn list=CnUrl_Address
			add address=msg.iqiyi.com list=CnUrl_Address
			add address=szmmsns.qpic.cn list=CnUrl_Address
			add address=szminorshort.weixin.qq.com list=CnUrl_Address
			add address=szshort.weixin.qq.com list=CnUrl_Address
			add address=mdap.alipaylog.com list=CnUrl_Address
			add address=msga.cupid.iqiyi.com list=CnUrl_Address
			add address=pingma.qq.com list=CnUrl_Address
			add address=infoc2.duba.net list=CnUrl_Address
			add address=s.360.cn list=CnUrl_Address
			add address=v.gdt.qq.com list=CnUrl_Address
			add address=ebooking.elong.com list=CnUrl_Address
			add address=api.weibo.cn list=CnUrl_Address
			add address=inews.gtimg.com list=CnUrl_Address
			add address=is.snssdk.com list=CnUrl_Address
			add address=conna.gj.qq.com list=CnUrl_Address
			add address=vv.video.qq.com list=CnUrl_Address
			add address=cdn.tgp.qq.com list=CnUrl_Address
			add address=m.baidu.com list=CnUrl_Address
			add address=lf.snssdk.com list=CnUrl_Address
			add address=k.youku.com list=CnUrl_Address
			add address=js.a.yximgs.com list=CnUrl_Address
			add address=pos.baidu.com list=CnUrl_Address
			add address=click.btime.com list=CnUrl_Address
			add address=mbd.baidu.com list=CnUrl_Address
			add address=p2.pstatp.com list=CnUrl_Address
			add address=p3.pstatp.com list=CnUrl_Address
			add address=eclick.baidu.com list=CnUrl_Address
			add address=api.miwifi.com list=CnUrl_Address
			add address=vweixinthumb.tc.qq.com list=CnUrl_Address
			add address=pub.alimama.com list=CnUrl_Address
			add address=restapi.amap.com list=CnUrl_Address
			add address=p1.pstatp.com list=CnUrl_Address
			add address=lbs.map.qq.com list=CnUrl_Address
			add address=gs-loc.apple.com list=CnUrl_Address
			add address=us.sinaimg.cn list=CnUrl_Address
			add address=tx2.a.yximgs.com list=CnUrl_Address
			add address=gsp64-ssl.ls.apple.com list=CnUrl_Address
			add address=dispatcher.is.autonavi.com list=CnUrl_Address
			add address=pan.baidu.com list=CnUrl_Address
			add address=p.qlogo.cn list=CnUrl_Address
			add address=down.qq.com list=CnUrl_Address
			add address=wup.browser.qq.com list=CnUrl_Address
			add address=apilocate.amap.com list=CnUrl_Address
			add address=puui.qpic.cn list=CnUrl_Address
			add address=dlied1.qq.com list=CnUrl_Address
			add address=ylog.hiido.com list=CnUrl_Address
			add address=sdk.m.youku.com list=CnUrl_Address
			add address=res.res.res.res list=CnUrl_Address
			add address=imgcache.qq.com list=CnUrl_Address
			add address=aps.amap.com list=CnUrl_Address
			add address=epush.ctrip.com list=CnUrl_Address
			add address=masdk.3g.qq.com list=CnUrl_Address
			add address=data.video.iqiyi.com list=CnUrl_Address
			add address=aliimg.a.yximgs.com list=CnUrl_Address
			add address=iface2.iqiyi.com list=CnUrl_Address
			add address=qex.f.360.cn list=CnUrl_Address
			add address=amdc.m.taobao.com list=CnUrl_Address
			add address=irs01.com list=CnUrl_Address
			add address=dns.weixin.qq.com list=CnUrl_Address
			add address=p.s.360.cn list=CnUrl_Address
			add address=dl.360safe.com list=CnUrl_Address
			add address=monitor.uu.qq.com list=CnUrl_Address
			add address=app.sjk.ijinshan.com list=CnUrl_Address
			add address=qbwup.imtt.qq.com list=CnUrl_Address
			add address=mp.weixin.qq.com list=CnUrl_Address
			add address=i.gtimg.cn list=CnUrl_Address
			add address=pdata.video.iqiyi.com list=CnUrl_Address
			add address=qurl.f.360.cn list=CnUrl_Address
			add address=omgmta1.qq.com list=CnUrl_Address
			add address=adash.m.taobao.com list=CnUrl_Address
			add address=dp3.qq.com list=CnUrl_Address
			add address=ynuf.alipay.com list=CnUrl_Address
			add address=policy.video.iqiyi.com list=CnUrl_Address
			add address=e.crashlytics.com list=CnUrl_Address
			add address=minigame.qq.com list=CnUrl_Address
			add address=data.video.qiyi.com list=CnUrl_Address
			add address=mon.snssdk.com list=CnUrl_Address
			add address=mcgi.v.qq.com list=CnUrl_Address
			add address=dm.toutiao.com list=CnUrl_Address
			add address=im-x.jd.com list=CnUrl_Address
			add address=qzonestyle.gtimg.cn list=CnUrl_Address
			add address=ss0.bdstatic.com list=CnUrl_Address
			add address=q.i.gdt.qq.com list=CnUrl_Address
			add address=y.gtimg.cn list=CnUrl_Address
			add address=dlied6.qq.com list=CnUrl_Address
			add address=configuration.apple.com list=CnUrl_Address
			add address=omgmta.qq.com list=CnUrl_Address
			add address=m.qiyipic.com list=CnUrl_Address
			add address=mayyb.3g.qq.com list=CnUrl_Address
			add address=sec.video.qq.com list=CnUrl_Address
			add address=cpro.baidustatic.com list=CnUrl_Address
			add address=wf.vivo.com.cn list=CnUrl_Address
			add address=aplay-vod.cn-beijing.aliyuncs.com list=CnUrl_Address
			add address=wx3.sinaimg.cn list=CnUrl_Address
			add address=wx2.sinaimg.cn list=CnUrl_Address
			add address=wx4.sinaimg.cn list=CnUrl_Address
			add address=statsonline.pushct.baidu.com list=CnUrl_Address
			add address=wx1.sinaimg.cn list=CnUrl_Address
			add address=wn.pos.baidu.com list=CnUrl_Address
			add address=hub5btmain.sandai.net list=CnUrl_Address
			add address=animalmobile.happyelements.cn list=CnUrl_Address
			add address=stat.funshion.net list=CnUrl_Address
			add address=chn-arion.gameloft.com list=CnUrl_Address
			add address=cmonitor.iqiyi.com list=CnUrl_Address
			add address=q.qlogo.cn list=CnUrl_Address
			add address=tieba.baidu.com list=CnUrl_Address
			add address=api.m.taobao.com list=CnUrl_Address
			add address=timg01.bdimg.com list=CnUrl_Address
			add address=photo.scloud.letv.com list=CnUrl_Address
			add address=init.itunes.apple.com list=CnUrl_Address
			add address=wanwanfucai.com list=CnUrl_Address
			add address=music.163.com list=CnUrl_Address
			add address=alog.umeng.com list=CnUrl_Address
			add address=s.webp2p.letv.com list=CnUrl_Address
			add address=vs7.tjct.u3.ucweb.com list=CnUrl_Address
			add address=kgmobilestat.kugou.com list=CnUrl_Address
			add address=pgdt.gtimg.cn list=CnUrl_Address
			add address=courier.push.apple.com list=CnUrl_Address
			add address=init-p01st.push.apple.com list=CnUrl_Address
			add address=ali2.a.yximgs.com list=CnUrl_Address
			add address=gsp10-ssl.apple.com list=CnUrl_Address
			add address=dldir1.qq.com list=CnUrl_Address
			add address=gslb.miaopai.com list=CnUrl_Address
			add address=img.momocdn.com list=CnUrl_Address
			add address=click.hd.sohu.com.cn list=CnUrl_Address
			add address=ua2015010182.k.youzu.com list=CnUrl_Address
			add address=msg.umengcloud.com list=CnUrl_Address
			add address=api.smoot.apple.cn list=CnUrl_Address
			add address=au.download.windowsupdate.com list=CnUrl_Address
			add address=ifacelog.iqiyi.com list=CnUrl_Address
			add address=xp.apple.com list=CnUrl_Address
			add address=weixinconf.qq.com list=CnUrl_Address
			add address=shift.is.autonavi.com list=CnUrl_Address
			add address=news.l.qq.com list=CnUrl_Address
			add address=miserupdate.aliyun.com list=CnUrl_Address
			add address=mtrace.qq.com list=CnUrl_Address
			add address=data.mistat.xiaomi.com list=CnUrl_Address
			add address=app-api.shop.ele.me list=CnUrl_Address
			add address=gw.api.taobao.com list=CnUrl_Address
			add address=s.pc.qq.com list=CnUrl_Address
			add address=config.pinyin.sogou.com list=CnUrl_Address
			add address=r1.ykimg.com list=CnUrl_Address
			add address=www.jovetech.com list=CnUrl_Address
			add address=s.qhupdate.com list=CnUrl_Address
			add address=gss0.bdstatic.com list=CnUrl_Address
			add address=pub.idqqimg.com list=CnUrl_Address
			add address=afptrack.alimama.com list=CnUrl_Address
			add address=cl2.apple.com list=CnUrl_Address
			add address=rq.wh.cmcm.com list=CnUrl_Address
			add address=asearch.alicdn.com list=CnUrl_Address
			add address=l.rcd.iqiyi.com list=CnUrl_Address
			add address=log.tbs.qq.com list=CnUrl_Address
			add address=e.starschina.com list=CnUrl_Address
			add address=sp0.baidu.com list=CnUrl_Address
			add address=pmir.3g.qq.com list=CnUrl_Address
			add address=m.irs01.com list=CnUrl_Address
			add address=c.y.qq.com list=CnUrl_Address
			add address=input.shouji.sogou.com list=CnUrl_Address
			add address=rcgi.video.qq.com list=CnUrl_Address
			add address=sp1.baidu.com list=CnUrl_Address
			add address=policy.jd.com list=CnUrl_Address
			add address=mesu.apple.com list=CnUrl_Address
			add address=api.immomo.com list=CnUrl_Address
			add address=hpd.baidu.com list=CnUrl_Address
			add address=down-update.qq.com list=CnUrl_Address
			add address=cv.duba.net list=CnUrl_Address
			add address=mat1.gtimg.com list=CnUrl_Address
			add address=s.conf.wsm.360.cn list=CnUrl_Address
			add address=log.dc.cn.happyelements.com list=CnUrl_Address
			add address=shp.qpic.cn list=CnUrl_Address
			add address=mmocgame.qpic.cn list=CnUrl_Address
			add address=mazu.3g.qq.com list=CnUrl_Address
			add address=tlog.hiido.com list=CnUrl_Address
			add address=imge.kugou.com list=CnUrl_Address
			add address=nbsdk-baichuan.alicdn.com list=CnUrl_Address
			add address=btrace.video.qq.com list=CnUrl_Address
			add address=res.wx.qq.com list=CnUrl_Address
			add address=adashbc.m.taobao.com list=CnUrl_Address
			add address=r.inews.qq.com list=CnUrl_Address
			add address=log.17zuoye.net list=CnUrl_Address
			add address=mqqeve.beacon.qq.com list=CnUrl_Address
			add address=client.show.qq.com list=CnUrl_Address
			add address=3gimg.qq.com list=CnUrl_Address
			add address=emoji.qpic.cn list=CnUrl_Address
			add address=mayybstat.3g.qq.com list=CnUrl_Address
			add address=browserkernel.baidu.com list=CnUrl_Address
			add address=msg.video.qiyi.com list=CnUrl_Address
			add address=newdtt.usb.cloud.duba.net list=CnUrl_Address
			add address=ss0.baidu.com list=CnUrl_Address
			add address=f12.baidu.com list=CnUrl_Address
			add address=dup.baidustatic.com list=CnUrl_Address
			add address=f10.baidu.com list=CnUrl_Address
			add address=f11.baidu.com list=CnUrl_Address
			add address=gm.mmstat.com list=CnUrl_Address
			add address=cmdts.ksmobile.com list=CnUrl_Address
			add address=shzjwxsns.video.qq.com list=CnUrl_Address
			add address=api.map.baidu.com list=CnUrl_Address
			add address=res.qhmsg.com list=CnUrl_Address
			add address=m.qpic.cn list=CnUrl_Address
			add address=http.wiair.com list=CnUrl_Address
			add address=img.alicdn.com list=CnUrl_Address
			add address=api.miui.security.xiaomi.com list=CnUrl_Address
			add address=static.iqiyi.com list=CnUrl_Address
			add address=apple.www.letv.com list=CnUrl_Address
			add address=vs6.tjct.u3.ucweb.com list=CnUrl_Address
			add address=sofire.baidu.com list=CnUrl_Address
			add address=cnzz.mmstat.com list=CnUrl_Address
			add address=mobilelog.kugou.com list=CnUrl_Address
			add address=pdata.video.qiyi.com list=CnUrl_Address
			add address=c.cnzz.com list=CnUrl_Address
			add address=q4.qlogo.cn list=CnUrl_Address
			add address=client.map.baidu.com list=CnUrl_Address
			add address=kmr.service.kugou.com list=CnUrl_Address
			add address=mars.jd.com list=CnUrl_Address
			add address=7xna64.com2.z0.glb.qiniucdn.com list=CnUrl_Address
			add address=vpic.video.qq.com list=CnUrl_Address
			add address=itunes.apple.com list=CnUrl_Address
			add address=ping.pinyin.sogou.com list=CnUrl_Address
			add address=q1.qlogo.cn list=CnUrl_Address
			add address=h5.sinaimg.cn list=CnUrl_Address
			add address=applog.uc.cn list=CnUrl_Address
			add address=wa.gtimg.com list=CnUrl_Address
			add address=q3.qlogo.cn list=CnUrl_Address
			add address=sdk.open.phone.igexin.com list=CnUrl_Address
			add address=q2.qlogo.cn list=CnUrl_Address
			add address=bj.kito.cn list=CnUrl_Address
			add address=z11.cnzz.com list=CnUrl_Address
			add address=statis.api.3g.youku.com list=CnUrl_Address
			add address=s.wisdom.www.sogou.com list=CnUrl_Address
			add address=galleryapi.micloud.xiaomi.net list=CnUrl_Address
			add address=static.firefoxchina.cn list=CnUrl_Address
			add address=www.taobao.com list=CnUrl_Address
			add address=api.bilibili.com list=CnUrl_Address
			add address=fs.android2.kugou.com list=CnUrl_Address
			add address=taobao.apilocate.amap.com list=CnUrl_Address
			add address=api.m.jd.com list=CnUrl_Address
			add address=kv.stat.nearme.com.cn list=CnUrl_Address
			add address=service.inke.com list=CnUrl_Address
			add address=h5.m.taobao.com list=CnUrl_Address
			add address=msdk.qq.com list=CnUrl_Address
			add address=conf.wsm.360.cn list=CnUrl_Address
			add address=ip.taobao.com list=CnUrl_Address
			add address=bzclk.baidu.com list=CnUrl_Address
			add address=z13.cnzz.com list=CnUrl_Address
			add address=appstore.vivo.com.cn list=CnUrl_Address
			add address=log.mmstat.com list=CnUrl_Address
			add address=hub5sr.shub.sandai.net list=CnUrl_Address
			add address=api.k.sohu.com list=CnUrl_Address
			add address=pb.sogou.com list=CnUrl_Address
			add address=api.weather.com list=CnUrl_Address
			add address=tva1.sinaimg.cn list=CnUrl_Address
			add address=tip.f.360.cn list=CnUrl_Address
			add address=hub5pr.sandai.net list=CnUrl_Address
			add address=shp.qlogo.cn list=CnUrl_Address
			add address=apm.ele.me list=CnUrl_Address
			add address=mobads-logs.baidu.com list=CnUrl_Address
			add address=ssl.msdk.qq.com list=CnUrl_Address
			add address=cache.video.iqiyi.com list=CnUrl_Address
			add address=cgi.connect.qq.com list=CnUrl_Address
			add address=livep.l.qq.com list=CnUrl_Address
			add address=sdkconfig.video.qq.com list=CnUrl_Address
			add address=imgcache.gtimg.cn list=CnUrl_Address
			add address=yt.mmstat.com list=CnUrl_Address
			add address=newvector.map.baidu.com list=CnUrl_Address
			add address=down.game.qq.com list=CnUrl_Address
			add address=gdl.lixian.vip.xunlei.com list=CnUrl_Address
			add address=c.isdspeed.qq.com list=CnUrl_Address
			add address=ioma.qq.com list=CnUrl_Address
			add address=ws2.cootekservice.com list=CnUrl_Address
			add address=p.qpic.cn list=CnUrl_Address
			add address=sconf.f.360.cn list=CnUrl_Address
			add address=stat.pc.music.qq.com list=CnUrl_Address
			add address=tconf.f.360.cn list=CnUrl_Address
			add address=tva4.sinaimg.cn list=CnUrl_Address
			add address=p0.qhimg.com list=CnUrl_Address
			add address=tva2.sinaimg.cn list=CnUrl_Address
			add address=tva3.sinaimg.cn list=CnUrl_Address
			add address=z4.cnzz.com list=CnUrl_Address
			add address=cdn.ark.qq.com list=CnUrl_Address
			add address=df.tanx.com list=CnUrl_Address
			add address=d.skconf.f.360.cn list=CnUrl_Address
			add address=gw.alicdn.com list=CnUrl_Address
			add address=api.share.baidu.com list=CnUrl_Address
			add address=ss1.baidu.com list=CnUrl_Address
			add address=security.snssdk.com list=CnUrl_Address
			add address=agent.sj.qq.com list=CnUrl_Address
			add address=www.google-analytics.com list=CnUrl_Address
			add address=song.fanxing.kugou.com list=CnUrl_Address
			add address=www.googletagmanager.com list=CnUrl_Address
			add address=up.hy.baidu.com list=CnUrl_Address
			add address=mps.amap.com list=CnUrl_Address
			add address=rq.cct.cloud.duba.net list=CnUrl_Address
			add address=musiclog.gionee.com list=CnUrl_Address
			add address=afpeng.alimama.com list=CnUrl_Address
			add address=p9.pstatp.com list=CnUrl_Address
			add address=nsclick.baidu.com list=CnUrl_Address
			add address=conf.diditaxi.com.cn list=CnUrl_Address
			add address=cl.vd.f.360.cn list=CnUrl_Address
			add address=rq.lbcct.cloud.duba.net list=CnUrl_Address
			add address=img1.gtimg.com list=CnUrl_Address
			add address=pancake.apple.com list=CnUrl_Address
			add address=olimenew.baidu.com list=CnUrl_Address
			add address=pingfore.qq.com list=CnUrl_Address
			add address=puma.api.iqiyi.com list=CnUrl_Address
			add address=g.alicdn.com list=CnUrl_Address
			add address=sax.sina.com.cn list=CnUrl_Address
			add address=ss2.baidu.com list=CnUrl_Address
			add address=mdap.alipay.com list=CnUrl_Address
			add address=huanle.qq.com list=CnUrl_Address
			add address=m5.amap.com list=CnUrl_Address
			add address=hub5p.sandai.net list=CnUrl_Address
			add address=ichannel.snssdk.com list=CnUrl_Address
			add address=gsp0.baidu.com list=CnUrl_Address
			add address=vs5.tjct.u3.ucweb.com list=CnUrl_Address
			add address=check02.51y5.net list=CnUrl_Address
			add address=ark.letv.com list=CnUrl_Address
			add address=gspe19-cn.ls.apple.com list=CnUrl_Address
			add address=paopao.iqiyi.com list=CnUrl_Address
			add address=mapi.dianping.com list=CnUrl_Address
			add address=rtmonitor.kugou.com list=CnUrl_Address
			add address=gllive.gameloft.com list=CnUrl_Address
			add address=offlinepkg.vip.qq.com list=CnUrl_Address
			add address=api.gifshow.com list=CnUrl_Address
			add address=o2o.api.xiaomi.com list=CnUrl_Address
			add address=sqimg.qq.com list=CnUrl_Address
			add address=toutiao-frontier.snssdk.com list=CnUrl_Address
			add address=shouji.sogou.com list=CnUrl_Address
			add address=atanx.alicdn.com list=CnUrl_Address
			add address=h5.qzone.qq.com list=CnUrl_Address
			add address=p0.meituan.net list=CnUrl_Address
			add address=swa.gtimg.com list=CnUrl_Address
			add address=www.qchannel01.cn list=CnUrl_Address
			add address=kkpgv3.xunlei.com list=CnUrl_Address
			add address=blackhole.m.jd.com list=CnUrl_Address
			add address=i.sau.coloros.com list=CnUrl_Address
			add address=wgo.mmstat.com list=CnUrl_Address
			add address=ubmcmm.baidustatic.com list=CnUrl_Address
			add address=db.safe.2345.com list=CnUrl_Address
			add address=api-log.immomo.com list=CnUrl_Address
			add address=ww1.sinaimg.cn list=CnUrl_Address
			add address=apoll.m.taobao.com list=CnUrl_Address
			add address=stat.lianmeng.360.cn list=CnUrl_Address
			add address=image.uczzd.cn list=CnUrl_Address
			add address=rm.api.weibo.com list=CnUrl_Address
			add address=p1.meituan.net list=CnUrl_Address
			add address=m.s.360.cn list=CnUrl_Address
			add address=im-pb.iqiyi.com list=CnUrl_Address
			add address=isub.snssdk.com list=CnUrl_Address
			add address=apiinit.amap.com list=CnUrl_Address
			add address=jqmt.qq.com list=CnUrl_Address
			add address=lives.l.qq.com list=CnUrl_Address
			add address=p.tanx.com list=CnUrl_Address
			add address=googleads.g.doubleclick.net list=CnUrl_Address
			add address=gameeve.beacon.qq.com list=CnUrl_Address
			add address=ios-dc.51y5.net list=CnUrl_Address
			add address=play.itunes.apple.com list=CnUrl_Address
			add address=oa.kito.cn list=CnUrl_Address
			add address=dd.browser.360.cn list=CnUrl_Address
			add address=pcookie.cnzz.com list=CnUrl_Address
			add address=show-m.mediav.com list=CnUrl_Address
			add address=dl.stream.qqmusic.qq.com list=CnUrl_Address
			add address=ww4.sinaimg.cn list=CnUrl_Address
			add address=w.cnews.qq.com list=CnUrl_Address
			add address=qqpublic.qpic.cn list=CnUrl_Address
			add address=iface.iqiyi.com list=CnUrl_Address
			add address=wspeed.qq.com list=CnUrl_Address
			add address=hb.crm2.qq.com list=CnUrl_Address
			add address=pic5.qiyipic.com list=CnUrl_Address
			add address=wanwandaojia.com list=CnUrl_Address
			add address=lyrics.kugou.com list=CnUrl_Address
			add address=api.share.mob.com list=CnUrl_Address
			add address=ic.wps.cn list=CnUrl_Address
			add address=commdata.v.qq.com list=CnUrl_Address
			add address=meta.video.qiyi.com list=CnUrl_Address
			add address=mbdlog.iqiyi.com list=CnUrl_Address
			add address=8.tlu.dl.delivery.mp.microsoft.com list=CnUrl_Address
			add address=m.360buyimg.com list=CnUrl_Address
			add address=pv.hd.sohu.com list=CnUrl_Address
			add address=uranus.jd.com list=CnUrl_Address
			add address=qos.live.360.cn list=CnUrl_Address
			add address=pb.hd.sohu.com.cn list=CnUrl_Address
			add address=vmtstvcdn.alicdn.com list=CnUrl_Address
			add address=ossweb-img.qq.com list=CnUrl_Address
			add address=ls.a.yximgs.com list=CnUrl_Address
			add address=scs-lxy.openspeech.cn list=CnUrl_Address
			add address=cgi.qqweb.qq.com list=CnUrl_Address
			add address=stat.iqiyimsdk.p2cdn.com list=CnUrl_Address
			add address=dorangesource.alicdn.com list=CnUrl_Address
			add address=cn.bing.com list=CnUrl_Address
			add address=ww2.sinaimg.cn list=CnUrl_Address
			add address=ope.tanx.com list=CnUrl_Address
			add address=push.mobile.kugou.com list=CnUrl_Address
			add address=ww3.sinaimg.cn list=CnUrl_Address
			add address=log.snssdk.com list=CnUrl_Address
			add address=stats.jpush.cn list=CnUrl_Address
			add address=sdk.mobad.ijinshan.com list=CnUrl_Address
			add address=serveraddr.service.kugou.com list=CnUrl_Address
			add address=pic7.qiyipic.com list=CnUrl_Address
			add address=v3.365yg.com list=CnUrl_Address
			add address=cu005.www.duba.net list=CnUrl_Address
			add address=isdspeed.qq.com list=CnUrl_Address
			add address=switch.pcfg.cache.wpscdn.cn list=CnUrl_Address
			add address=static2.ssp.xunlei.com list=CnUrl_Address
			add address=us-east-1.blobstore.apple.com list=CnUrl_Address
			add address=cl5.apple.com list=CnUrl_Address
			add address=pic0.qiyipic.com list=CnUrl_Address
			add address=catdot.dianping.com list=CnUrl_Address
			add address=data.flurry.com list=CnUrl_Address
			add address=pic2.qiyipic.com list=CnUrl_Address
			add address=vwecam.tc.qq.com list=CnUrl_Address
			add address=alogs.umeng.com list=CnUrl_Address
			add address=bd.a.yximgs.com list=CnUrl_Address
			add address=search.www.duba.net list=CnUrl_Address
			add address=hub5idx.shub.sandai.net list=CnUrl_Address
			add address=beacon.sina.com.cn list=CnUrl_Address
			add address=cdn01.baidu-img.cn list=CnUrl_Address
			add address=hotsoon.snssdk.com list=CnUrl_Address
			add address=v6.365yg.com list=CnUrl_Address
			add address=pic8.qiyipic.com list=CnUrl_Address
			add address=get.shouji.sogou.com list=CnUrl_Address
			add address=info.pinyin.sogou.com list=CnUrl_Address
			add address=acs.m.taobao.com list=CnUrl_Address
			add address=pic9.qiyipic.com list=CnUrl_Address
			add address=newsapi.sina.cn list=CnUrl_Address
			add address=i1.go2yd.com list=CnUrl_Address
			add address=img.shouji.sogou.com list=CnUrl_Address
			add address=dl.static.iqiyi.com list=CnUrl_Address
			add address=mmgr.gtimg.com list=CnUrl_Address
			add address=pic4.qiyipic.com list=CnUrl_Address
			add address=awaken.amap.com list=CnUrl_Address
			add address=guzzoni.apple.com list=CnUrl_Address
			add address=settings.crashlytics.com list=CnUrl_Address
			add address=rq.drcct.cloud.duba.net list=CnUrl_Address
			add address=captive.apple.com list=CnUrl_Address
			add address=r6.mo.baidu.com list=CnUrl_Address
			add address=res.imtt.qq.com list=CnUrl_Address
			add address=pcdnstat.youku.com list=CnUrl_Address
			add address=dr.hy.baidu.com list=CnUrl_Address
			add address=nseed.minigame.qq.com list=CnUrl_Address
			add address=subscription.iqiyi.com list=CnUrl_Address
			add address=s.p.youku.com list=CnUrl_Address
			add address=pic3.qiyipic.com list=CnUrl_Address
			add address=screenshot.dwstatic.com list=CnUrl_Address
			add address=max-l.mediav.com list=CnUrl_Address
			add address=mobads.baidu.com list=CnUrl_Address
			add address=baichuan.baidu.com list=CnUrl_Address
			add address=uple.qq.com list=CnUrl_Address
			add address=v.qq.com list=CnUrl_Address
			add address=v1.365yg.com list=CnUrl_Address
			add address=sfsapi.micloud.xiaomi.net list=CnUrl_Address
			add address=pic6.qiyipic.com list=CnUrl_Address
			add address=g.us.sinaimg.cn list=CnUrl_Address
			add address=pic1.qiyipic.com list=CnUrl_Address
			add address=iis1.deliver.ifeng.com list=CnUrl_Address
			add address=tconf2.f.360.cn list=CnUrl_Address
			add address=tj.kpzip.com list=CnUrl_Address
			add address=it.snssdk.com list=CnUrl_Address
			add address=p.l.qq.com list=CnUrl_Address
			add address=image.uc.cn list=CnUrl_Address
			add address=rq.upgrade.cloud.duba.net list=CnUrl_Address
			add address=lcsdk.3g.qq.com list=CnUrl_Address
			add address=vs.funshion.com list=CnUrl_Address
			add address=safebrowsing.googleapis.com list=CnUrl_Address
			add address=uestat.video.qiyi.com list=CnUrl_Address
			add address=sr.symcd.com list=CnUrl_Address
			add address=img1.360buyimg.com list=CnUrl_Address
			add address=nl.rcd.iqiyi.com list=CnUrl_Address
			add address=v10.vortex-win.data.microsoft.com list=CnUrl_Address
			add address=ssxd.mediav.com list=CnUrl_Address
			add address=common.diditaxi.com.cn list=CnUrl_Address
			add address=www.ganji.com list=CnUrl_Address
			add address=img.t.sinajs.cn list=CnUrl_Address
			add address=store-021.blobstore.apple.com list=CnUrl_Address
			add address=apic.douyucdn.cn list=CnUrl_Address
			add address=gcn.happyelements.cn list=CnUrl_Address
			add address=x.jd.com list=CnUrl_Address
			add address=browserapi.micloud.xiaomi.net list=CnUrl_Address
			add address=hmma.baidu.com list=CnUrl_Address
			add address=vconf.f.360.cn list=CnUrl_Address
			add address=support.weixin.qq.com list=CnUrl_Address
			add address=ss1.bdstatic.com list=CnUrl_Address
			add address=social.sunlands.com list=CnUrl_Address
			add address=adashx.m.taobao.com list=CnUrl_Address
			add address=video.acfun.cn list=CnUrl_Address
			add address=sopor.game.oppomobile.com list=CnUrl_Address
			add address=oc.umeng.com list=CnUrl_Address
			add address=log.umsns.com list=CnUrl_Address
			add address=mygw.alipay.com list=CnUrl_Address
			add address=api.mobile.meituan.com list=CnUrl_Address
			add address=vm.aty.sohu.com list=CnUrl_Address
			add address=iu.snssdk.com list=CnUrl_Address
			add address=sdkconfig.ad.xiaomi.com list=CnUrl_Address
			add address=cm.pos.baidu.com list=CnUrl_Address
			add address=aliyun.live.pptv.com list=CnUrl_Address
			add address=feature.3g.qq.com list=CnUrl_Address
			add address=ssl.ptlogin2.qq.com list=CnUrl_Address
			add address=app.video.baidu.com list=CnUrl_Address
			add address=ib.snssdk.com list=CnUrl_Address
			add address=adashbc.ut.taobao.com list=CnUrl_Address
			add address=rl.go2yd.com list=CnUrl_Address
			add address=page.amap.com list=CnUrl_Address
			add address=w.inews.qq.com list=CnUrl_Address
			add address=account.xiaomi.com list=CnUrl_Address
			add address=update.360safe.com list=CnUrl_Address
			add address=updatem.360safe.com list=CnUrl_Address
			add address=track.mediav.com list=CnUrl_Address
			add address=img7.qiyipic.com list=CnUrl_Address
			add address=settings-win.data.microsoft.com list=CnUrl_Address
			add address=stat.m.jd.com list=CnUrl_Address
			add address=ied-tqos-tgp.qq.com list=CnUrl_Address
			add address=dc.stat.nearme.com.cn list=CnUrl_Address
			add address=api.meituan.com list=CnUrl_Address
			add address=iphonesubmissions.apple.com list=CnUrl_Address
			add address=wx.gtimg.com list=CnUrl_Address
			add address=api.smoot.apple.com.cn list=CnUrl_Address
			add address=i.y.qq.com list=CnUrl_Address
			add address=cmts.iqiyi.com list=CnUrl_Address
			add address=isure.stream.qqmusic.qq.com list=CnUrl_Address
			add address=appupgrade.vivo.com.cn list=CnUrl_Address
			add address=ccc.sys.miui.com list=CnUrl_Address
			add address=ulog.gifshow.com list=CnUrl_Address
			add address=api.sec.miui.com list=CnUrl_Address
			add address=pcsdata.baidu.com list=CnUrl_Address
			add address=fusion.qq.com list=CnUrl_Address
			add address=report.mg02.q-dazzle.com list=CnUrl_Address
			add address=statclient.baidu.com list=CnUrl_Address
			add address=se.360.cn list=CnUrl_Address
			add address=e.hiphotos.baidu.com list=CnUrl_Address
			add address=offline.aps.amap.com list=CnUrl_Address
			add address=u167.g03.dbankcloud.com list=CnUrl_Address
			add address=socm.dmp.360.cn list=CnUrl_Address
			add address=store-022.blobstore.apple.com list=CnUrl_Address
			add address=res.qhupdate.com list=CnUrl_Address
			add address=c.51y5.net list=CnUrl_Address
			add address=p5.qhimg.com list=CnUrl_Address
			add address=dl.gl.35go.cn list=CnUrl_Address
			add address=cws.conviva.com list=CnUrl_Address
			add address=ini.update.360safe.com list=CnUrl_Address
			add address=omgup.xiaojukeji.com list=CnUrl_Address
			add address=ic.snssdk.com list=CnUrl_Address
			add address=i3.go2yd.com list=CnUrl_Address
			add address=entry.baidu.com list=CnUrl_Address
			add address=p9.qhimg.com list=CnUrl_Address
			add address=commercial.shouji.360.cn list=CnUrl_Address
			add address=s.bdstatic.com list=CnUrl_Address
			add address=n.sinaimg.cn list=CnUrl_Address
			add address=supportcmsecurity1.ksmobile.com list=CnUrl_Address
			add address=p3p.sogou.com list=CnUrl_Address
			add address=ltsbsy.qq.com list=CnUrl_Address
			add address=datapc.qq.com list=CnUrl_Address
			add address=scan.call.f.360.cn list=CnUrl_Address
			add address=u170.g05.dbankcloud.com list=CnUrl_Address
			add address=iflow.uczzd.cn list=CnUrl_Address
			add address=changyan.sohu.com list=CnUrl_Address
			add address=vector0.map.bdimg.com list=CnUrl_Address
			add address=wq.cloud.duba.net list=CnUrl_Address
			add address=e.tf.360.cn list=CnUrl_Address
			add address=p8.qhimg.com list=CnUrl_Address
			add address=update.pan.baidu.com list=CnUrl_Address
			add address=qqadapt.qpic.cn list=CnUrl_Address
			add address=js1.pcfg.cache.wpscdn.cn list=CnUrl_Address
			add address=api.accuweather.com list=CnUrl_Address
			add address=log.kuwo.cn list=CnUrl_Address
			add address=es.f.360.cn list=CnUrl_Address
			add address=emoticon.sns.iqiyi.com list=CnUrl_Address
			add address=p1.qhimg.com list=CnUrl_Address
			add address=kyfw.12306.cn list=CnUrl_Address
			add address=jsync.3g.qq.com list=CnUrl_Address
			add address=report.meituan.com list=CnUrl_Address
			add address=video.ums.uc.cn list=CnUrl_Address
			add address=pptv.live.lxdns.com list=CnUrl_Address
			add address=as.xiaojukeji.com list=CnUrl_Address
			add address=weather.myoppo.com list=CnUrl_Address
			add address=api.huoshan.com list=CnUrl_Address
			add address=p1.ssl.qhimg.com list=CnUrl_Address
			add address=i.kpzip.com list=CnUrl_Address
			add address=log.hdtv.cp21.ott.cibntv.net list=CnUrl_Address
			add address=static.qiyi.com list=CnUrl_Address
			add address=dataaq.yy.com list=CnUrl_Address
			add address=ei.cnzz.com list=CnUrl_Address
			add address=news-img.51y5.net list=CnUrl_Address
			add address=bdimg.share.baidu.com list=CnUrl_Address
			add address=passport.baidu.com list=CnUrl_Address
			add address=h5vv.video.qq.com list=CnUrl_Address
			add address=hermes.jd.com list=CnUrl_Address
			add address=hb.hy.baidu.com list=CnUrl_Address
			add address=v0.baidupcs.com list=CnUrl_Address
			add address=app.homeinns.com list=CnUrl_Address
			add address=q14.cnzz.com list=CnUrl_Address
			add address=cn-android.cliapi.microfun.cn list=CnUrl_Address
			add address=wsqncdn.miaopai.com list=CnUrl_Address
			add address=os.alipayobjects.com list=CnUrl_Address
			add address=huatuocode.weiyun.com list=CnUrl_Address
			add address=zhidao.baidu.com list=CnUrl_Address
			add address=video.dispatch.tc.qq.com list=CnUrl_Address
			add address=gllto.glpals.com list=CnUrl_Address
			add address=ssl-danmu.youku.com list=CnUrl_Address
			add address=u1.sinaimg.cn list=CnUrl_Address
			add address=cm.l.qq.com list=CnUrl_Address
			add address=update.drivergenius.com list=CnUrl_Address
			add address=pinghot.qq.com list=CnUrl_Address
			add address=hkextshort.weixin.qq.com list=CnUrl_Address
			add address=ptlogin2.qq.com list=CnUrl_Address
			add address=qosp.msg.71.am list=CnUrl_Address
			add address=apps.game.qq.com list=CnUrl_Address
			add address=dc.cp21.ott.cibntv.net list=CnUrl_Address
			add address=huodong.m.taobao.com list=CnUrl_Address
			add address=toutiao.com list=CnUrl_Address
			add address=api.udache.com list=CnUrl_Address
			add address=mi.gdt.qq.com list=CnUrl_Address
			add address=new-user.mobile.youku.com list=CnUrl_Address
			add address=ro.up.vivo.com.cn list=CnUrl_Address
			add address=api.weibo.com list=CnUrl_Address
			add address=a3.pstatp.com list=CnUrl_Address
			add address=p3.qhimg.com list=CnUrl_Address
			add address=cdn.content.prod.cms.msn.com list=CnUrl_Address
			add address=cache.video.qiyi.com list=CnUrl_Address
			add address=b.scorecardresearch.com list=CnUrl_Address
			add address=p2.qhimg.com list=CnUrl_Address
			add address=account.youku.com list=CnUrl_Address
			add address=mmstat.ucweb.com list=CnUrl_Address
			add address=wdl1.cache.wps.cn list=CnUrl_Address
			add address=sdk.look.360.cn list=CnUrl_Address
			add address=kg.qq.com list=CnUrl_Address
			add address=open.weixin.qq.com list=CnUrl_Address
			add address=ra.gtimg.com list=CnUrl_Address
			add address=ah2.zhangyue.com list=CnUrl_Address
			add address=s.f.360.cn list=CnUrl_Address
			add address=r.cnews.qq.com list=CnUrl_Address
			add address=imgstat.baidu.com list=CnUrl_Address
			add address=gspe35-ssl.ls.apple.com list=CnUrl_Address
			add address=www.qq.com list=CnUrl_Address
			add address=omgmta.play.aiseet.atianqi.com list=CnUrl_Address
			add address=val.atm.youku.com list=CnUrl_Address
			add address=c.hiphotos.baidu.com list=CnUrl_Address
			add address=se.itunes.apple.com list=CnUrl_Address
			add address=v7.pstatp.com list=CnUrl_Address
			add address=happyapp.huanle.qq.com list=CnUrl_Address
			add address=xia4.12345hdhd.com list=CnUrl_Address
			add address=mobilegw.alipay.com list=CnUrl_Address
			add address=trackercdn.kugou.com list=CnUrl_Address
			add address=sdkapp.mobile.sina.cn list=CnUrl_Address
			add address=wifiapi02.51y5.net list=CnUrl_Address
			add address=qumas.mail.qq.com list=CnUrl_Address
			add address=fs.ios.kugou.com list=CnUrl_Address
			add address=p0.ssl.qhimg.com list=CnUrl_Address
			add address=data.bilibili.com list=CnUrl_Address
			add address=ls.baidu.com list=CnUrl_Address
			add address=stat.3g.music.qq.com list=CnUrl_Address
			add address=api1.dbank.com list=CnUrl_Address
			add address=dl.ijinshan.com list=CnUrl_Address
			add address=appc.baidu.com list=CnUrl_Address
			add address=p.api.pc120.com list=CnUrl_Address
			add address=cdn.read.html5.qq.com list=CnUrl_Address
			add address=appstore.cliapi.microfun.cn list=CnUrl_Address
			add address=cm.passport.iqiyi.com list=CnUrl_Address
			add address=p7.qhimg.com list=CnUrl_Address
			add address=cm.g.doubleclick.net list=CnUrl_Address
			add address=p6.qhimg.com list=CnUrl_Address
			add address=sax.sina.cn list=CnUrl_Address
			add address=ugc-videohy.tc.qq.com list=CnUrl_Address
			add address=lg.snssdk.com list=CnUrl_Address
			add address=api.unipay.qq.com list=CnUrl_Address
			add address=vliveachy.tc.qq.com list=CnUrl_Address
			add address=stt.baidu.com list=CnUrl_Address
			add address=api.mobile.youku.com list=CnUrl_Address
			add address=comm.inner.bbk.com list=CnUrl_Address
			add address=web.qun.qq.com list=CnUrl_Address
			add address=us-std-00001.s3.amazonaws.com list=CnUrl_Address
			add address=ddsdk.vectors2.map.qq.com list=CnUrl_Address
			add address=uxip.meizu.com list=CnUrl_Address
			add address=aw11.pub.funshion.com list=CnUrl_Address
			add address=www.duba.com list=CnUrl_Address
			add address=huatuospeed.huatuo.qq.com list=CnUrl_Address
			add address=rq.upgrade.cmpc.cmcm.com list=CnUrl_Address
			add address=qq.irs01.com list=CnUrl_Address
			add address=als.baidu.com list=CnUrl_Address
			add address=p4.qhimg.com list=CnUrl_Address
			add address=store-017.blobstore.apple.com list=CnUrl_Address
			add address=pagead2.googlesyndication.com list=CnUrl_Address
			add address=cdn.data.video.iqiyi.com list=CnUrl_Address
			add address=openapi.youku.com list=CnUrl_Address
			add address=m.ctrip.com list=CnUrl_Address
			add address=live-api.immomo.com list=CnUrl_Address
			add address=sngmta.qq.com list=CnUrl_Address
			add address=probe.vip.com list=CnUrl_Address
			add address=gpic.qpic.cn list=CnUrl_Address
			add address=nimg.ws.126.net list=CnUrl_Address
			add address=dyn.wps.cn list=CnUrl_Address
			add address=changyan.itc.cn list=CnUrl_Address
			add address=mi.zhaopin.com list=CnUrl_Address
			add address=s3m.mediav.com list=CnUrl_Address
			add address=www.qiyipic.com list=CnUrl_Address
			add address=m.wisdom.www.sogou.com list=CnUrl_Address
			add address=uconf.f.360.cn list=CnUrl_Address
			add address=cm.poll.keke.cn list=CnUrl_Address
			add address=mercury.jd.com list=CnUrl_Address
			add address=fex.bdstatic.com list=CnUrl_Address
			add address=zxpic.imtt.qq.com list=CnUrl_Address
			add address=wap.sogou.com list=CnUrl_Address
			add address=weatherapi.market.xiaomi.com list=CnUrl_Address
			add address=api.foxitreader.cn list=CnUrl_Address
			add address=sdk.mediav.com list=CnUrl_Address
			add address=urs.microsoft.com list=CnUrl_Address
			add address=masterconn.qq.com list=CnUrl_Address
			add address=a3.bytecdn.cn list=CnUrl_Address
			add address=api.ad.xiaomi.com list=CnUrl_Address
			add address=sdup.360.cn list=CnUrl_Address
			add address=s.webp2p.cp21.ott.cibntv.net list=CnUrl_Address
			add address=av.video.qq.com list=CnUrl_Address
			add address=login.live.com list=CnUrl_Address
			add address=uc.a.yximgs.com list=CnUrl_Address
			add address=like.video.qq.com list=CnUrl_Address
			add address=mobile.ximalaya.com list=CnUrl_Address
			add address=wbapp.mobile.sina.cn list=CnUrl_Address
			add address=hispaceclt.hicloud.com list=CnUrl_Address
			add address=image.smoba.qq.com list=CnUrl_Address
			add address=flexible.zego.im list=CnUrl_Address
			add address=sdk.e.qq.com list=CnUrl_Address
			add address=images.sohu.com list=CnUrl_Address
			add address=p3.ssl.qhimg.com list=CnUrl_Address
			add address=t5.baidu.com list=CnUrl_Address
			add address=service.gc.apple.com list=CnUrl_Address
			add address=d.pcs.baidu.com list=CnUrl_Address
			add address=kjjs.360.cn list=CnUrl_Address
			add address=dr.ttl.baidu.com list=CnUrl_Address
			add address=c.tieba.baidu.com list=CnUrl_Address
			add address=qiaowebn.baidu.com list=CnUrl_Address
			add address=img30.360buyimg.com list=CnUrl_Address
			add address=p2.ssl.qhimg.com list=CnUrl_Address
			add address=webapi.weather.com.cn list=CnUrl_Address
			add address=data.video.qq.com list=CnUrl_Address
			add address=c.gj.qq.com list=CnUrl_Address
			add address=mobilecdn.kugou.com list=CnUrl_Address
			add address=tb1.bdstatic.com list=CnUrl_Address
			add address=dldir3.qq.com list=CnUrl_Address
			add address=ctldl.windowsupdate.com list=CnUrl_Address
			add address=pingjs.qq.com list=CnUrl_Address
			add address=ad.fanxing.kugou.com list=CnUrl_Address
			add address=lmbsy.qq.com list=CnUrl_Address
			add address=hao.360.cn list=CnUrl_Address
			add address=m.yunos.wasu.tv list=CnUrl_Address
			add address=cgicol.amap.com list=CnUrl_Address
			add address=fld.funshion.com list=CnUrl_Address
			add address=stats.umsns.com list=CnUrl_Address
			add address=su.bdimg.com list=CnUrl_Address
			add address=video.qpic.cn list=CnUrl_Address
			add address=szzjwxsns.video.qq.com list=CnUrl_Address
			add address=cctv11.live.cntv.dnion.com list=CnUrl_Address
			add address=cn.ekg.riotgames.com list=CnUrl_Address
			add address=cm.jd.com list=CnUrl_Address
			add address=2052.flash2-http.qq.com list=CnUrl_Address
			add address=topmusic.kuwo.cn list=CnUrl_Address
			add address=adui.tg.meitu.com list=CnUrl_Address
			add address=image.scale.inke.com list=CnUrl_Address
			add address=www.hao123.com list=CnUrl_Address
			add address=mmcard.qpic.cn list=CnUrl_Address
			add address=store-011.blobstore.apple.com list=CnUrl_Address
			add address=ios.rqd.qq.com list=CnUrl_Address
			add address=api.meitu.com list=CnUrl_Address
			add address=i1.weather.oppomobile.com list=CnUrl_Address
			add address=mobsec-sec.baidu.com list=CnUrl_Address
			add address=gss0.baidu.com list=CnUrl_Address
			add address=mobile.app100718846.twsapp.com list=CnUrl_Address
			add address=search.video.qiyi.com list=CnUrl_Address
			add address=www.so.com list=CnUrl_Address
			add address=api.map.haosou.com list=CnUrl_Address
			add address=a.hiphotos.baidu.com list=CnUrl_Address
			add address=cdn.hiphotos.baidu.com list=CnUrl_Address
			add address=tv.aiseet.atianqi.com list=CnUrl_Address
			add address=oalipay-dl-django.alicdn.com list=CnUrl_Address
			add address=hs.qhupdate.com list=CnUrl_Address
			add address=cloudshell-tsa-server.aliyun.com list=CnUrl_Address
			add address=wq.jd.com list=CnUrl_Address
			add address=cc.linkinme.com list=CnUrl_Address
			add address=c.uaa.iqiyi.com list=CnUrl_Address
			add address=cms.tanx.com list=CnUrl_Address
			add address=s.x.baidu.com list=CnUrl_Address
			add address=dr.cs3.duba.net list=CnUrl_Address
			add address=post.mp.qq.com list=CnUrl_Address
			add address=data.3g.yy.com list=CnUrl_Address
			add address=conn.tga.qq.com list=CnUrl_Address
			add address=tyaqy.m.cn.miaozhen.com list=CnUrl_Address
			add address=www.lechange.cn list=CnUrl_Address
			add address=d.ifengimg.com list=CnUrl_Address
			add address=api.changba.com list=CnUrl_Address
			add address=mapi.4399api.net list=CnUrl_Address
			add address=m.simba.taobao.com list=CnUrl_Address
			add address=www.zhangyu.tv list=CnUrl_Address
			add address=store-005.blobstore.apple.com list=CnUrl_Address
			add address=softm.update.360safe.com list=CnUrl_Address
			add address=waimaie.meituan.com list=CnUrl_Address
			add address=client.qzone.com list=CnUrl_Address
			add address=sd.cn.miaozhen.com list=CnUrl_Address
			add address=tracking.miui.com list=CnUrl_Address
			add address=mvconf.f.360.cn list=CnUrl_Address
			add address=user-mobile.youku.com list=CnUrl_Address
			add address=servicecut.meizu.com list=CnUrl_Address
			add address=update.leak.360.cn list=CnUrl_Address
			add address=imageplus.baidu.com list=CnUrl_Address
			add address=api.lxqp.360.cn list=CnUrl_Address
			add address=pclist.iqiyi.com list=CnUrl_Address
			add address=huyaimg.dwstatic.com list=CnUrl_Address
			add address=p.3.cn list=CnUrl_Address
			add address=driver.sjk.ijinshan.com list=CnUrl_Address
			add address=main.appstore.vivo.com.cn list=CnUrl_Address
			add address=client04.pdl.wow.battlenet.com.cn list=CnUrl_Address
			add address=tc2.baidu-1img.cn list=CnUrl_Address
			add address=vm.gtimg.cn list=CnUrl_Address
			add address=v.admaster.com.cn list=CnUrl_Address
			add address=graph.baidu.com list=CnUrl_Address
			add address=pcvideoaliyun.titan.mgtv.com list=CnUrl_Address
			add address=static.tieba.baidu.com list=CnUrl_Address
			add address=configsvr.msf.3g.qq.com list=CnUrl_Address
			add address=api.bosszhipin.com list=CnUrl_Address
			add address=lbdata.tj.ijinshan.com list=CnUrl_Address
			add address=manage.artron.net list=CnUrl_Address
			add address=weather.hicloud.com list=CnUrl_Address
			add address=xiaozhengtai.pw list=CnUrl_Address
			add address=app.market.xiaomi.com list=CnUrl_Address
			add address=ic100.wps.cn list=CnUrl_Address
			add address=ios.bugly.qq.com list=CnUrl_Address
			add address=w.cnzz.com list=CnUrl_Address
			add address=qlogo1.store.qq.com list=CnUrl_Address
			add address=qzs.qq.com list=CnUrl_Address
			add address=p10-buy.itunes.apple.com list=CnUrl_Address
			add address=pim.baidu.com list=CnUrl_Address
			add address=init.ess.apple.com list=CnUrl_Address
			add address=kepler.jd.com list=CnUrl_Address
			add address=api.ksapisrv.com list=CnUrl_Address
			add address=stat.10jqka.com.cn list=CnUrl_Address
			add address=notify.wps.cn list=CnUrl_Address
			add address=huichuan.sm.cn list=CnUrl_Address
			add address=ups.ksmobile.net list=CnUrl_Address
			add address=ac.tc.qq.com list=CnUrl_Address
			add address=u.meizu.com list=CnUrl_Address
			add address=ark.qq.com list=CnUrl_Address
			add address=s4.cnzz.com list=CnUrl_Address
			add address=shark.dianping.com list=CnUrl_Address
			add address=smart.sug.so.com list=CnUrl_Address
			add address=track.uc.cn list=CnUrl_Address
			add address=f.hiphotos.baidu.com list=CnUrl_Address
			add address=blades.aliyun.com list=CnUrl_Address
			add address=s8.url.cn list=CnUrl_Address
			add address=pcvideoyd.titan.mgtv.com list=CnUrl_Address
			add address=weather.vivo.com.cn list=CnUrl_Address
			add address=istore.oppomobile.com list=CnUrl_Address
			add address=mobilecns.alipay.com list=CnUrl_Address
			add address=wea.uc.cn list=CnUrl_Address
			add address=p.ssl.qhimg.com list=CnUrl_Address
			add address=data.store.iqiyi.com list=CnUrl_Address
			add address=pp.myapp.com list=CnUrl_Address
			add address=shurufacdn.baidu.com list=CnUrl_Address
			add address=bilin.yy.com list=CnUrl_Address
			add address=dld.qzapp.z.qq.com list=CnUrl_Address
			add address=long.open.weixin.qq.com list=CnUrl_Address
			add address=s.momocdn.com list=CnUrl_Address
			add address=hao.ssl.dhrest.com list=CnUrl_Address
			add address=g3com.cp21.ott.cibntv.net list=CnUrl_Address
			add address=qcweb.qunar.com list=CnUrl_Address
			add address=list3.ppstream.com.iqiyi.com list=CnUrl_Address
			add address=ad.api.3g.youku.com list=CnUrl_Address
			add address=api.growingio.com list=CnUrl_Address
			add address=netmon.stat.360safe.com list=CnUrl_Address
			add address=opensdk.uu.qq.com list=CnUrl_Address
			add address=elephant.browser.360.cn list=CnUrl_Address
			add address=tunion-api.m.taobao.com list=CnUrl_Address
			add address=api.ys7.com list=CnUrl_Address
			add address=go.microsoft.com list=CnUrl_Address
			add address=mini.eastday.com list=CnUrl_Address
			add address=r2.ykimg.com list=CnUrl_Address
			add address=stuck.stat.nearme.com.cn list=CnUrl_Address
			add address=bmc.yunos.com list=CnUrl_Address
			add address=online.kugou.com list=CnUrl_Address
			add address=singerimg.kugou.com list=CnUrl_Address
			add address=www.ludashi.com list=CnUrl_Address
			add address=btrace.play.aiseet.atianqi.com list=CnUrl_Address
			add address=alimov2.a.yximgs.com list=CnUrl_Address
			add address=ofloc.map.baidu.com list=CnUrl_Address
			add address=statistic.3g.qq.com list=CnUrl_Address
			add address=wp.mail.qq.com list=CnUrl_Address
			add address=snakeapi.afunapp.com list=CnUrl_Address
			add address=pcs.baidu.com list=CnUrl_Address
			add address=ebooking.qunar.com list=CnUrl_Address
			add address=s.ludashi.com list=CnUrl_Address
			add address=infoc0.duba.net list=CnUrl_Address
			add address=www.wanwandaojia.com list=CnUrl_Address
			add address=nufm.dfcfw.com list=CnUrl_Address
			add address=s3.qhimg.com list=CnUrl_Address
			add address=store-007.blobstore.apple.com list=CnUrl_Address
			add address=show.g.mediav.com list=CnUrl_Address
			add address=px.3.cn list=CnUrl_Address
			add address=ndct-data.video.iqiyi.com list=CnUrl_Address
			add address=store-009.blobstore.apple.com list=CnUrl_Address
			add address=zixun.html5.qq.com list=CnUrl_Address
			add address=hkhkg-2-ap.icloud-content.com list=CnUrl_Address
			add address=sp2.baidu.com list=CnUrl_Address
			add address=service.supercell.net list=CnUrl_Address
			add address=store-010.blobstore.apple.com list=CnUrl_Address
			add address=zos.alipayobjects.com list=CnUrl_Address
			add address=397c0.admaster.com.cn list=CnUrl_Address
			add address=keplerapi.jd.com list=CnUrl_Address
			add address=ioscdn.kugou.com list=CnUrl_Address
			add address=msg.ptqy.gitv.tv list=CnUrl_Address
			add address=analy.qq.com list=CnUrl_Address
			add address=i.go.sohu.com list=CnUrl_Address
			add address=tools.3g.qq.com list=CnUrl_Address
			add address=a1.alicdn.com list=CnUrl_Address
			add address=hkhkg-3-ap.icloud-content.com list=CnUrl_Address
			add address=crl.microsoft.com list=CnUrl_Address
			add address=mapi.appvipshop.com list=CnUrl_Address
			add address=nj.t.bcsp2p.baidu.com list=CnUrl_Address
			add address=spark.api.xiami.com list=CnUrl_Address
			add address=resolver.gslb.mi-idc.com list=CnUrl_Address
			add address=img13.360buyimg.com list=CnUrl_Address
			add address=log.web.kugou.com list=CnUrl_Address
			add address=magzinefs.nearme.com.cn list=CnUrl_Address
			add address=sofire.bdstatic.com list=CnUrl_Address
			add address=gsp1.apple.com list=CnUrl_Address
			add address=query.hicloud.com list=CnUrl_Address
			add address=rabbit.tg.meitu.com list=CnUrl_Address
			add address=hfm.adsame.com list=CnUrl_Address
			add address=pay.video.qq.com list=CnUrl_Address
			add address=conn1.oppomobile.com list=CnUrl_Address
			add address=hd.xiaojukeji.com list=CnUrl_Address
			add address=dicon.ifreetalk.com list=CnUrl_Address
			add address=bbs.tianya.cn list=CnUrl_Address
			add address=melody.shop.ele.me list=CnUrl_Address
			add address=apple-finance.query.yahoo.com list=CnUrl_Address
			add address=tvax4.sinaimg.cn list=CnUrl_Address
			add address=c.m.163.com list=CnUrl_Address
			add address=p14-buy.itunes.apple.com list=CnUrl_Address
			add address=hb.zc.baidu.com list=CnUrl_Address
			add address=log.m.sm.cn list=CnUrl_Address
			add address=api.sunchip-tech.com list=CnUrl_Address
			add address=section.ifreetalk.com list=CnUrl_Address
			add address=api.didialift.com list=CnUrl_Address
			add address=c.wkanx.com list=CnUrl_Address
			add address=hkhkg-4-ap.icloud-content.com list=CnUrl_Address
			add address=pingtcss.qq.com list=CnUrl_Address
			add address=i.work.weixin.qq.com list=CnUrl_Address
			add address=hkhkg-1-ap.icloud-content.com list=CnUrl_Address
			add address=g.fastapi.net list=CnUrl_Address
			add address=iphone-ld.apple.com list=CnUrl_Address
			add address=www.sogou.com list=CnUrl_Address
			add address=img01.sogoucdn.com list=CnUrl_Address
			add address=count.atm.youku.com list=CnUrl_Address
			add address=img.inbilin.com list=CnUrl_Address
			add address=r4.ykimg.com list=CnUrl_Address
			add address=info.wps.cn list=CnUrl_Address
			add address=s.gdt.qq.com list=CnUrl_Address
			add address=ma.3g.qq.com list=CnUrl_Address
			add address=dol.deliver.ifeng.com list=CnUrl_Address
			add address=lepodownload.mediatek.com list=CnUrl_Address
			add address=client.tv.uc.cn list=CnUrl_Address
			add address=pingmid.qq.com list=CnUrl_Address
			add address=dnion.pp.starschinalive.com list=CnUrl_Address
			add address=api.free.wifi.360.cn list=CnUrl_Address
			add address=seupdate.360safe.com list=CnUrl_Address
			add address=api.m.sm.cn list=CnUrl_Address
			add address=tvax3.sinaimg.cn list=CnUrl_Address
			add address=client-api.itunes.apple.com list=CnUrl_Address
			add address=pinyin.voicecloud.cn list=CnUrl_Address
			add address=imgsrc.baidu.com list=CnUrl_Address
			add address=mixer.video.iqiyi.com list=CnUrl_Address
			add address=tvax1.sinaimg.cn list=CnUrl_Address
			add address=tvax2.sinaimg.cn list=CnUrl_Address
			add address=dc1.networkbench.com list=CnUrl_Address
			add address=tajs.qq.com list=CnUrl_Address
			add address=ads.service.kugou.com list=CnUrl_Address
			add address=show.re.taobao.com list=CnUrl_Address
			add address=grand.ele.me list=CnUrl_Address
			add address=c.mp.qq.com list=CnUrl_Address
			add address=ss2.bdstatic.com list=CnUrl_Address
			add address=s11.cnzz.com list=CnUrl_Address
			add address=static.flv.uuzuonline.com list=CnUrl_Address
			add address=ltslx.qq.com list=CnUrl_Address
			add address=mmy.pp.starschinalive.com list=CnUrl_Address
			add address=ios-config.51y5.net list=CnUrl_Address
			add address=service.mobile.kugou.com list=CnUrl_Address
			add address=s0.ssl.qhres.com list=CnUrl_Address
			add address=rq.upgrade.lbmini.cmcm.com list=CnUrl_Address
			add address=r3.ykimg.com list=CnUrl_Address
			add address=vcheck.f.360.cn list=CnUrl_Address
		}	
	}