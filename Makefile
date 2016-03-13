export ARCHS = armv7 armv7s arm64

include theos/makefiles/common.mk

TWEAK_NAME = Passregex
Passregex_FILES = Tweak.xm
Passregex_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += passregex
include $(THEOS_MAKE_PATH)/aggregate.mk
