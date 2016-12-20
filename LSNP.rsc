
# LSN ·���� ���� AP ����˵��
# ȫ���˿� ���� bridge �� ��Ϊ�����顣
# ether1 �˿� �Զ���ȡ LSN ·�������䵽��IP��ַ��
# �Զ������߽ӿڼ��뵽CAP�б����ϼ�DHCP ���� Capcman ��ַ 

:delay 2s;

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

# wait for System

/system identity set name=LSNR+;
/user set admin password=All.007!;
/system clock set time-zone-name=Asia/Shanghai;
/system ntp client set enabled=yes server-dns-names=1.cn.pool.ntp.org,1.asia.pool.ntp.org,3.asia.pool.ntp.org;


# wait for interfaces
:while ([/interface ethernet find] = "") do={ :delay 1s; };

/interface bridge add name=bridge
/interface bridge port add bridge=bridge interface=ether1
/interface bridge port add bridge=bridge interface=ether2
/interface bridge port add bridge=bridge interface=ether3
/interface bridge port add bridge=bridge interface=ether4
/interface bridge port add bridge=bridge interface=ether5

/ip dhcp-client add interface=ether1 use-peer-dns=no disabled=no;


# wait for wireless
:log info "wirelessEnabled:$wirelessEnabled"
:log info "interfacewireless:$interfacewireless"

:if ( $wirelessEnabled = 1) do={


:if ( $interfacewireless = 1) do={
/interface wireless cap
set enabled=yes interfaces=wlan1		
					}

:if ( $interfacewireless = 2) do={
/interface wireless cap
set enabled=yes interfaces=wlan1,wlan2
					}

}


