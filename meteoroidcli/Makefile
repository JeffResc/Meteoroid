# The meteoroidcli subproject is a fork of WallpaperChanger by Capt Inc
# Thank you so much to them for their work, it helped so much
# Please checkout his project here if you are interested: https://github.com/captinc/WallpaperChanger

ARCHS = arm64 arm64e
TARGET = iphone:clang::11.0
include $(THEOS)/makefiles/common.mk

TOOL_NAME = meteoroidcli
meteoroidcli_FILES = main.m
meteoroidcli_CFLAGS = -fobjc-arc
meteoroidcli_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tool.mk
