#import <OneSignal/OneSignal.h>
#import "OneSignal.h"
#import "OneSignalCoronaDelegate.h"
#import "OneSignalHelper.h"
#import "OneSignalLocation.h"
#import "OneSignalTracker.h"

@implementation OneSignalCoronaDelegate : NSObject 

- (void)applicationWillResignActive:(UIApplication*)application {
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"applicationWillResignActive:application"];
    
    if ([OneSignal app_id])
        [OneSignalTracker onFocus:YES];
}

- (void)applicationDidBecomeActive:(UIApplication*)application {
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"applicationDidBecomeActive:application"];
    
    if ([OneSignal app_id]) {
        [OneSignalTracker onFocus:NO];
        [OneSignalLocation onfocus:YES];
    }
}

- (void)application:(UIApplication*)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)inDeviceToken {
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"application:app didRegisterForRemoteNotificationsWithDeviceToken:inDeviceToken"];
    
    if ([OneSignal app_id])
        [OneSignal didRegisterForRemoteNotifications:app deviceToken:inDeviceToken];
}

- (void)application:(UIApplication*)app didFailToRegisterForRemoteNotificationsWithError:(NSError*)err {
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"application:app didFailToRegisterForRemoteNotificationsWithError:err"];
    
    if ([OneSignal app_id])
        [OneSignal handleDidFailRegisterForRemoteNotification:err];
}

- (void)application:(UIApplication*)app didRegisterUserNotificationSettings:(UIUserNotificationSettings*)notificationSettings {
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"application:app didRegisterUserNotificationSettings:notificationSettings"];
    
    if ([OneSignal app_id])
        [OneSignal updateNotificationTypes:[notificationSettings types]];
}

// Notification opened! iOS 6 ONLY!
//     gameThriveRemoteSilentNotification gets called on iOS 7 & 8
- (void)application:(UIApplication*)app didReceiveRemoteNotification:(NSDictionary*)userInfo {
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"application:app didReceiveRemoteNotification:userInfo"];
    
    BOOL* isActive = [app applicationState] == UIApplicationStateActive;
    
    if ([OneSignal app_id])
        [OneSignal handleNotificationOpened:userInfo
                                   isActive:isActive
                                 actionType:OSNotificationActionTypeOpened
                                displayType:OSNotificationDisplayTypeNotification];
}


// Notification opened or silent one received on iOS 7 & 8
- (void)application:(UIApplication*)app didReceiveRemoteNotification:(NSDictionary*)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult)) completionHandler {
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"application:app didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler"];
    
    if ([OneSignal app_id])
        [OneSignal remoteSilentNotification:app UserInfo:userInfo completionHandler:completionHandler];
}

- (void)application:(UIApplication*)app handleActionWithIdentifier:(NSString*)identifier forLocalNotification:(UILocalNotification*)notification completionHandler:(void(^)()) completionHandler {
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"application:app handleActionWithIdentifier:identifier forLocalNotification:notification completionHandler:completionHandler"];
    
    [OneSignal processLocalActionBasedNotification:notification identifier:identifier];
}

- (void)application:(UIApplication*)app didReceiveLocalNotification:(UILocalNotification*)notification {
    [OneSignal onesignal_Log:ONE_S_LL_VERBOSE message:@"application:app didReceiveLocalNotification:notification"];
    
    [OneSignal processLocalActionBasedNotification:notification identifier:@"__DEFAULT__"];
}

- (void)willLoadMain:(id<CoronaRuntime>)runtime {}
- (void)didLoadMain:(id<CoronaRuntime>)runtime {}

@end
