include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-zdm-dailybonus
PKG_VERSION:=0.2.1
PKG_RELEASE:=20210428

define Package/$(PKG_NAME)/conffiles
/etc/config/zdm-dailybonus
endef

LUCI_TITLE:=Luci for ZuiDaiMa dailybonus script
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+wget +lua +curl +libuci-lua

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature
