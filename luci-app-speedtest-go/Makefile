#
# Copyright (C) 2021 zhangsean <https://github.com/zhangsean/>
#
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for speedtest-go
LUCI_DESCRIPTION:=LuCI support for speedtest-go.
LUCI_DEPENDS:=+speedtest-go
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-speedtest-go
PKG_VERSION:=0.0.3
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=zhangsean <https://github.com/zhangsean/>

include $(TOPDIR)/feeds/luci/luci.mk
# call BuildPackage - OpenWrt buildroot signature
