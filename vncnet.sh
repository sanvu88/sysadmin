#!/bin/bash

if [ ! -f /bin/netstat ]; then
	yum -y install net-tools >/dev/null 2>&1
	sudo apt-get update >/dev/null 2>&1
	sudo apt-get -y install net-tools >/dev/null 2>&1
fi
if [ ! -f /usr/bin/sar ]; then
	yum -y install sysstat >/dev/null 2>&1
	sudo apt-get update >/dev/null 2>&1 
	sudo apt-get -y install sysstat >/dev/null 2>&1
fi
if [ ! -f /usr/bin/bc ]; then
	yum -y install bc >/dev/null 2>&1
	sudo apt-get update >/dev/null 2>&1 
	sudo apt-get -y install bc >/dev/null 2>&1
fi
if [ ! -d /tmp ]; then
	mkdir -p /tmp
fi




a=a
while [ $a = 'a' ]
do

CPUdangdung=`sar -u  1 1 | grep Average: | awk '{print $3}'`
block=`fdisk -l| grep I/O|  awk '{print $7}'| head -1`
IOsar=`sar -b  1 1 | grep Average:`
bread_s=`echo "$IOsar" | awk '{print $5}'| tr . ' ' | awk '{print $1}'`; IOdangdung_doc=$((bread_s*block/1024/1024))
bwrtn_s=`echo "$IOsar" | awk '{print $6}'| tr . ' ' | awk '{print $1}'`; IOdangdung_ghi=$((bwrtn_s*block/1024/1024))

RAMsar=`sar -r  1 1 | grep Average:`
used=`echo "$RAMsar" | awk '{print $3}'| tr . ' ' | awk '{print $1}'`
buffer=`echo "$RAMsar" | awk '{print $5}'| tr . ' ' | awk '{print $1}'`
cached=`echo "$RAMsar" | awk '{print $6}'| tr . ' ' | awk '{print $1}'`
RAMdangdung=$(((used-buffer-cached)/1024))

BWsar="`sar -n DEV 1 1`"
bwnhanvao=$(echo "scale=3;(`echo "$BWsar"|grep Average:| grep -v "IFACE"| awk {'print $5'} |tr "\n" "+"`0)"| bc -q| awk '{printf "%.0f\n", $0}')
bwtruyendi=$(echo "scale=3;(`echo "$BWsar"|grep Average:| grep -v "IFACE"| awk {'print $6'} |tr "\n" "+"`0)"| bc -q| awk '{printf "%.0f\n", $0}')

netstat_an_grep_80=`netstat -an|grep :80`
netstat_an_grep_443=`netstat -an|grep :443`
netstat_an_grep_ESTA=`netstat -an | grep ESTA`

netstatport80="`echo "$netstat_an_grep_80" |awk '!/:8080/'|awk '!/:8081/' |awk '{print $5}'|cut -d":" -f1|sort|uniq -c|sort -rn | grep '\.'| grep -v "0.0.0.0"`"
netstatport443="`echo "$netstat_an_grep_443" |awk '{print $5}'|cut -d":" -f1|sort|uniq -c|sort -rn | grep '\.'| grep -v "0.0.0.0"|tr -s " "`"

port80truyvan=`netstat -n | grep :80 |awk '!/:8080/'|awk '!/:8081/'|wc -l`
port443truyvan=`netstat -n | grep :443 |wc -l`
port80numberip=`echo "$netstatport80"| wc -l`
port443numberip=`echo "$netstatport443"| wc -l`
port80thietlap=`echo "$netstat_an_grep_80"|awk '!/:8080/'|awk '!/:8081/'| grep ESTA| wc -l`
port443thietlap=`echo "$netstat_an_grep_443" | grep ESTA | wc -l`

#port80listip="`echo "$netstatport80" | head -24 |tr -s " "`"
#port443listip="`echo "$netstatport443" | head -24 |tr -s " "`"
#thietlaplistip="`echo "$netstat_an_grep_ESTA" |awk '{print $5}'|cut -d":" -f1|sort|uniq -c|sort -rn| grep '\.' | grep -v "0.0.0.0"|head -24|tr -s " "`"
listiphostname=`netstat -tn | awk '{print $5}' | sed -e 's/:.*//' | grep '\.'|xargs -i sh -c 'echo {} $(getent hosts {})' | awk '$1 == $2 {print $2, $3; next}; {print}' | sort | uniq -c | sort -nr | head -24`

column=`pr -mT  --width=145 --page-width=145 <(echo "Những IP Address kết nối nhiều nhất đến:"; echo "$listiphostname")`

date=`TZ=Asia/Ho_Chi_Minh date +"GIỜ:%HH%M-NGÀY:%d-%m-%Y"`
clear
echo '########### Bảng thống kê máy chủ dành cho SYSTEM ADMIN LINUX SERVER VNC SYS: ########### '$date' ###########

	Xung nhịp CPU đang dùng là: ~'$CPUdangdung'%	Lượng RAM đang dùng là: ~'$RAMdangdung'MB		Tốc độ tải IO ổ cứng đang là:	~'$IOdangdung_doc'MB/s ĐỌC
															~'$IOdangdung_ghi'MB/s GHI 				
	Tổng SỐ TRUY VẤN vào port 80 là: '$port80truyvan'	(Do tất cả '$port80numberip' IP Address truy vấn đến)	 
	Tổng SỐ TRUY VẤN vào port 443 là: '$port443truyvan'	(Do tất cả '$port443numberip' IP Address truy vấn đến)	
											
	 Số truy vấn ĐÃ ĐƯỢC THIẾT LẬP là:			|	TỐC ĐỘ MẠNG:
	 Port 80: '$port80thietlap' kết nối					|	Đang nhận vào là: '$bwnhanvao'KB/s
	 Port 443: '$port443thietlap' kết nối					|	Đang truyền đi là: '$bwtruyendi'KB/s

'"$column"'

Cám ơn bạn đã sử dụng!'  
a=a;
done