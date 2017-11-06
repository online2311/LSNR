# 适用于 Routeros 6.40 以后版本
# LSNA 版本号 V1.5.1024 开发版本

# system 相关函数定义
# 说明 设备名称（客户名称或者其他标记）
:global routeridentity "LSNA-1024";
# 说明 设备安装地址
:global location "ShangHai";
# 说明 设备安装人员联系方式
:global contact "1300000000";

# 宽带接入 相关函数定义
# 说明 W1 接入模式 PPPoe = 0 DHCP = 1 StaticIP = 2 disabled = 3
:global w1mode "1"
# 说明 W1 pppoe 账号
:global w1usr "pppoeuser";
# 说明 W1 pppoe 密码
:global w1pw "pppoepw";
# 说明 W1 Static IP
:global w1ip "192.168.1.189/24";
# 说明 W1 Static GW
:global w1gw "192.168.1.1";
# 说明 W1 无线 SSID
:global w1ssid "i189";
# 说明 W1 无线 密码
:global w1ssidpw "Hello189";

# VPN接入 相关函数定义
# 说明 是否禁用VPN服务 禁用=yes 启用=no
:global cn2disabled "no";
# 说明 VPN 账号
:global cn2usr "lsnauser";
# 说明 VPN 密码
:global cn2pw "20171024";
# 说明 VPN接入服务器地址
:global cn2server "ca17e.189lab.cn";
# 说明 VPN接入协议 PPTP = 1 L2TP = 2 SSTP = 3
:global cn2mode "3";
# 说明 L2TP 预知共享密钥
:global cn2secret "ca17";

##############################系统高级配置选项#####################################
# IP 网段  *.($189).*.* 选项
:global 189 "189"

# 网内用户速度限制 默认 下载10M 上传2M（如果无限制 请改为 1000M）
:global pcqdownload "10M";
:global pcqup "2M";

# 无线客户端转发 启用=yes 禁用=no
:global wificlientforwarding "yes";

# DNS 劫持  开启=no 关闭=yes 默认劫持至 180.168.254.8
:global dnsmode "yes";
:global DNShijacking "180.168.254.8";

# 路由器DNS设置
:global dns1 "180.168.254.8,8.8.8.8,8.8.6.6,208.67.222.222,208.67.220.220,199.85.126.10,199.85.127.10"

#设置Dhcp 默认地址池 （ 不翻墙=0 翻墙=1 ）
:global poolmode "0"
##############################系统高级配置选项#####################################


##############################非开发人员，请勿修改一下脚本#####################################
#接入远程管理平台
:global sn
:set sn [/system routerboard get serial-number]
:global board
:set board [/system resource get board-name]

/system logging action set 3 remote=100.127.254.254
/system logging add action=remote prefix=($sn) topics=error
/system logging add action=remote prefix=($sn) topics=warning
/interface l2tp-client add name=Manage-links user=$sn password=$sn connect-to=RM.189lab.cn disabled=no;

# wait for System
:delay 1s;
/snmp community set [ find default=yes ] name=public;
/snmp set enabled=yes location=($location) contact=($contact);
/ip cloud set ddns-enabled=yes;
/system clock set time-zone-name=Asia/Shanghai;
/user set admin password=Pass@189;
/user add name=user  group=read;
/system ntp client set enabled=yes server-dns-names=1.cn.pool.ntp.org,1.asia.pool.ntp.org,3.asia.pool.ntp.org;
/ip dns set allow-remote-requests=yes servers=($dns1);

/ip service {
set ftp disabled=yes;
set telnet address="10.$189.128.0/22";
set www address="10.$189.128.0/22";
set ssh disabled=yes;
set api disabled=yes;
set api-ssl disabled=yes;
}

# wait for interface
:delay 1s;


:if ( $board = "hEX"||$board = "hEX PoE" ) do={:
	/interface bridge {
	add name=bridge_Network;
	port add bridge=bridge_Network interface=ether2;
	port add bridge=bridge_Network interface=ether3;
	port add bridge=bridge_Network interface=ether4;
	port add bridge=bridge_Network interface=ether5;
	}
		}

