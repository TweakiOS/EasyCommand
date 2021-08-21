TARGET := iphone:clang:13.0:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = EasyCommandPrefs

EasyCommandPrefs_FILES = SMPRootListController.m
EasyCommandPrefs_FRAMEWORKS = UIKit
EasyCommandPrefs_PRIVATE_FRAMEWORKS = Preferences
EasyCommandPrefs_INSTALL_PATH = /Library/PreferenceBundles
EasyCommandPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
