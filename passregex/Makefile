export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

BUNDLE_NAME = Passregex
Passregex_FILES = Passregex.mm
Passregex_INSTALL_PATH = /Library/PreferenceBundles
Passregex_FRAMEWORKS = UIKit
Passregex_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Passregex.plist$(ECHO_END)
