include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-zdm-dailybonus
PKG_VERSION:=0.0.1
PKG_RELEASE:=20210408

define Package/$(PKG_NAME)/conffiles
/etc/config/zdm-dailybonus
endef

LUCI_TITLE:=Luci for JD dailybonus Script
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+node +wget +lua +curl +libuci-lua

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
