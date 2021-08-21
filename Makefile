ARCHS = arm64 arm64e
TARGET := iphone:clang:13.0:11.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = EasyCommand
EasyCommand_BUNDLE_EXTENSION = bundle
EasyCommand_FILES = EasyCommand.m ProvidedCommandModule.m ProvidedCommandModuleRootListController.m
EasyCommand_PRIVATE_FRAMEWORKS = ControlCenterUIKit Preferences
EasyCommand_INSTALL_PATH = /Library/ControlCenter/CCSupport_Providers
EasyCommand_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
SUBPROJECTS += EasyCommandPrefs commandmoduled SB
include $(THEOS_MAKE_PATH)/aggregate.mk
