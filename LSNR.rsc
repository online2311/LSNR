# 适用于 Routeros 6.37 版本
# w1 相关函数定义
# 说明 W1 pppoe 账号
:global w1usr ad73212126;
# 说明 W1 pppoe 密码
:global w1pw MJpe7rfA;
# 说明 W1 无线 SSID
:global w1ssid i1-189;
# 说明 W1 无线 密码
:global w1ssidpw All.007!;
# 说明 W1 是否禁用
:global w1disabled no;

#:log info "w1usr:$w1usr"
#:log info "w1pw:$w1pw"
#:log info "w1ssid:$w1ssid"
#:log info "w1ssidpw:$w1ssidpw"
#:log info "w1disabled:$w1disabled"

# w2 相关函数定义
# 说明 W2 pppoe 账号
:global w2usr 13901666840;
# 说明 W2 pppoe 密码
:global w2pw 850361;
# 说明 W2 无线 SSID
:global w2ssid i2-139;
# 说明 W2 无线 密码
:global w2ssidpw All.007!;
# 说明 W1 是否禁用
:global w2disabled yes;

#:log info "w2usr:$w2usr"
#:log info "w2pw:$w2pw"
#:log info "w2ssid:$w2ssid"
#:log info "w2ssidpw:$w2ssidpw"
#:log info "w2disabled:$w2disabled"

# cn2 相关函数定义
# 说明 VPN 账号
:global cn2usr 12344321;
# 说明 VPN 密码
:global cn2pw 12344321;
:global cn2usr 12344321;
# 说明 VPN 无线名称
:global cn2ssid LSN;
# 说明 VPN 无线密码
:global cn2ssidpw All.007!;
# 说明 是否禁用VPN服务
:global cn2disabled no;
# 说明 替换为VPN接入服务器地址
:global cn2server two.ca17.net;
# 说明 PPTP = 1 L2TP = 2 SSTP = 3
:global cn2mode 3;
# 说明 仅配置为L2TP 模式下需要此参数
:global cn2secret ca17;

#:log info "cn2usr:$cn2usr"
#:log info "cn2pw:$cn2pw"
#:log info "cn2ssid:$cn2ssid"
#:log info "cn2ssidpw:$cn2ssidpw"
#:log info "cn2disabled:$cn2disabled"
#:log info "cn2server:$cn2server"
#:log info "cn2mode:$cn2mode"
#:log info "cn2secret:$cn2secret"

# wireless 相关函数定义
:global wirelessEnabled 0;
:global interfacewireless 0;

:if ([:len [/system package find name="wireless" !disabled]] != 0) do={
:set wirelessEnabled 1;
}

:if ([:len [/interface wireless find name="wlan1"]] != 0) do={
:set interfacewireless 1;
}

:if ([:len [/interface wireless find name="wlan2"]] != 0) do={
:set interfacewireless 2;
}

:log info "wirelessEnabled:$wirelessEnabled"
:log info "interfacewireless:$interfacewireless"

# system 相关函数定义

:global routeridentity LSN-Router;
:global routerpw All.007!;


#:log info "routeridentity:$routeridentity"
#:log info "routerpw:$routerpw"



# wait for System

/system identity set name=LSN-Router;
/snmp community set [ find default=yes ] name=LSN-Router
/snmp set enabled=yes location=LSN-Router
/ip cloud set ddns-enabled=yes
/system clock set time-zone-name=Asia/Shanghai
/user set admin password=All.007!;
/system ntp client set enabled=yes server-dns-names=1.cn.pool.ntp.org,1.asia.pool.ntp.org,3.asia.pool.ntp.org;

/ip service
set telnet disabled=yes
set ftp disabled=yes
set www port=8080
set ssh disabled=yes
set api disabled=yes





# wait for interfaces


/interface bridge
add name=bridge_CN2 disabled=($cn2disabled)
add name=bridge_W1 disabled=($w1disabled)
add name=bridge_W2 disabled=($w2disabled)

/interface ethernet
set [ find default-name=ether1 ] name=ether1-W1
set [ find default-name=ether2 ] name=ether2-W2
set [ find default-name=ether3 ] name=ether3-CN2
set [ find default-name=ether4 ] name=ether4-wired
set [ find default-name=ether5 ] master-port=ether4-wired name=ether5-wired


/ip address
add address=10.189.189.1/24 interface=ether4-wired network=10.189.189.0 disabled=($w1disabled)
add address=10.189.199.1/24 interface=bridge_W1 network=10.189.199.0 disabled=($w1disabled)
add address=10.189.198.1/24 interface=bridge_CN2 network=10.189.198.0 disabled=($cn2disabled)
add address=10.189.200.1/24 interface=bridge_W2 network=10.189.200.0 disabled=($w2disabled)
add address=10.189.188.1/24 interface=ether3-CN2 network=10.189.188.0 disabled=($cn2disabled)
add address=10.189.190.1/24 interface=ether4-wired network=10.189.190.0 disabled=($w2disabled)


