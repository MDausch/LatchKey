ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk
export GO_EASY_ON_ME := 1


BUNDLE_NAME = LatchKey
LatchKey_FILES = mdlkRootListController.m mdFeedbackController.m
LatchKey_INSTALL_PATH = /Library/PreferenceBundles
LatchKey_FRAMEWORKS = UIKit
LatchKey_PRIVATE_FRAMEWORKS = Preferences
LatchKey_LIBRARIES = colorpicker

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/LatchKey.plist$(ECHO_END)
