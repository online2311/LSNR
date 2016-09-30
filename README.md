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
```

##变量设定 
  
:global w1usr user; “[user]W1宽带账号”
:global w1pw password; “[password]W1宽带密码”
:global w1ssid ssidA; “[ssidA]W1无线SSID”
:global w1ssidpw password; “[password]W1无线密码”
:global w1disabled no; “[no]w1是否启用” 


  
##使用说明
  设备版本升级至 6.37 ，把LSNR.rsc 拖放到 flash/ 目录下。
```
/system reset-configuration no-defaults=yes run-after-reset=flash/LSNR.rsc
```
  执行以上命令进行配置导入