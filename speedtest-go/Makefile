#
# Copyright (C) 2020-2021 zhangsean <https://github.com/zhangsean/>
# The LuCI Network diagnosis and speed test <https://github.com/sirpdboy/NetSpeedTest>
# Use the speed measurement program provided by ookla.
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_ARCH:=x86_64
PKG_NAME:=speedtest-go
PKG_VERSION:=1.1.3
PKG_RELEASE:=1

PKG_SOURCE:=speedtest-go_$(PKG_VERSION)_linux_amd64.tar.gz
PKG_SOURCE_URL:=https://github.com/librespeed/speedtest-go/releases/download/v$(PKG_VERSION)
PKG_HASH:=skip
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=zhangsean <https://github.com/zhangsean/>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Real-time local net speed test tool in web
  DEPENDS:=
  URL:=https://github.com/librespeed/speedtest-go
endef

define Package/$(PKG_NAME)/description
  No Flash, No Java, No WebSocket, No Bullshit.
  This is a very lightweight speed test implemented in JavaScript, using XMLHttpRequest and Web Workers.
  All modern browsers are supported: IE11, latest Edge, latest Chrome, latest Firefox, latest Safari.
  Works with mobile versions too.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)/$(PKG_NAME)
	$(CP) -a ./etc $(PKG_BUILD_DIR)/$(PKG_NAME)
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME)/etc/init.d/speedtest-go $(1)/etc/init.d
endef

define Package/$(PKG_NAME)/postinst
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
