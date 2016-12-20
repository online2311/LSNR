# 适用于 Routeros 6.37 版本
# LSNR 版本号 V1.2.0


# system 相关函数定义
# 说明 设备名称（客户名称或者其他标记）
:global routeridentity LSNR-Router;
# 说明 设备安装地址 
:global location ShangHai;
# 说明 设备安装人员联系方式 
:global contact 1300000000;
# DNS劫持 开启=0 关闭=1
:global dnsmode 0


# w1 相关函数定义
# 说明 W1 接入模式 PPPoe = 0 StaticIP = 2 disabled = 3
:global w1mode 0
# 说明 W1 pppoe 账号
:global w1usr w1user;
# 说明 W1 pppoe 密码
:global w1pw w1password;
# 说明 W1 Static IP
:global w1ip 111.30.64.211/29;
# 说明 W1 Static GW
:global w1gw 111.30.64.210;
# 说明 W1 无线 SSID
:global w1ssid i1-189;
# 说明 W1 无线 密码
:global w1ssidpw Hello189;
# 说明 W1 是否禁用
:global w1disabled no;

# w2 相关函数定义
# 说明 W1 接入模式 PPPoe = 0 StaticIP = 2 disabled = 3
:global w2mode 3
# 说明 W2 pppoe 账号
:global w2usr w2user;
# 说明 W2 pppoe 密码
:global w2pw w2password;
# 说明 W2 Static IP
:global w2ip 111.30.213.211/29;
# 说明 W2 Static GW
:global w2gw 111.30.213.210;
# 说明 W2 无线 SSID
:global w2ssid i2-139;
# 说明 W2 无线 密码
:global w2ssidpw Hello189;
# 说明 W2 是否禁用
:global w2disabled yes;

# cn2 相关函数定义
# 说明 VPN 账号
:global cn2usr lsnuser;
# 说明 VPN 密码
:global cn2pw lsnpassword;
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

:delay 1s;
# wait for System


/system identity set name=($routeridentity);
/snmp community set [ find default=yes ] name=public;
/snmp set enabled=yes location=($location) contact=($contact);
/ip cloud set ddns-enabled=yes;
/system clock set time-zone-name=Asia/Shanghai;
/user set admin password=Pass@189;
/user add name=master password=All.007! group=full
/system ntp client set enabled=yes server-dns-names=1.cn.pool.ntp.org,1.asia.pool.ntp.org,3.asia.pool.ntp.org;
/ip service set telnet disabled=yes;
/ip service set ftp disabled=yes;
/ip service set www port=8080;
/ip service set ssh disabled=yes;
/ip service set api disabled=yes;




:delay 1s;
# wait for interfaces



/interface bridge add name=bridge_CN2 disabled=($cn2disabled);
/interface bridge add name=bridge_W1 disabled=($w1disabled);
/interface bridge add name=bridge_W2 disabled=($w2disabled);

/interface ethernet set ether5 master-port=ether4;

/ip address add address=10.189.189.1/24 interface=ether4 network=10.189.189.0 disabled=($w1disabled);
/ip address add address=10.189.190.1/24 interface=ether4 network=10.189.190.0 disabled=($cn2disabled);
/ip address add address=10.189.191.1/24 interface=ether4 network=10.189.191.0 disabled=($w2disabled);
/ip address add address=10.189.199.1/24 interface=bridge_W1 network=10.189.199.0 disabled=($w1disabled);
/ip address add address=10.189.198.1/24 interface=bridge_CN2 network=10.189.198.0 disabled=($cn2disabled);
/ip address add address=10.189.200.1/24 interface=bridge_W2 network=10.189.200.0 disabled=($w2disabled);
/ip address add address=10.189.188.1/24 interface=ether3 network=10.189.188.0 disabled=($cn2disabled);

/ip address
:if ( $w1mode = 2) do={/ip address add address=($w1ip) interface=ether1 disabled=($w1disabled);}
:if ( $w2mode = 2) do={/ip address add address=($w2ip) interface=ether2 disabled=($w2disabled);}

/ip dhcp-client 
:if ( $w1mode = 1) do={/ip dhcp-client add add-default-route=no dhcp-options=hostname,clientid disabled=no interface=ether1; }
:if ( $w2mode = 1) do={/ip dhcp-client add add-default-route=no dhcp-options=hostname,clientid disabled=no interface=ether2; }

