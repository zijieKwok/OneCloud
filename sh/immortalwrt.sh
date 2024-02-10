#!/bin/bash

# 移除要替换的包
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/msd_lite
rm -rf feeds/packages/net/smartdns
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-netgear
rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/luci/applications/luci-app-netdata
rm -rf feeds/luci/applications/luci-app-serverchan
rm -rf feeds/luci/applications/luci-app-openclash
rm -rf feeds/luci/applications/luci-app-homeproxy
rm -rf feeds/package/luci-app-turboacc
rm -rf package/luci-app-turboacc
rm -rf feeds/luci/themes/luci-theme-bootstrap

#设置armv7 32位的openclash
mkdir -p files/etc/openclash/core
mkdir -p files/etc/profile.d
mkdir -p files/root

CLASH_DEV_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/dev/clash-linux-armv7.tar.gz"
CLASH_TUN_URL=$(curl -fsSL https://api.github.com/repos/vernesong/OpenClash/contents/dev/premium\?ref\=core | grep download_url | grep armv7 | awk -F '"' '{print $4}')
CLASH_META_URL="https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/meta/clash-linux-armv7.tar.gz"
GEOIP_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
GEOSITE_URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"
GEO_MMDB_URL="https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb"
#kr_URL="https://raw.githubusercontent.com/shiyu1314/openwrt-onecloud/main/sh/1.sh"
#xx_URL="https://raw.githubusercontent.com/shiyu1314/openwrt-onecloud/main/sh/30-sysinfo.sh"

wget -qO- $CLASH_DEV_URL | tar xOvz > files/etc/openclash/core/clash
wget -qO- $CLASH_TUN_URL | gunzip -c > files/etc/openclash/core/clash_tun
wget -qO- $CLASH_META_URL | tar xOvz > files/etc/openclash/core/clash_meta
wget -qO- $GEOIP_URL > files/etc/openclash/GeoIP.dat
wget -qO- $GEOSITE_URL > files/etc/openclash/GeoSite.dat
wget -qO- $GEO_MMDB_URL > files/etc/openclash/Country.mmdb

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
git clone --depth=1 https://github.com/sirpdboy/luci-app-ddns-go package/luci-app-ddns-go
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
git clone --depth=1 https://github.com/zijieKwok/istoreos-nas-packages package/luci-app-quickstart
git clone --depth=1 https://github.com/zijieKwok/istoreos-nas-packages package/luci-app-linkease
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-filebrowser
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-pushbot
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-qbittorrent
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-turboacc
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-usb-printer
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-easymesh

# 科学上网插件
git clone --depth=1 https://github.com/immortalwrt/homeproxy package/luci-app-homeproxy
git clone --depth=1 https://github.com/zijieKwok/passwall-packages package/passwall-packages
git clone --depth=1 https://github.com/zijieKwok/JacKwok-passwall package/luci-app-passwall
git clone --depth=1 https://github.com/xiaorouji/openwrt-passwall2 package/luci-app-passwall2
git_sparse_clone dev https://github.com/vernesong/OpenClash luci-app-openclash

# quickstart依赖 
git clone --depth=1 https://github.com/linkease/nas-packages package/quickstart
git clone --depth=1 https://github.com/linkease/nas-packages package/linkease
git clone --depth=1 https://github.com/linkease/nas-packages package/ffmpeg-remux

# DDNS-GO依赖
git_sparse_clone main https://github.com/sirpdboy/luci-app-ddns-go ddns-go

# 科学上网插件依赖
git_sparse_clone main https://github.com/kenzok8/small-package v2dat
git_sparse_clone main https://github.com/kenzok8/small-package lua-maxminddb
git_sparse_clone main https://github.com/kenzok8/small-package brook
git_sparse_clone main https://github.com/kenzok8/small-package trojan-go
git_sparse_clone main https://github.com/kenzok8/small-package trojan-plus
git_sparse_clone main https://github.com/kenzok8/small-package sagernet-core
git_sparse_clone main https://github.com/kenzok8/small-package lua-neturl
git_sparse_clone main https://github.com/kenzok8/small-package redsocks2
git_sparse_clone main https://github.com/kenzok8/small-package aria2
git_sparse_clone main https://github.com/kenzok8/small-package ariang
git_sparse_clone main https://github.com/kenzok8/small-package filebrowser
git_sparse_clone main https://github.com/kenzok8/small-package qBittorrent-Enhanced-Edition
git_sparse_clone main https://github.com/kenzok8/small-package qBittorrent-static
git_sparse_clone main https://github.com/kenzok8/small-package qBittorrent
git_sparse_clone main https://github.com/kenzok8/small-package qt6base
git_sparse_clone main https://github.com/kenzok8/small-package qtbase
git_sparse_clone main https://github.com/kenzok8/small-package qttools
git_sparse_clone main https://github.com/kenzok8/small-package rblibtorrent
git_sparse_clone master https://github.com/kiddin9/openwrt-packages vlmcsd
git_sparse_clone master https://github.com/kiddin9/openwrt-packages sing-box
git_sparse_clone master https://github.com/kiddin9/openwrt-packages UnblockNeteaseMusic-Go
git_sparse_clone master https://github.com/kiddin9/openwrt-packages UnblockNeteaseMusic
git_sparse_clone master https://github.com/kiddin9/openwrt-packages wrtbwmon
git_sparse_clone master https://github.com/kiddin9/openwrt-packages homebox
git_sparse_clone master https://github.com/kiddin9/openwrt-packages vsftpd-alt
git_sparse_clone master https://github.com/kiddin9/openwrt-packages ddns-scripts
git_sparse_clone master https://github.com/kiddin9/openwrt-packages n2n
git_sparse_clone master https://github.com/kiddin9/openwrt-packages adbyby
git_sparse_clone master https://github.com/kiddin9/openwrt-packages dns-forwarder
git_sparse_clone master https://github.com/kiddin9/openwrt-packages upx

# Themes
git clone --depth=1 https://github.com/zijieKwok/istoreos-nas-packages package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# 晶晨宝盒
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-amlogic
#sed -i "s|firmware_repo.*|firmware_repo 'https://github.com/ophub/luci-app-amlogic'|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|kernel_path.*|kernel_path 'https://github.com/ophub/kernel'|g" package/luci-app-amlogic/root/etc/config/amlogic
#sed -i "s|ARMv8|ARMv8_PLUS|g" package/luci-app-amlogic/root/etc/config/amlogic

# SmartDNS
git clone --depth=1 -b lede https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# msd_lite
git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

# MosDNS
#git_sparse_clone main https://github.com/kenzok8/small-package luci-app-mosdns
#git_sparse_clone main https://github.com/kenzok8/small-package mosdns
git clone --depth=1 https://github.com/sbwml/luci-app-mosdns package/luci-app-mosdns

# DDNS.to
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-ddnsto
git_sparse_clone main https://github.com/kenzok8/small-package ddnsto

# Alist
#git_sparse_clone main https://github.com/kenzok8/small-package luci-app-alist
#git_sparse_clone main https://github.com/kenzok8/small-package alist
git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# iStore
# git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
# git_sparse_clone main https://github.com/linkease/istore luci
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-store
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-lib-taskd
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-lib-xterm
git_sparse_clone master https://github.com/kiddin9/openwrt-packages taskd

# 在线用户
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-onliner
#sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
#sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
sudo chmod -Rf 755 package/luci-app-onliner

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

