#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import <rootless.h>

BOOL enabled;
#define kPrefsAppID CFSTR("dev.ayden.ios.tweak.wintermode")
#define prefsPath ROOT_PATH_NS(@"/var/mobile/Library/Preferences/dev.ayden.ios.tweak.wintermode.plist")

static void loadSettings() {
	if (![[NSFileManager defaultManager] fileExistsAtPath:prefsPath]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:@YES forKey:@"Enabled"];
		[dict writeToFile:prefsPath atomically:YES];
	}
	NSDictionary *settings = nil;
    CFPreferencesAppSynchronize(kPrefsAppID);
    CFArrayRef keyList = CFPreferencesCopyKeyList(kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (keyList) {
        settings = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, kPrefsAppID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
        CFRelease(keyList);
    }
    enabled = [settings[@"Enabled"] boolValue];
    NSString *bundle = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundle isEqual:@"com.apple.Bridge"]) {
        if (enabled) {
            NSLog(@"iosrouter: Enabling tweak");
            NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];
            [prefsDict setObject:@YES forKey:@"Enabled"];
            [prefsDict writeToFile:prefsPath atomically:YES];
        }
        else {
            NSLog(@"iosrouter: Disabling tweak");
            NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:prefsPath];
            [prefsDict setObject:@NO forKey:@"Enabled"];
            [prefsDict writeToFile:prefsPath atomically:YES];
        }
    }
    

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

  //  ------- Send Notifications to watch even when iPhone is unlocked & in use -------
  //Older versions
  - (void)_notifyGizmoOfBulletin:(id)arg1 forFeed:(NSUInteger)arg2 updateType:(NSUInteger)arg3 playLightsAndSirens:(BOOL)arg4 shouldSendReplyIfNeeded:(BOOL)arg5
  {
    if (enabled) { 
      NSLog(@"iosrouter: #1 %d", arg4);
      %orig(arg1, arg2, arg3, YES, arg5); 
    
    }
	  else { %orig; }
  }

  -(BOOL)_notifyGizmoOfBulletin:(id)arg1 forFeed:(unsigned long long)arg2 updateType:(unsigned long long)arg3 playLightsAndSirens:(BOOL)arg4 shouldSendReplyIfNeeded:(BOOL)arg5 attachment:(id)arg6 attachmentType:(long long)arg7 replyToken:(id)arg8
  { if (enabled) { 
    NSLog(@"iosrouter: #2 %d", arg4);
    arg4 = YES;
    }
    return %orig;
  }

  //  ------- Send Notifications to iPhone even when they have been delivered to watch & iPhone is Locked -------
  - (void)_handleDidPlayLightsAndSirens:(BOOL)didPlayLightsAndSirens forBulletin:(id)bulletin inPhoneSection:(id)phoneSecton transmissionDate:(id)transmissionDate receptionDate:(id)receptionDate fromGizmo:(BOOL)fromGizmo finalReply:(BOOL)finalReply replyToken:(id)replyToken
  { if (enabled) { 
    NSLog(@"iosrouter: #3 %d", didPlayLightsAndSirens);
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
   }
}