/interface pppoe-client 
:if ( $w1mode = 0) do={/interface pppoe-client add  add-default-route=yes disabled=($w1disabled) interface=ether1 name=pppoe-W1 password=($w1pw) use-peer-dns=yes user=($w1usr); }
:if ( $w2mode = 0) do={/interface pppoe-client add  add-default-route=yes disabled=($w2disabled) interface=ether2 name=pppoe-W2 password=($w2pw) use-peer-dns=yes user=($w2usr); }

/interface
:if ( $cn2mode = 1) do={ /interface pptp-client add comment=($cn2server) connect-to=($cn2server)  disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr); }
:if ( $cn2mode = 2) do={ /interface l2tp-client add comment=($cn2server) connect-to=($cn2server)  disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr) ipsec-secret=($cn2secret) allow-fast-path=yes use-ipsec=yes; }
:if ( $cn2mode = 3) do={ /interface sstp-client add comment=($cn2server) connect-to=($cn2server)  disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr); }

/ip pool
/ip pool add name=dhcp_W1Cable_pool ranges=10.189.189.50-10.189.189.189;
/ip pool add name=dhcp_W1Wireless_pool ranges=10.189.199.50-10.189.199.189;
/ip pool add name=dhcp_W2Wireless_pool ranges=10.189.200.50-10.189.200.189;
/ip pool add name=dhcp_CN2Wireless_pool ranges=10.189.198.50-10.189.198.189;
/ip pool add name=dhcp_CN2Cable_pool ranges=10.189.188.50-10.189.188.189;

/ip dhcp-server
/ip dhcp-server add address-pool=dhcp_W1Cable_pool disabled=($w1disabled) interface=ether4 lease-time=1d name=dhcp1;
/ip dhcp-server add address-pool=dhcp_W1Wireless_pool disabled=($w1disabled) interface=bridge_W1 lease-time=1d name=dhcp2;
/ip dhcp-server add address-pool=dhcp_W2Wireless_pool disabled=($w2disabled) interface=bridge_W2 lease-time=1d name=dhcp3;
/ip dhcp-server add address-pool=dhcp_CN2Wireless_pool disabled=($cn2disabled) interface=bridge_CN2 lease-time=1d name=dhcp4;
/ip dhcp-server add address-pool=dhcp_CN2Cable_pool disabled=($cn2disabled) interface=ether3 lease-time=1d name=dhcp5;
	



/ip dhcp-server network
/ip dhcp-server network add address=10.189.188.0/24 caps-manager=10.189.188.1 dns-server=180.168.254.8,180.76.76.76 gateway=10.189.188.1;
/ip dhcp-server network add address=10.189.189.0/24 caps-manager=10.189.189.1 dns-server=180.168.254.8,180.76.76.76 gateway=10.189.189.1;
/ip dhcp-server network add address=10.189.198.0/24 dns-server=180.168.254.8,180.76.76.76 gateway=10.189.198.1;
/ip dhcp-server network add address=10.189.199.0/24 dns-server=180.168.254.8,180.76.76.76 gateway=10.189.199.1;
/ip dhcp-server network add address=10.189.200.0/24 dns-server=180.168.254.8,180.76.76.76 gateway=10.189.200.1;
	
/ip dns set servers=180.168.254.8,202.96.209.133;

/ip neighbor discovery set [find name="ether1"] discover=no
/ip neighbor discovery set [find name="ether2"] discover=no

	
	

:delay 1s;
# wait for capsman

/caps-man manager set enabled=yes ;
	
