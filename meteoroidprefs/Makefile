include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = meteoroidprefs
meteoroidprefs_FILES = MRootListController.m MButtonController.m
meteoroidprefs_INSTALL_PATH = /Library/PreferenceBundles
meteoroidprefs_FRAMEWORKS = UIKit
meteoroidprefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/meteoroidprefs.plist$(ECHO_END)
