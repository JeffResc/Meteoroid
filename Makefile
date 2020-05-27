PACKAGE_VERSION = 1.0.5
DEBUG = 0
ARCHS = arm64 arm64e
include $(THEOS)/makefiles/common.mk
INSTALL_TARGET_PROCESSES = SpringBoard

TWEAK_NAME = Meteoroid
Meteoroid_FILES = Tweak.xm
Meteoroid_CFLAGS = -fobjc-arc
Meteoroid_PRIVATE_FRAMEWORKS = PersistentConnection AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += meteoroidprefs meteoroidcli
include $(THEOS_MAKE_PATH)/aggregate.mk