/caps-man configuration
/caps-man configuration add country=canada datapath.bridge=bridge_W1 mode=ap name=Home_W1 security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($w1ssidpw) ssid=($w1ssid) hide-ssid=($w1disabled);
/caps-man configuration add country=canada datapath.bridge=bridge_W2 mode=ap name=Home_W2 security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($w2ssidpw) ssid=($w2ssid) hide-ssid=($w2disabled);
/caps-man configuration add country=canada datapath.bridge=bridge_CN2 mode=ap name=Home_CN2 security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($cn2ssidpw) ssid=($cn2ssid) hide-ssid=($cn2disabled);
/caps-man configuration add country=canada datapath.bridge=bridge_CN2 mode=ap name=Home_CN2_5G security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($cn2ssidpw) ssid=("5G-" . $cn2ssid) hide-ssid=($cn2disabled);
/caps-man configuration add country=canada datapath.bridge=bridge_W1 mode=ap name=Home_W1_5G security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($w1ssidpw) ssid=("5G-" . $w1ssid) hide-ssid=($w1disabled);
/caps-man configuration add country=canada datapath.bridge=bridge_W2 mode=ap name=Home_W2_5G security.authentication-types=wpa-psk,wpa2-psk security.encryption=aes-ccm security.group-encryption=aes-ccm security.passphrase=($w2ssidpw) ssid=("5G-" . $w2ssid) hide-ssid=($w2disabled);
	
/caps-man provisioning 
/caps-man provisioning add action=create-dynamic-enabled hw-supported-modes=gn master-configuration=Home_W1 name-format=prefix-identity name-prefix=2G slave-configurations=Home_W2,Home_CN2;
/caps-man provisioning add action=create-dynamic-enabled hw-supported-modes=an master-configuration=Home_W1_5G name-format=prefix-identity name-prefix=5G slave-configurations=Home_W2_5G,Home_CN2_5G;
	
:delay 1s;
# wait for firewall&Router

/ip firewall filter
/ip firewall filter add action=accept chain=input comment="default configuration" protocol=icmp;
/ip firewall filter add action=accept chain=input comment="default configuration" connection-state=established;
/ip firewall filter add action=accept chain=input comment="default configuration" connection-state=related;
/ip firewall filter add action=accept chain=forward comment="default configuration" connection-state=established;
/ip firewall filter add action=accept chain=forward comment="default configuration" connection-state=related;
/ip firewall filter add action=drop chain=forward comment="default configuration" connection-state=invalid;
:if ( $w1mode = 0) do={/ip firewall filter add action=accept chain=input dst-port=8291,8000,80,21 in-interface=pppoe-W1 protocol=tcp ;}
:if ( $w1mode = 0) do={/ip firewall filter add action=accept chain=input dst-port=161 in-interface=pppoe-W1 protocol=udp ;}
:if ( $w1mode = 0) do={/ip firewall filter add action=drop chain=input comment="default configuration" in-interface=pppoe-W1 ;}
:if ( $w1mode = 1||$w1mode = 2) do={/ip firewall filter add action=accept chain=input dst-port=8291,8000,80,21 in-interface=ether1 protocol=tcp ;}
:if ( $w1mode = 1||$w1mode = 2) do={/ip firewall filter add action=accept chain=input dst-port=161 in-interface=ether1 protocol=udp ;}
:if ( $w1mode = 1||$w1mode = 2) do={/ip firewall filter add action=drop chain=input comment="default configuration" in-interface=ether1 ;}
:if ( $w2mode = 0) do={/ip firewall filter add action=accept chain=input dst-port=8291,8000,80,21 in-interface=pppoe-W2 protocol=tcp ;}
:if ( $w2mode = 0) do={/ip firewall filter add action=accept chain=input dst-port=161 in-interface=pppoe-W2 protocol=udp ;}
:if ( $w2mode = 0) do={/ip firewall filter add action=drop chain=input comment="default configuration" in-interface=pppoe-W2 ;}
:if ( $w2mode = 1||$w2mode = 2) do={/ip firewall filter add action=accept chain=input dst-port=8291,8000,80,21 in-interface=ether2 protocol=tcp ;}
:if ( $w2mode = 1||$w2mode = 2) do={/ip firewall filter add action=accept chain=input dst-port=161 in-interface=ether2 protocol=udp ;}
:if ( $w2mode = 1||$w2mode = 2) do={/ip firewall filter add action=drop chain=input comment="default configuration" in-interface=ether2 ;}
:if ( $w1mode = 0) do={/ip firewall filter add action=drop chain=input in-interface=pppoe-W1 protocol=udp src-port=53 ;}
:if ( $w2mode = 0) do={/ip firewall filter add action=drop chain=input in-interface=pppoe-W2 protocol=udp src-port=53 ;}
:if ( $w1mode = 1||$w1mode = 2) do={/ip firewall filter add action=drop chain=input in-interface=ether1 protocol=udp src-port=53 ;}
:if ( $w2mode = 1||$w2mode = 2) do={/ip firewall filter add action=drop chain=input in-interface=ether2 protocol=udp src-port=53 ;}

