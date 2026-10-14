TARGET := iphone:clang:latest:12.0
ARCHS := arm64
INSTALL_TARGET_PROCESSES := SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME := KwarWelcome

KwarWelcome_FILES := Sources/Tweak.xm Sources/KWDialog.m
KwarWelcome_CFLAGS := -fobjc-arc -Wno-deprecated-declarations
KwarWelcome_FRAMEWORKS := UIKit Foundation QuartzCore CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard || true"