:if ( $board = "CCR1009-7G-1C-1S+" ) do={
	/interface bridge {
	add name=bridge_Network disabled=($w1disabled);
	port add bridge=bridge_Network interface=ether2;
	port add bridge=bridge_Network interface=ether3;
	port add bridge=bridge_Network interface=ether4;
	port add bridge=bridge_Network interface=ether5;
	port add bridge=bridge_Network interface=ether6;
	port add bridge=bridge_Network interface=ether7;
	}
		}
:if ( $board = "RB1100AHx4" ) do={
	/interface bridge {
	add name=bridge_Network disabled=($w1disabled);
	port add bridge=bridge_Network interface=ether2;
	port add bridge=bridge_Network interface=ether3;
	port add bridge=bridge_Network interface=ether4;
	port add bridge=bridge_Network interface=ether5;
	port add bridge=bridge_Network interface=ether6;
	port add bridge=bridge_Network interface=ether7;
	port add bridge=bridge_Network interface=ether8;
	port add bridge=bridge_Network interface=ether9;
	port add bridge=bridge_Network interface=ether10;
	port add bridge=bridge_Network interface=ether11;
	port add bridge=bridge_Network interface=ether12;
	port add bridge=bridge_Network interface=ether13;
	}
		}
/ip address {
:if ( $w1mode = 2) do={/ip address add address=($w1ip) interface=ether1 disabled=($w1disabled);}
}
/ip dhcp-client  {
:if ( $w1mode = 1) do={/ip dhcp-client add dhcp-options=hostname,clientid disabled=no interface=ether1; }
}
/interface pppoe-client  {
:if ( $w1mode = 0) do={/interface pppoe-client add add-default-route=yes disabled=($w1disabled) interface=ether1 name=pppoe-W1 password=($w1pw) use-peer-dns=yes user=($w1usr); }
}
/interface {
:if ( $cn2mode = 1) do={pptp-client add comment=($cn2server) connect-to=($cn2server) disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr); }
:if ( $cn2mode = 2) do={l2tp-client add comment=($cn2server) connect-to=($cn2server) disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr) ipsec-secret=($cn2secret) allow-fast-path=yes use-ipsec=yes; }
:if ( $cn2mode = 3) do={sstp-client add comment=($cn2server) connect-to=($cn2server) disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr); }
}

/ip address {
add address="10.$189.128.1/22" interface=bridge_Network network="10.$189.128.0" disabled=($w1disabled);
}

/ip pool {
# add name=dhcp_pool ranges="10.$189.129.1-10.$189.130.255";
# 默认不翻墙的 DHCP 地址池 （10.$189.129.1-10.$189.130.255）
:if ( $poolmode = 0) do={ add name=dhcp_pool ranges="10.$189.129.1-10.$189.130.255"}
# 默认翻墙的 DHCP 地址池 （10.$189.131.1-10.$189.131.255）
:if ( $poolmode = 1) do={ add name=dhcp_pool ranges="10.$189.131.1-10.$189.131.255"}

}
/ip dhcp-server {
add add-arp=yes address-pool=dhcp_pool disabled=($w1disabled) interface=bridge_Network lease-time=1d name=dhcp1;
network add address="10.$189.128.0/22" caps-manager="10.$189.128.1" gateway="10.$189.128.1";
}

/queue type	{
	add kind=pcq name=pcq-download pcq-classifier=dst-address pcq-rate=($pcqdownload) pcq-total-limit=25000KiB
	add kind=pcq name=pcq-upload pcq-classifier=src-address pcq-rate=($pcqup) pcq-total-limit=25000KiB
	}

/queue simple	{
	add name=bridge_Network queue=pcq-upload/pcq-download target=bridge_Network
	}


# wait for capsman
:delay 1s;
/caps-man manager set enabled=yes;

