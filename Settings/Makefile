include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = GoodgesPrefs
$(BUNDLE_NAME)_FILES = ../include/GGPrefsManager.m ../include/UIColor+Goodges.m
$(BUNDLE_NAME)_FILES += $(wildcard *.m)
$(BUNDLE_NAME)_FRAMEWORKS = MessageUI Social UIKit
$(BUNDLE_NAME)_LIBRARIES = colorpicker applist
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS += -I../include
$(BUNDLE_NAME)_LDFLAGS = Preferences.tbd

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/GoodgesPrefs.plist$(ECHO_END)
