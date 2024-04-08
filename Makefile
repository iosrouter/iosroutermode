TARGET := iphone:clang:latest:7.0


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = IosrouterMode

IosrouterMode_FILES = Tweak.x
IosrouterMode_CFLAGS = -fobjc-arc


include $(THEOS_MAKE_PATH)/tweak.mk


SUBPROJECTS += wmodebundle
include $(THEOS_MAKE_PATH)/aggregate.mk