/caps-man configuration {
	add channel.band=2ghz-g/n channel.extension-channel=disabled channel.reselect-interval=1d channel.skip-dfs-channels=yes country=canada datapath.bridge=bridge_Network datapath.client-to-client-forwarding=($wificlientforwarding) distance=indoors mode=ap name=Home_W1 security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($w1ssidpw) ssid=($w1ssid);
	add channel.band=5ghz-a/n/ac channel.reselect-interval=1d channel.skip-dfs-channels=yes  country=canada datapath.bridge=bridge_Network datapath.client-to-client-forwarding=($wificlientforwarding) distance=indoors mode=ap name=Home_W1_5G security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($w1ssidpw) ssid=("5G-" . $w1ssid);
				}

	/caps-man provisioning {
	add action=create-enabled hw-supported-modes=gn master-configuration=Home_W1 name-format=prefix-identity name-prefix=2G;
	add action=create-enabled hw-supported-modes=an master-configuration=Home_W1_5G name-format=prefix-identity name-prefix=5G;
				}

/caps-man channel	{
	add extension-channel=disabled frequency=2412 name="2412 (1)" tx-power=20
	add extension-channel=disabled frequency=2437 name="2437 (6)" tx-power=20
	add extension-channel=disabled frequency=2462 name="2462 (11)" tx-power=20
	add extension-channel=disabled frequency=5180 name="5180 (36)"
	add extension-channel=disabled frequency=5200 name="5200 (40)"
	add extension-channel=disabled frequency=5220 name="5220 (44)"
	add extension-channel=disabled frequency=5240 name="5240 (48)"
	add extension-channel=disabled frequency=5260 name="5260 (52)"
	add extension-channel=disabled frequency=5280 name="5280 (56)"
	add extension-channel=disabled frequency=5300 name="5300 (60)"
	add extension-channel=disabled frequency=5320 name="5320 (64)"
	add extension-channel=disabled frequency=5745 name="5745 (149)" tx-power=23
	add extension-channel=disabled frequency=5765 name="5765 (153)" tx-power=23
	add extension-channel=disabled frequency=5785 name="5785 (157)" tx-power=23
	add extension-channel=disabled frequency=5805 name="5805 (161)" tx-power=23
	add extension-channel=disabled frequency=5825 name="5825 (165)" tx-power=23
	}

# wait for firewall
:delay 1s;
/ip firewall filter {
add action=accept chain=input comment="default configuration" protocol=icmp;
add action=accept chain=input comment="default configuration" connection-state=established;
add action=accept chain=input comment="default configuration" connection-state=related;
add action=accept chain=forward comment="default configuration" connection-state=established;
add action=accept chain=forward comment="default configuration" connection-state=related;
add action=drop chain=forward comment="default configuration" connection-state=invalid;
:if ( $w1mode = 0) do={ add action=accept chain=input dst-port=8291 in-interface=pppoe protocol=tcp ;}
:if ( $w1mode = 0) do={ add action=drop chain=input comment="default configuration" in-interface=pppoe ;}
:if ( $w1mode = 1||$w1mode = 2) do={ add action=accept chain=input dst-port=8291 in-interface=ether1 protocol=tcp ;}
:if ( $w1mode = 1||$w1mode = 2) do={ add action=drop chain=input comment="default configuration" in-interface=ether1 ;}
			}

/ip firewall nat {
add action=accept chain=dstnat dst-port=8291 protocol=tcp
add disabled=($dnsmode) action=dst-nat chain=dstnat dst-port=53 protocol=udp src-address="10.$189.131.0/24" to-addresses=($DNShijacking) to-ports=53;
:if ( $w1mode = 0) do={ add action=masquerade chain=srcnat out-interface=pppoe disabled=($w1disabled);}
:if ( $w1mode = 1||$w1mode = 2) do={ add action=masquerade chain=srcnat out-interface=ether1 disabled=($w1disabled);}
add action=masquerade chain=srcnat out-interface=lsn-vpn disabled=($cn2disabled);
			}

