#!/bin/bash

#字体颜色
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

#server酱，换行前加上%0D%0A%0D%0A%0D%0A
function sc_send(){
text1=合成字幕完成
desp=视频名称-${yttitle}%0D%0A%0D%0A%0D%0A视频身份-${ytname}%0D%0A%0D%0A%0D%0A字幕类型-${ytnamezm}%0D%0A%0D%0A%0D%0A视频总时长-${yttime}%0D%0A%0D%0A%0D%0A视频链接-${ylink}
#此处设置自己的server酱代码
curl hhttps://sc.ftqq.com/SCU91034Teb0f33abd2f0c852211d37048e3.send? -X POST -d "text=${text1}&desp=${desp}"
}


#1.下载视频
function link_ydy(){
    read -p "请输入油管网址:" ylink
    ytname_ydy
    zmtype_ydy
}

#字幕类型选择
function zmtype_ydy(){
echo "------------------------------------------------"
blue "请选择字幕类型"
green "1) 自动英文字幕"
green "2) 普通字幕"
green "3) 无需字幕"
green "4) mkv极清画质"
red "0) 退出脚本"
read -p ":" zmnum
case $zmnum in
    1)
    	youtube-dlc -f best --merge-output-format mp4 --write-auto-sub --sub-lang en --sub-format ass/srt/best --convert-subs srt --id $ylink
    	green "视频字幕下载完毕，正在合并字幕中"
      ptzm=en
      ytnamezm=$ytname.$ptzm.srt
      hb_ydy
      wait
    ;;
    2)
    	ptzm_ydy
    ;;
    3)
    	youtube-dlc -f best --merge-output-format mp4 --id $ylink
        #更改文件名称
     mv $ytname.mp4 /home/$time.mp4
     bypy_ydy
     green "已上传至百度云！"
     text1=无需字幕，已上传至百度云！
     ptzm=无字幕
     sc_send
    	qg_ydy
    ;;
    4)
    	youtube-dlc --merge-output-format mkv --id $ylink
        #更改文件名称
     mv $ytname.mkv /home/$time.mkv
     bypy_ydy
     green "$ytname极清画质mkv下载完毕!"
    ;;
    0)
    	exit
    ;;
    *)
    red "请输入正确数字"
    sleep 1s
    zmtype_ydy
    ;;
esac

}

#普通字幕选择
function ptzm_ydy(){
green "请输入需要的字幕语言如en/zh"
read -p ":" ptzm
ytnamezm=$ytname.$ptzm.srt
youtube-dlc -f best --merge-output-format mp4 --write-sub --sub-lang $ptzm --sub-format ass/srt/best --convert-subs srt --id $ylink
green "视频字幕下载完毕，正在合并字幕中"
hb_ydy
}

