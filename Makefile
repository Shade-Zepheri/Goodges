export TARGET = iphone:latest:12.0
export ARCHS = arm64e

INSTALL_TARGET_PROCESSES = Preferences

ifneq ($(RESPRING),0)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

export ADDITIONAL_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Goodges
Goodges_FILES = include/GGPrefsManager.m include/UIColor+Goodges.m
Goodges_FILES += Goodges.x
Goodges_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore
Goodges_CFLAGS = -Iinclude/ -IHeaders/
Goodges_LIBRARIES = colorpicker applist

SUBPROJECTS = Settings

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
