TARGET := iphone:clang:16.5:14.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = WModeBundle

WModeBundle_FILES = wmoRootListController.m
WModeBundle_FRAMEWORKS = UIKit
WModeBundle_PRIVATE_FRAMEWORKS = Preferences
WModeBundle_INSTALL_PATH = /Library/PreferenceBundles
WModeBundle_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
