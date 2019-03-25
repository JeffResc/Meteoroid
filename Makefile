PACKAGE_VERSION = 1.0.1
DEBUG = 0
ARCHS = armv7 arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Meteoroid
Meteoroid_FILES = Tweak.xm
Meteoroid_PRIVATE_FRAMEWORKS = PhotoLibrary PersistentConnection AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += meteoroidprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
