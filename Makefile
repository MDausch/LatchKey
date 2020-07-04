ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk
export SDKVERSION = 11.2
export SDKROOT = $(THEOS)/sdks/iPhoneOS11.2.sdk

TWEAK_NAME = LatchKey
LatchKey_FILES = LatchKey.xm
LatchKey_LIBRARIES = colorpicker
LatchKey_FRAMEWORKS = UIKit CoreGraphics Foundation QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += latchkey
include $(THEOS_MAKE_PATH)/aggregate.mk
