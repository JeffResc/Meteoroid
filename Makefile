PACKAGE_VERSION = 1.0.4
DEBUG = 0
export SDKVERSION = 11.2
export ARCHS = arm64 arm64e
THEOS_DEVIVE_IP = 10.0.0.6
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Meteoroid
Meteoroid_FILES = Tweak.xm
Meteoroid_PRIVATE_FRAMEWORKS = PhotoLibrary PersistentConnection AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += meteoroidprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
