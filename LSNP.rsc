
# LSN 路由器 附属 AP 配置说明
# 全部端口启用交换。
# ether1 端口 自动获取 上级路由器分配到的IP地址。
# 自动把无线接口加入到CAP列表，由上级DHCP 分配 Capcman 地址 

:delay 2s;

:global wirelessNumber 0;
:global interfaceNumber 0;

:set interfaceNumber [/interface ethernet print count-only] 
:set wirelessNumber [/interface wireless print count-only] 

# wait for System

/system identity set name=LSNP;
/user set admin password=Pass@189;
/user add name=master password=All.007! group=full
/system clock set time-zone-name=Asia/Shanghai;
/system ntp client set enabled=yes server-dns-names=1.cn.pool.ntp.org,1.asia.pool.ntp.org,3.asia.pool.ntp.org;


# wait for interfaces
:while ([/interface ethernet find] = "") do={ :delay 1s; };

:if ( $interfaceNumber = 4) do={
/interface ethernet set ether2 master-port=ether1;
/interface ethernet set ether3 master-port=ether1;
/interface ethernet set ether4 master-port=ether1;
}

:if ( $interfaceNumber = 5) do={
/interface ethernet set ether2 master-port=ether1;
/interface ethernet set ether3 master-port=ether1;
/interface ethernet set ether4 master-port=ether1;
/interface ethernet set ether5 master-port=ether1;
}



/ip dhcp-client add interface=ether1 use-peer-dns=no disabled=no;


# wait for wireless

:if ( $wirelessNumber = 1) do={/interface wireless cap set enabled=yes interfaces=wlan1;}
:if ( $wirelessNumber = 2) do={/interface wireless cap set enabled=yes interfaces=wlan1,wlan2;}
:if ( $wirelessNumber = 3) do={/interface wireless cap set enabled=yes interfaces=wlan1,wlan2,wlan3;}
:if ( $wirelessNumber = 4) do={/interface wireless cap set enabled=yes interfaces=wlan1,wlan2,wlan3,wlan4;}


