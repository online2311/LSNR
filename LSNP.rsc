# ������ Routeros 6.38+ �汾
# LSNR.P �汾�� V1.1.b0417

# LSN ·���� ���� AP ����˵��
# ȫ���˿����ý�����
# ether1 �˿� �Զ���ȡ �ϼ�·�������䵽��IP��ַ��
# �Զ������߽ӿڼ��뵽CAP�б����ϼ�DHCP ���� Capcman ��ַ 

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
:if ( $interfaceNumber = 6) do={
/interface ethernet set ether2 master-port=ether1;
/interface ethernet set ether3 master-port=ether1;
/interface ethernet set ether4 master-port=ether1;
/interface ethernet set ether5 master-port=ether1;
}



:if ( $interfaceNumber = 9) do={
/interface ethernet set ether2 master-port=ether1;
/interface ethernet set ether3 master-port=ether1;
/interface ethernet set ether4 master-port=ether1;
/interface ethernet set ether5 master-port=ether1;
/interface ethernet set ether6 master-port=ether1;
/interface ethernet set ether7 master-port=ether1;
/interface ethernet set ether8 master-port=ether1;
}
:if ( $interfaceNumber = 10) do={
/interface ethernet set ether2 master-port=ether1;
/interface ethernet set ether3 master-port=ether1;
/interface ethernet set ether4 master-port=ether1;
/interface ethernet set ether5 master-port=ether1;
/interface ethernet set ether6 master-port=ether1;
/interface ethernet set ether7 master-port=ether1;
/interface ethernet set ether8 master-port=ether1;
}

:if ( $interfaceNumber = 11) do={
/interface ethernet set ether2 master-port=ether1;
/interface ethernet set ether3 master-port=ether1;
/interface ethernet set ether4 master-port=ether1;
/interface ethernet set ether5 master-port=ether1;
/interface ethernet set ether6 master-port=ether1;
/interface ethernet set ether7 master-port=ether1;
/interface ethernet set ether8 master-port=ether1;
/interface ethernet set ether9 master-port=ether1;
/interface ethernet set ether10 master-port=ether1;
}

:if ( $interfaceNumber = 12) do={
/interface ethernet set ether2 master-port=ether1;
/interface ethernet set ether3 master-port=ether1;
/interface ethernet set ether4 master-port=ether1;
/interface ethernet set ether5 master-port=ether1;
/interface ethernet set ether6 master-port=ether1;
/interface ethernet set ether7 master-port=ether1;
/interface ethernet set ether8 master-port=ether1;
}

:if ( $interfaceNumber = 25) do={
/interface ethernet set ether2 master-port=ether1;
/interface ethernet set ether3 master-port=ether1;
/interface ethernet set ether4 master-port=ether1;
/interface ethernet set ether5 master-port=ether1;
/interface ethernet set ether6 master-port=ether1;
/interface ethernet set ether7 master-port=ether1;
/interface ethernet set ether8 master-port=ether1;
/interface ethernet set ether9 master-port=ether1;
/interface ethernet set ether10 master-port=ether1;
/interface ethernet set ether11 master-port=ether1;
/interface ethernet set ether12 master-port=ether1;
/interface ethernet set ether13 master-port=ether1;
/interface ethernet set ether14 master-port=ether1;
/interface ethernet set ether15 master-port=ether1;
/interface ethernet set ether16 master-port=ether1;
/interface ethernet set ether17 master-port=ether1;
/interface ethernet set ether18 master-port=ether1;
/interface ethernet set ether19 master-port=ether1;
/interface ethernet set ether20 master-port=ether1;
/interface ethernet set ether21 master-port=ether1;
/interface ethernet set ether22 master-port=ether1;
/interface ethernet set ether23 master-port=ether1;
/interface ethernet set ether24 master-port=ether1;
}

:if ( $interfaceNumber = 26) do={
/interface ethernet set ether2 master-port=ether1;
/interface ethernet set ether3 master-port=ether1;
/interface ethernet set ether4 master-port=ether1;
/interface ethernet set ether5 master-port=ether1;
/interface ethernet set ether6 master-port=ether1;
/interface ethernet set ether7 master-port=ether1;
/interface ethernet set ether8 master-port=ether1;
/interface ethernet set ether9 master-port=ether1;
/interface ethernet set ether10 master-port=ether1;
/interface ethernet set ether11 master-port=ether1;
/interface ethernet set ether12 master-port=ether1;
/interface ethernet set ether13 master-port=ether1;
/interface ethernet set ether14 master-port=ether1;
/interface ethernet set ether15 master-port=ether1;
/interface ethernet set ether16 master-port=ether1;
/interface ethernet set ether17 master-port=ether1;
/interface ethernet set ether18 master-port=ether1;
/interface ethernet set ether19 master-port=ether1;
/interface ethernet set ether20 master-port=ether1;
/interface ethernet set ether21 master-port=ether1;
/interface ethernet set ether22 master-port=ether1;
/interface ethernet set ether23 master-port=ether1;
/interface ethernet set ether24 master-port=ether1;
}




/ip dhcp-client add interface=ether1 use-peer-dns=no disabled=no;


# wait for wireless
:delay 1s;
:if ( $wirelessNumber = 1) do={/interface wireless cap set enabled=yes interfaces=wlan1;}
:if ( $wirelessNumber = 2) do={/interface wireless cap set enabled=yes interfaces=wlan1,wlan2;}
:if ( $wirelessNumber = 3) do={/interface wireless cap set enabled=yes interfaces=wlan1,wlan2,wlan3;}
:if ( $wirelessNumber = 4) do={/interface wireless cap set enabled=yes interfaces=wlan1,wlan2,wlan3,wlan4;}


