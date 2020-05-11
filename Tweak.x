// #import <CoreDuet/_CDBatterySaver.h>
@interface _CDBatterySaver : NSObject
+ (id)batterySaver;
- (long long)getPowerMode;
- (long long)setMode:(long long)arg1;
@end

static _CDBatterySaver *batterySaver;
static long long last_lpm_state = 0;

static void sb_event_acstatuschanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSDictionary *batteryState = (__bridge NSDictionary *) userInfo;
	if([batteryState[@"ExternalChargeCapable"] isEqual:@1]) {
		// Enable LPM.
		last_lpm_state = [batterySaver getPowerMode];
		[batterySaver setMode:0];
	} else {
		if (([batteryState[@"CurrentCapacity"] floatValue] / [batteryState[@"MaxCapacity"] floatValue]) <= 1.0) {
			[batterySaver setMode:1];
		} else {
			// Disable LPM if it was disabled before.
			if(last_lpm_state == 0) {
				[batterySaver setMode:0];	
			}
		}
	}
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
	%orig;
	sb_event_acstatuschanged(NULL, NULL, NULL, NULL, NULL);
}
%end

%ctor {
	batterySaver = [_CDBatterySaver batterySaver];
	last_lpm_state = [batterySaver getPowerMode];
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, sb_event_acstatuschanged, CFSTR("SBUIACStatusChangedNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