/interface pppoe-client
add add-default-route=yes default-route-distance=1  disabled=($w1disabled) interface=\
    ether1-W1 name=pppoe-W1 password=($w1pw) use-peer-dns=yes user=\
    ($w1usr)
add  disabled=($w2disabled) interface=ether2-W2 name=pppoe-W2 password=($w2pw) \
    use-peer-dns=yes user=($w2usr)  

/interface
:if ( $cn2mode = 1) do={ /interface pptp-client add comment=($cn2server) connect-to=($cn2server)  disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr) };
:if ( $cn2mode = 2) do={ /interface l2tp-client add comment=($cn2server) connect-to=($cn2server)  disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr) ipsec-secret=($cn2secret) allow-fast-path=yes use-ipsec=yes };
:if ( $cn2mode = 3) do={ /interface sstp-client add comment=($cn2server) connect-to=($cn2server)  disabled=($cn2disabled) name=lsn-vpn password=($cn2pw) user=($cn2usr) };

/ip pool
add name=dhcp_W1Cable_pool ranges=10.189.189.50-10.189.189.189
add name=dhcp_W1Wireless_pool ranges=10.189.199.100-10.189.199.200
add name=dhcp_W2Wireless_pool ranges=10.189.200.100-10.189.200.200
add name=dhcp_CN2Wireless_pool ranges=10.189.198.100-10.189.198.200
add name=dhcp_CN2Cable_pool ranges=10.189.188.100-10.189.188.200

/ip dhcp-server
add address-pool=dhcp_W1Cable_pool disabled=($w1disabled) interface=ether4-wired \
    lease-time=1d name=dhcp1
add address-pool=dhcp_W1Wireless_pool disabled=($w1disabled) interface=bridge_W1 \
    lease-time=1d name=dhcp2
add address-pool=dhcp_W2Wireless_pool disabled=($w2disabled) interface=bridge_W2 \
    lease-time=1d name=dhcp3
add address-pool=dhcp_CN2Wireless_pool disabled=($cn2disabled) interface=bridge_CN2 \
    lease-time=1d name=dhcp4
add address-pool=dhcp_CN2Cable_pool disabled=($cn2disabled) interface=ether3-CN2 \
    lease-time=1d name=dhcp5
	



/ip dhcp-server network
add address=10.189.188.0/24 caps-manager=10.189.188.1 dns-server=\
    8.8.8.8,208.67.220.220 gateway=10.189.188.1
add address=10.189.189.0/24 caps-manager=10.189.189.1 dns-server=\
    223.5.5.5,114.114.114.114 gateway=10.189.189.1
add address=10.189.198.0/24 dns-server=8.8.8.8,208.67.220.220 gateway=\
    10.189.198.1
add address=10.189.199.0/24 dns-server=223.5.5.5,114.114.114.114 gateway=\
    10.189.199.1
add address=10.189.200.0/24 dns-server=223.5.5.5,114.114.114.114 gateway=\
    10.189.200.1
	
/ip dns
set servers=202.96.209.133,114.114.114.114


	
	


# wait for capsman

/caps-man manager
set enabled=yes
	
/caps-man configuration
add country=canada datapath.bridge=bridge_W1 mode=ap name=Home_W1 \
    security.authentication-types=wpa-psk,wpa2-psk security.encryption=\
    aes-ccm security.group-encryption=aes-ccm security.passphrase=($w1ssidpw) \
    ssid=($w1ssid) hide-ssid=($w1disabled)
add country=canada datapath.bridge=bridge_W2 mode=ap name=Home_W2 \
    security.authentication-types=wpa-psk,wpa2-psk security.encryption=\
    aes-ccm security.group-encryption=aes-ccm security.passphrase=($w2ssidpw) \
    ssid=($w2ssid) hide-ssid=($w2disabled)
add country=canada datapath.bridge=bridge_CN2 mode=ap name=Home_CN2 \
    security.authentication-types=wpa-psk,wpa2-psk security.encryption=\
    aes-ccm security.group-encryption=aes-ccm security.passphrase=($cn2ssidpw) \
    ssid=($cn2ssid) hide-ssid=($cn2disabled)
add country=canada datapath.bridge=bridge_CN2 mode=ap name=Home_CN2_5G \
    security.authentication-types=wpa-psk,wpa2-psk security.encryption=\
    aes-ccm security.group-encryption=aes-ccm security.passphrase=($cn2ssidpw) \
    ssid=($cn2ssid . "_5G") hide-ssid=($cn2disabled)
add country=canada datapath.bridge=bridge_W1 mode=ap name=Home_W1_5G \
    security.authentication-types=wpa-psk,wpa2-psk security.encryption=\
    aes-ccm security.group-encryption=aes-ccm security.passphrase=($w1ssidpw)\
    ssid=($w1ssid . "_5G") hide-ssid=($w1disabled)