/ip firewall mangle  {
:if ( $w1mode = 0) do={ add action=change-mss chain=forward new-mss=1410 out-interface=all-ppp passthrough=yes protocol=tcp tcp-flags=syn tcp-mss=1411-65535 ;}
:if ( $w1mode = 0) do={ add action=change-mss chain=forward in-interface=all-ppp new-mss=1410 passthrough=yes protocol=tcp tcp-flags=syn tcp-mss=1411-65535 ;}
			}

# wait for route
:delay 1s;
/ip route {
:if ( $w1mode = 2) do={/ip route add check-gateway=ping distance=1 gateway=($w1gw) disabled=($w1disabled);}
add check-gateway=ping distance=1 gateway=lsn-vpn routing-mark=CN2_Routing disabled=($cn2disabled);
:if ( $w1mode = 0) do={/ip route add check-gateway=ping distance=10 gateway=pppoe-W1 routing-mark=CN2_Routing disabled=($cn2disabled);}
:if ( $w1mode = 2) do={/ip route add check-gateway=ping distance=10 gateway=($w1gw) routing-mark=CN2_Routing disabled=($cn2disabled);}
		}

/ip route rule {
add dst-address=81.198.87.240 table=main comment=cloud.mikrotik.com;
add dst-address=91.188.51.139 table=main comment=cloud.mikrotik.com;
add dst-address=180.168.254.8/32 table=CN2_Routing comment=DNS;
add dst-address=8.8.8.8/32 table=CN2_Routing comment=DNS;
add dst-address=208.67.220.220/32 table=CN2_Routing comment=DNS;
add dst-address=10.0.0.0/8 src-address="10.$189.128.0/22" table=main;
add dst-address=192.168.0.0/16 src-address="10.$189.128.0/22" table=main;
add dst-address=172.16.0.0/13 src-address="10.$189.128.0/22" table=main;
add dst-address=0.0.0.0/0 src-address="10.$189.128.0/24" table=main;
add dst-address=0.0.0.0/0 src-address="10.$189.129.0/24" table=main;
add dst-address=0.0.0.0/0 src-address="10.$189.130.0/24" table=main;
# add dst-address=0.0.0.0/0 src-address="10.$189.131.0/24" table=CN2_Routing;
# 默认全部都走VPN ，不进行国内国外IP区分。
		}


/system scheduler
add interval=1w name=CNIP_update on-event="\r\
    \n/tool fetch url=http://routeros-device-config.oss-cn-shanghai.aliyuncs.com/LSNA/LSNA_CNIP.rsc  mode=http\r\
    \n:delay 15s;\r\
    \n/import LSNA_CNIP.rsc\r\
    \n/file remove LSNA_CNIP.rsc\r\
    \n" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup

# 设置DHCP网关
:if ( $w1mode = 1) do={
:global dhcpgateway;
:set dhcpgateway [/ip dhcp-client get number=0 gateway]
/ip route add check-gateway=ping distance=10 gateway=($dhcpgateway) routing-mark=CN2_Routing disabled=($cn2disabled);
				};
# 设备配置导入成功以后，更改设备名称。
/system identity set name=($routeridentity);

# 第一次联网后自动下载CNIP路由表。
/system script	{
 add name=CNIP owner=admin policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source="\r\
	\n/tool fetch url=http://routeros-device-config.oss-cn-shanghai.aliyuncs.com/LSNA/LSNA_CNIP.rsc  mode=http\r\
	\n:delay 15s;\r\
	\n/import LSNA_CNIP.rsc  \r\
	\n/file remove LSNA_CNIP.rsc\r\
	\n "	}

/tool netwatch	{
	add host=8.8.8.8 up-script="/system script run CNIP;\r\
	\n/tool netwatch remove numbers=0\r\
	\n/system script remove CNIP"
				}
##############################非开发人员，请勿修改一下脚本#####################################
