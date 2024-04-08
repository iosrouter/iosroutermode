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

- (void)_handleDidPlayLightsAndSirens:(BOOL)didPlayLightsAndSirens forBulletin:(id)bulletin inPhoneSection:(id)phoneSecton transmissionDate:(id)transmissionDate receptionDate:(id)receptionDate fromGizmo:(BOOL)fromGizmo finalReply:(BOOL)finalReply replyToken:(id)replyToken {
	if (enabled) {
		didPlayLightsAndSirens = NO;
	}
	%orig;
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