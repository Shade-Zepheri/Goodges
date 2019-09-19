export TARGET = iphone:latest:12.0
export ARCHS = arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

export ADDITIONAL_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Goodges
Goodges_FILES = include/GGPrefsManager.m include/UIColor+Goodges.m
Goodges_FILES += Goodges.xm
Goodges_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore
Goodges_CFLAGS = -Iinclude/ -IHeaders/
Goodges_LIBRARIES = colorpicker applist

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