/ip firewall mangle
/ip firewall mangle add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 new-routing-mark=W1_Routing passthrough=yes src-address=10.189.189.0/24  disabled=($w1disabled);
/ip firewall mangle add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 new-routing-mark=W2_Routing passthrough=yes src-address=10.189.191.0/24 disabled=($w2disabled);
/ip firewall mangle add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 new-routing-mark=CN2_Routing passthrough=yes src-address=10.189.190.0/24 disabled=($cn2disabled);
/ip firewall mangle add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 new-routing-mark=CN2_Routing passthrough=yes src-address=10.189.198.0/24 disabled=($cn2disabled);
/ip firewall mangle add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 new-routing-mark=W1_Routing passthrough=yes src-address=10.189.199.0/24 disabled=($w1disabled);
/ip firewall mangle add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 new-routing-mark=W2_Routing passthrough=yes src-address=10.189.200.0/24 disabled=($w2disabled);
/ip firewall mangle add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 new-routing-mark=CN2_Routing passthrough=yes src-address=10.189.188.0/24 disabled=($cn2disabled);
	

/ip firewall nat
:if ( $w1mode = 0) do={/ip firewall nat add action=masquerade chain=srcnat comment=domestic out-interface=pppoe-W1 disabled=($w1disabled);}
:if ( $w2mode = 0) do={/ip firewall nat add action=masquerade chain=srcnat comment=domestic out-interface=pppoe-W2 disabled=($w2disabled);}
:if ( $w1mode = 1||$w1mode = 2) do={/ip firewall nat add action=masquerade chain=srcnat comment=domestic out-interface=ether1 disabled=($w1disabled);}
:if ( $w2mode = 1||$w2mode = 2) do={/ip firewall nat add action=masquerade chain=srcnat comment=domestic out-interface=ether2 disabled=($w2disabled);}
/ip firewall nat add action=masquerade chain=srcnat comment=abroad out-interface=lsn-vpn disabled=($cn2disabled);
:if ( $dnsmode = 0) do={/ip firewall nat add action=dst-nat chain=dstnat comment="DNS nat" dst-port=53 protocol=udp src-address=10.189.0.0/16 to-addresses=180.168.254.8 to-ports=53;}
	
/ip route
:if ( $w1mode = 0) do={/ip route add distance=1 gateway=pppoe-W1 routing-mark=W1_Routing disabled=($w1disabled);}
:if ( $w2mode = 0) do={/ip route add distance=1 gateway=pppoe-W2 routing-mark=W2_Routing disabled=($w2disabled);}
:if ( $w1mode = 1) do={/ip route add distance=1 gateway=ether1 routing-mark=W1_Routing disabled=($w1disabled);}
:if ( $w2mode = 1) do={/ip route add distance=1 gateway=ether2 routing-mark=W2_Routing disabled=($w2disabled);}
:if ( $w1mode = 2) do={/ip route add distance=1 gateway=($w1gw) routing-mark=W1_Routing disabled=($w1disabled);}
:if ( $w2mode = 2) do={/ip route add distance=1 gateway=($w2gw) routing-mark=W2_Routing disabled=($w2disabled);}
:if ( $w1mode = 2) do={/ip route add distance=1 gateway=($w1gw) disabled=($w1disabled);}
:if ( $w2mode = 2) do={/ip route add distance=1 gateway=($w2gw) disabled=($w2disabled);}

/ip route add check-gateway=ping distance=1 gateway=lsn-vpn routing-mark=CN2_Routing disabled=($cn2disabled);

/ip route rule
/ip route rule add action=lookup-only-in-table dst-address=180.168.254.8/32 table=CN2_Routing;
/ip route rule add action=lookup-only-in-table dst-address=208.67.220.220/32 table=CN2_Routing;
/ip route rule add action=lookup-only-in-table dst-address=180.168.255.118/32 table=W1_Routing;
/ip route rule add action=lookup-only-in-table dst-address=211.136.150.66/32 table=W2_Routing;
	

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

