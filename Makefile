include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LatchKey
LatchKey_FILES = LatchKey.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += latchkey
include $(THEOS_MAKE_PATH)/aggregate.mk