add country=canada datapath.bridge=bridge_W2 mode=ap name=Home_W2_5G \
    security.authentication-types=wpa-psk,wpa2-psk security.encryption=\
    aes-ccm security.group-encryption=aes-ccm security.passphrase=($w2ssidpw) \
    ssid=($w2ssid . "_5G") hide-ssid=($w2disabled)
	
/caps-man provisioning
add action=create-dynamic-enabled hw-supported-modes=gn master-configuration=\
    Home_W1 name-format=prefix-identity name-prefix=2G slave-configurations=\
    Home_W2,Home_CN2
add action=create-dynamic-enabled hw-supported-modes=an master-configuration=\
    Home_W1_5G name-format=prefix-identity name-prefix=5G \
    slave-configurations=Home_W2_5G,Home_CN2_5G
	

# wait for firewall&Router

/ip firewall filter
add action=accept chain=input comment="default configuration" protocol=icmp
add action=accept chain=input comment="default configuration" \
    connection-state=established
add action=accept chain=input comment="default configuration" \
    connection-state=related
add action=accept chain=input dst-port=8291,8000,80,21 in-interface=\
    pppoe-W1 protocol=tcp
add action=accept chain=input dst-port=161 in-interface=pppoe-W1 protocol=\
    udp
add action=drop chain=input comment="default configuration" in-interface=\
    pppoe-W1
add action=accept chain=forward comment="default configuration" \
    connection-state=established
add action=accept chain=forward comment="default configuration" \
    connection-state=related
add action=drop chain=forward comment="default configuration" \
    connection-state=invalid
add action=drop chain=input in-interface=pppoe-W1 protocol=udp src-port=53
add action=drop chain=input in-interface=pppoe-W2 protocol=udp src-port=53

/ip firewall mangle
add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 \
    new-routing-mark=W1_Routing passthrough=yes src-address=10.189.189.0/24  disabled=($w1disabled)
add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 \
    new-routing-mark=W1_Routing passthrough=yes src-address=10.189.199.0/24 disabled=($w1disabled)
add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 \
    new-routing-mark=CN2_Routing passthrough=yes src-address=10.189.188.0/24 disabled=($cn2disabled)
add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 \
    new-routing-mark=CN2_Routing passthrough=yes src-address=10.189.198.0/24 disabled=($cn2disabled)
add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 \
    new-routing-mark=W2_Routing passthrough=yes src-address=10.189.190.0/24 disabled=($w2disabled)
add action=mark-routing chain=prerouting dst-address=!10.189.0.0/16 \
    new-routing-mark=W2_Routing passthrough=yes src-address=10.189.200.0/24 disabled=($w2disabled)
	
/ip firewall nat
add action=masquerade chain=srcnat comment=domestic out-interface=pppoe-W1 disabled=($w1disabled)
add action=masquerade chain=srcnat comment=domestic out-interface=pppoe-W2 disabled=($w2disabled)
add action=masquerade chain=srcnat comment=abroad out-interface=lsn-vpn disabled=($cn2disabled)
add action=dst-nat chain=dstnat comment="DNS nat" dst-port=53 protocol=udp \
    src-address=10.189.188.0/24 to-addresses=8.8.8.8 to-ports=53
add action=dst-nat chain=dstnat comment="DNS nat" dst-port=53 protocol=udp \
    src-address=10.189.198.0/24 to-addresses=8.8.8.8 to-ports=53
add action=dst-nat chain=dstnat comment="DNS nat" dst-port=53 protocol=udp \
    src-address=10.189.189.0/24 to-addresses=180.168.255.118 to-ports=53
add action=dst-nat chain=dstnat comment="DNS nat" dst-port=53 protocol=udp \
    src-address=10.189.199.0/24 to-addresses=180.168.255.118 to-ports=53
add action=dst-nat chain=dstnat comment="DNS nat" dst-port=53 protocol=udp \
    src-address=10.189.190.0/24 to-addresses=211.136.150.66 to-ports=53
add action=dst-nat chain=dstnat comment="DNS nat" dst-port=53 protocol=udp \
    src-address=10.189.200.0/24 to-addresses=211.136.150.66 to-ports=53
	
/ip route
add distance=1 gateway=pppoe-W1 routing-mark=W1_Routing disabled=($w1disabled)
add distance=1 gateway=pppoe-W2 routing-mark=W2_Routing disabled=($w2disabled)
add check-gateway=ping distance=1 gateway=lsn-vpn routing-mark=CN2_Routing disabled=($cn2disabled)

/ip route rule
add action=lookup-only-in-table dst-address=8.8.8.8/32 table=CN2_Routing
add action=lookup-only-in-table dst-address=208.67.220.220/32 table=\
    CN2_Routing
add action=lookup-only-in-table dst-address=180.168.255.118/32 table=\
    W1_Routing
add action=lookup-only-in-table dst-address=211.136.150.66/32 table=\
    W2_Routing
	



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