#获得油管的id
function ytname_ydy(){
youtube-dl --list-subs $ylink
ytname=${ylink#*tu.be/}
yttitle=`youtube-dlc -e $ylink`
#以下可选择文件名称命名形式，第一种命名方式无法上传百度云
#time=$(date '+%m-%d-%H:%M')
time=$ytname.a
#获得总时间长度
yttime=`youtube-dlc --get-duration $ylink`
echo -e "标题-$yttitle\n身份--$ytname"
}

#2.合并字幕
function hb1_ydy(){
read -p "请输入油管网址:" ylink
ytname_ydy
#模糊匹配字幕，以ytname开头，srt结尾的
ytnamezm=$(find $ytname**srt)
hb_ydy
wait
}

#合并字幕脚本telegram版本
function hb_ydy(){
text1="合并字幕完成啦！"
     green "ytnamezm"
     ffmpeg  -i  $ytname.mp4  -vf subtitles=$ytnamezm -y file:/home/$time.mp4
     #这里将未合二为一的原文件删除（若不需要请在下面两行前加上"#"）
     rm $ytnamezm
     rm $ytname.mp4
     green "合并字幕完成！"
     bypy_ydy
     green "已上传至百度云！"
     text1=合成字幕完成并已上传至百度云！
     sc_send
     qg_ydy
}

#合并字幕脚本
function hb5_ydy(){
text1="合并字幕完成啦！"
read -p "是否需要后台运行?请输入 [Y/n] 默认n:" yn
	[ -z "${yn}" ] && yn="n"
	if [[ $yn == [Yy] ]]; then
#read -p "是否需要后台上传至百度云?请输入 [Y/n] 默认n:" yn1
     #if [[ $yn1 == [Yy] ]]; then
     #yn1=bypy_ydy
     #else
     #yn1=ytname_yty
     #fi
	nohup  ffmpeg  -i  $ytname.mp4  -vf subtitles=$ytnamezm -y file:/home/$time.mp4 && sc_send && rm $ytnamezm && rm $ytname.mp4 &
     #green "后台运行中,输入tail -f nohup.out查看后台"
     exit
     tail -f nohup.out 
     else
     green "ytnamezm"
     ffmpeg  -i  $ytname.mp4  -vf subtitles=$ytnamezm -y file:/home/$time.mp4
     #这里将未合二为一的原文件删除（若不需要请在下面两行前加上"#"）
     rm $ytnamezm
     rm $ytname.mp4
     green "合并字幕完成！"
     read -p "是否需要上传至百度云?请输入 [Y/n] 默认n:" yn
	[ -z "${yn}" ] && yn="n"
	if [[ $yn == [Yy] ]]; then
     bypy_ydy
     green "已上传至百度云！"
     fi
     qg_ydy
     fi
}

#切割视频脚本
function qg_ydy(){
#判断是否需要切割，不大于5：59分钟自动不切割视频
t1=`date -d "$yttime" +%s`
t2=`date -d "5:59" +%s`
if [ $t1 -gt $t2 ]; then
read -p "确认是否需要切割视频?请输入 [Y/n] 默认y:" yn
	[ -z "${yn}" ] && yn="y"
	if [[ $yn == [Yy] ]]; then
	  read -p "请输入切割文件名序号?请输入 [1/2/3]默认1 :" qgnum
	#文件名默认值id.a.c1.mp4
	if [ -z "${qgnum}" ]
	    then
		qgnum='1'
	fi
		#输入1则代表前6分钟，2为6----12分钟以此类推，0代表自己选择
	#如果为1
if (( ${qgnum} == 1 )); then
      stime='00:00:00'
	 otime='00:05:59'
elif (( ${qgnum} == 2 )); then
      stime='00:06:00'
	 otime='00:05:59'
elif (( ${qgnum} == 3 )); then
      stime='00:12:00'
	 otime='00:05:59'
elif (( ${qgnum} == 4 )); then
      stime='00:18:00'
	 otime='00:05:59'
else
	  read -p "请输入切割视频起点时间?请输入 [00:00:00] :" stime
	  read -p "请输入切割视频持续时间?请输入 [00:05:59] :" otime
	  	#如果结束时间为空，设置默认为0:00-5：59
	  if [ -z "${otime}" ]
	    then
		otime='00:05:59'
	  fi
	  if [ -z "${stime}" ]
	    then
		stime='00:00:00'
	  fi
fi
  ffmpeg -ss $stime -t $otime -accurate_seek -i file:/home/$time.mp4 -codec copy file:/home/$time.c$qgnum.mp4
  green "切割完毕，视频起始时间：${stime}-视频持续时间：${otime}"
  exit
  fi
green "视频大于6分钟，您选择不切割，执行完毕！"
exit
else
green "该视频小于6分钟，执行完毕！"
green "$yttitle"
exit
fi
}

#2.切割视频
function qg2_ydy(){
read -p "请输入油管网址:" ylink
ytname_ydy
qg_ydy
}

#完整视频上传到百度云
function bypy_ydy(){
bypy upload /home/$time.mp4
}
#4.上传至百度云
function bypy2_ydy(){
read -p "请输入油管网址:" ylink
youtube-dl --list-subs $ylink
ytname_ydy
bypy upload /root/$time.mp4
}

start_menu(){
    clear
    echo "------------------------------------------------"
    green " 1. 下载视频"
    green " 2. 切割视频"
    green " 3. 合并字幕"
    green " 4. 上传至百度云"
    green " 5. 查看后台执行情况"
    red " 0. 退出脚本"
    echo
    read -p "请输入数字:" num
    case "$num" in
    1)
    link_ydy
    ;;
    2)
    qg2_ydy
    ;;
    3)
    hb1_ydy
    ;;
    4)
    bypy2_ydy
    ;;
    5)
    tail -f nohup.out
    ;;
    0)
    exit 1
    #sc_send
    ;;
    *)
    clear
    red "请输入正确数字"
    sleep 1s
    start_menu
    ;;
    esac
}

start_menu
