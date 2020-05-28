# Thank you to Dave van Wijk and QuitAll for providing a beautiful preferences bundle
# https://github.com/vanwijkdave/QuitAll

include $(THEOS)/makefiles/common.mk
ARCHS = arm64 arm64e

BUNDLE_NAME = meteoroidprefs
meteoroidprefs_FILES = MeteoroidRootListController.m zodiacs.m
meteoroidprefs_INSTALL_PATH = /Library/PreferenceBundles
meteoroidprefs_FRAMEWORKS = UIKit
meteoroidprefs_PRIVATE_FRAMEWORKS = Preferences
meteoroidprefs_CFLAGS = -fobjc-arc
meteoroidprefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MeteoroidPrefs.plist$(ECHO_END)
