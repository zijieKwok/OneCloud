#!/bin/bash
             
##生成版本号
echo $(TZ=UTC-8 date +"%Y%m%d%M") > version

##Socat更改为端口转发
sed -i 's/msgstr "Socat"/msgstr "端口转发"/g' feeds/luci/applications/luci-app-socat/po/zh_Hans/socat.po
##修改ImmortalWrt为OneCloud
sed -i 's/VERSION_DIST:=$(if $(VERSION_DIST),$(VERSION_DIST),ImmortalWrt)/VERSION_DIST:=$(if $(VERSION_DIST),$(VERSION_DIST),OneCloud)/g' include/version.mk
sed -i 's/VERSION_MANUFACTURER:=$(if $(VERSION_MANUFACTURER),$(VERSION_MANUFACTURER),ImmortalWrt)/VERSION_MANUFACTURER:=$(if $(VERSION_MANUFACTURER),$(VERSION_MANUFACTURER),OneCloud)/g' include/version.mk
##修改upnp到NAS菜单
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-upnp/root/usr/share/luci/menu.d/luci-app-upnp.json
##修改FileBrowser为文件浏览器改到NAS菜单
sed -i 's/msgstr "FileBrowser"/msgstr "文件浏览器"/g' feeds/luci/applications/luci-app-filebrowser/po/zh_Hans/filebrowser.po
sed -i 's/services/nas/g' feeds/luci/applications/luci-app-filebrowser/root/usr/share/luci/menu.d/luci-app-filebrowser.json
##配置ip等
#sed -i 's/192.168.1.1/192.168.2.110/g' package/base-files/files/bin/config_generate
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$OWRT_IP/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
sed -i "s/hostname='.*'/hostname='OneCloud'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate
##immortalwrt源码增加汉化
echo -e "\nmsgid \"Control\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"控制\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "\nmsgid \"NAS\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"网络存储\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "\nmsgid \"Login\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"登录\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "\nmsgid \"MAC-Address\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"MAC地址\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "\nmsgid \"IPv4-Address\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po
echo -e "msgstr \"IPv4地址\"" >> feeds/luci/modules/luci-base/po/zh_Hans/base.po

# Modify default NTP server
echo 'Modify default NTP server...'
sed -i 's/ntp.aliyun.com/ntp.ntsc.ac.cn/' package/base-files/files/bin/config_generate
sed -i 's/time1.cloud.tencent.com/ntp.aliyun.com/' package/base-files/files/bin/config_generate
sed -i 's/time.ustc.edu.cn/cn.ntp.org.cn/' package/base-files/files/bin/config_generate
sed -i 's/cn.pool.ntp.org/pool.ntp.org/' package/base-files/files/bin/config_generate

#固件版本号添加个人标识和日期
[ -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "s/DISTRIB_DESCRIPTION='.*OpenWrt '/DISTRIB_DESCRIPTION='JayKwok($(TZ=UTC-8 date +%Y.%m.%d))@OpenWrt '/g" package/lean/default-settings/files/zzz-default-settings
#[ ! -e package/lean/default-settings/files/zzz-default-settings ] && sed -i "/DISTRIB_DESCRIPTION='*'/d" package/base-files/files/etc/openwrt_release
[ ! -e package/lean/default-settings/files/zzz-default-settings ] && echo "DISTRIB_DESCRIPTION='OneCloud by JayKwok ($(TZ=UTC-8 date +%Y年%m月%d日))'" >> package/base-files/files/etc/openwrt_release

# 设置密码为password
sed -i 's/root:::0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/' package/base-files/files/etc/shadow

#连接数
sed -i '/customized in this file/a fs.file-max=102400\nnet.ipv4.neigh.default.gc_thresh1=512\nnet.ipv4.neigh.default.gc_thresh2=2048\nnet.ipv4.neigh.default.gc_thresh3=4096\nnet.netfilter.nf_conntrack_max=65535' package/base-files/files/etc/sysctl.conf

# 修改默认wifi名称ssid为JayKwok
sed -i 's/ssid=OpenWrt/ssid=JayKwok/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 修改默认wifi密码key为12345678
sed -i 's/encryption=none/encryption=psk2/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
sed -i '/set wireless.default_radio${devidx}.encryption=psk2/a\set wireless.default_radio${devidx}.key=12345678' package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 取消原主题luci-theme-bootstrap 为默认主题
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap

# 修改 argon 为默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci-nginx/Makefile
# hijack dns queries to router(firewall)
sed -i '/REDIRECT --to-ports 53/d' package/network/config/firewall/files/firewall.user
# 把局域网内所有客户端对外ipv4的53端口查询请求，都劫持指向路由器(iptables -n -t nat -L PREROUTING -v --line-number)(iptables -t nat -D PREROUTING 2)
echo 'iptables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53' >> package/network/config/firewall/files/firewall.user
echo 'iptables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53' >> package/network/config/firewall/files/firewall.user
# 把局域网内所有客户端对外ipv6的53端口查询请求，都劫持指向路由器(ip6tables -n -t nat -L PREROUTING -v --line-number)(ip6tables -t nat -D PREROUTING 1)
echo '[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 53' >> package/network/config/firewall/files/firewall.user
echo '[ -n "$(command -v ip6tables)" ] && ip6tables -t nat -A PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 53' >> package/network/config/firewall/files/firewall.user
