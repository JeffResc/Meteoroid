export ARCHS = arm64
export SDKVERSION = 11.2
THEOS_DEVIVE_IP = 10.0.0.6
INSTALL_TARGET_PROCESSES = SpringBoard

# Simject
# export ARCHS = x86_64
# TARGET = simulator:clang::7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Meteoroid
Meteoroid_FILES = Tweak.xm
Meteoroid_PRIVATE_FRAMEWORKS = PhotoLibrary PersistentConnection AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += meteoroidprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
