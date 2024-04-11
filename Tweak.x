#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

static BOOL enabled;

#define prefsPath ROOT_PATH_NS(@"/var/mobile/Library/Preferences/dev.ayden.ios.tweak.wintermode.plist")

static void loadSettings() {
	//check if file exists
	if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:@YES forKey:@"enabled"];
		[dict writeToFile:prefsPath atomically:YES];
	}
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:prefsPath];
	enabled = [[dict objectForKey:@"enabled"] boolValue];

}

static void settingsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    loadSettings();
}

@interface PSListController : UIViewController
- (NSArray *)loadSpecifiersFromPlistName:(NSString *)arg1 target:(id)arg2 bundle:(NSBundle *)arg3;
@end

@interface COSSettingsListController : PSListController
@end

%hook BLTBulletinDistributor

- (void)handleDidPlayLightsAndSirens:(bool)arg1 forBulletin:(id)arg2 inPhoneSection:(id)arg3 transmissionDate:(id)arg4 receptionDate:(id)arg5 replyToken:(id)arg6 {
	if (enabled) {
		arg1 = NO;
	}
	%orig;
}

- (void)_handleDidPlayLightsAndSirens:(bool)arg1 forBulletin:(id)arg2 inPhoneSection:(id)arg3 transmissionDate:(id)arg4 receptionDate:(id)arg5 fromGizmo:(bool)arg6 finalReply:(bool)arg7 replyToken:(id)arg8 {
	if (enabled) {
		arg1 = NO;
	}
	%orig;
}

- (bool)_notifyGizmoOfBulletin:(id)arg1 forFeed:(unsigned long long)arg2 updateType:(unsigned long long)arg3 playLightsAndSirens:(bool)arg4 shouldSendReplyIfNeeded:(bool)arg5 attachment:(id)arg6 attachmentType:(long long)arg7 replyToken:(id)arg8 {
	if (enabled) {
		arg4 = YES;
		arg5 = YES;
	}
	return %orig;
}

%end

%hook COSSettingsListController

-(NSArray *)additionalSpecifiers {
    NSMutableArray *specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self bundle:[NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/PreferenceBundles/WModeBundle.bundle")]] mutableCopy];
    [specifiers addObjectsFromArray:%orig];
    return specifiers;
}

%end


%ctor {
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        (CFNotificationCallback)settingsChanged,
                                        CFSTR("dev.ayden.ios.tweak.wintermode.changed"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);
		loadSettings();						
   }
}