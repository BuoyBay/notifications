#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>
#include <stdint.h>

typedef void (*BuoyNotificationCompletion)(void *, int32_t, int64_t, const char *);

// Copy the message before leaving Apple's completion queue. Buoy object
// mutation and retained-context release must run on the main queue.
static void complete(BuoyNotificationCompletion callback, void *context, int32_t outcome, int64_t code, NSString *message) {
    NSString *copy = [message copy] ?: @"";
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool { callback(context, outcome, code, copy.UTF8String); }
    });
}
static BOOL hasBundle(void) {
    NSBundle *bundle = NSBundle.mainBundle;
    return bundle.bundleIdentifier.length > 0 && [bundle.bundlePath.pathExtension.lowercaseString isEqualToString:@"app"];
}
static void fail(BuoyNotificationCompletion callback, void *context, NSInteger code, NSString *message) {
    complete(callback, context, 3, (int64_t)code, message ?: @"Notification operation failed");
}
int32_t buoy_notifications_supported(void) {
    @autoreleasepool {
        if (@available(macOS 10.14, *)) return hasBundle() ? 1 : 0;
        return 0;
    }
}
void buoy_notifications_authorize(int32_t alerts, int32_t sounds, int32_t badges, BuoyNotificationCompletion callback, void *context) {
    @autoreleasepool {
        if (!buoy_notifications_supported()) { fail(callback, context, -1, @"Notifications require an identified macOS app bundle"); return; }
        @try {
            UNAuthorizationOptions options = 0;
            if (alerts) options |= UNAuthorizationOptionAlert;
            if (sounds) options |= UNAuthorizationOptionSound;
            if (badges) options |= UNAuthorizationOptionBadge;
            [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError *error) {
                @autoreleasepool {
                    if (error) fail(callback, context, error.code, error.localizedDescription);
                    else complete(callback, context, granted ? 1 : 2, 0, @"");
                }
            }];
        } @catch (NSException *exception) { fail(callback, context, -2, exception.reason); }
    }
}
void buoy_notifications_status(BuoyNotificationCompletion callback, void *context) {
    @autoreleasepool {
        if (!buoy_notifications_supported()) { fail(callback, context, -1, @"Notifications require an identified macOS app bundle"); return; }
        @try {
            [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
                @autoreleasepool { complete(callback, context, 1, (int64_t)settings.authorizationStatus, @""); }
            }];
        } @catch (NSException *exception) { fail(callback, context, -2, exception.reason); }
    }
}
void buoy_notifications_schedule(const char *identifier, const char *title, const char *body, double delay, int32_t sound, BuoyNotificationCompletion callback, void *context) {
    @autoreleasepool {
        if (!buoy_notifications_supported()) { fail(callback, context, -1, @"Notifications require an identified macOS app bundle"); return; }
        @try {
            NSString *key = [NSString stringWithUTF8String:identifier];
            UNMutableNotificationContent *content = [UNMutableNotificationContent new];
            content.title = [NSString stringWithUTF8String:title];
            content.body = [NSString stringWithUTF8String:body];
            if (sound) content.sound = UNNotificationSound.defaultSound;
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:delay repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:key content:content trigger:trigger];
            [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError *error) {
                @autoreleasepool {
                    if (error) fail(callback, context, error.code, error.localizedDescription);
                    else complete(callback, context, 1, 0, @"");
                }
            }];
        } @catch (NSException *exception) { fail(callback, context, -2, exception.reason); }
    }
}
int32_t buoy_notifications_cancel(const char *identifier, int32_t delivered) {
    @autoreleasepool {
        if (!buoy_notifications_supported()) return -1;
        @try {
            NSArray *identifiers = @[[NSString stringWithUTF8String:identifier]];
            if (delivered) [UNUserNotificationCenter.currentNotificationCenter removeDeliveredNotificationsWithIdentifiers:identifiers];
            else [UNUserNotificationCenter.currentNotificationCenter removePendingNotificationRequestsWithIdentifiers:identifiers];
            return 0;
        } @catch (NSException *exception) { return -2; }
    }
}

@interface BuoyForegroundNotifications : NSObject <UNUserNotificationCenterDelegate>
@property(atomic) UNNotificationPresentationOptions options;
@end
@implementation BuoyForegroundNotifications
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completion {
    completion(self.options);
}
@end
static BuoyForegroundNotifications *foregroundDelegate;
int32_t buoy_notifications_foreground(int32_t alerts, int32_t sounds, int32_t badges) {
    @autoreleasepool {
        if (!NSThread.isMainThread) return -4;
        if (!buoy_notifications_supported()) return -1;
        @try {
            UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
            if (!alerts && !sounds && !badges) {
                if (center.delegate == foregroundDelegate) center.delegate = nil;
                foregroundDelegate = nil;
                return 0;
            }
            if (center.delegate && center.delegate != foregroundDelegate) return -3;
            if (!foregroundDelegate) foregroundDelegate = [BuoyForegroundNotifications new];
            UNNotificationPresentationOptions options = 0;
            if (alerts) options |= UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionList;
            if (sounds) options |= UNNotificationPresentationOptionSound;
            if (badges) options |= UNNotificationPresentationOptionBadge;
            foregroundDelegate.options = options;
            center.delegate = foregroundDelegate;
            return 0;
        } @catch (NSException *exception) { return -2; }
    }
}
