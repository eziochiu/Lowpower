export THEOS_DEVICE_IP = 192.168.1.4
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = lowpower

lowpower_FILES = Tweak.x
lowpower_CFLAGS = -fobjc-arc
lowpower_PRIVATE_FRAMEWORKS = CoreDuet

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
