#import "CoronaDelegate.h"

@interface OneSignalCoronaDelegate : NSObject<CoronaDelegate>

- (void)applicationWillResignActive:(UIApplication*)application;
- (void)applicationDidBecomeActive:(UIApplication*)application;
- (void)application:(UIApplication*)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)inDeviceToken;
- (void)application:(UIApplication*)app didFailToRegisterForRemoteNotificationsWithError:(NSError*)err;
- (void)application:(UIApplication*)application didRegisterUserNotificationSettings:(UIUserNotificationSettings*)notificationSettings;
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo;
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult)) completionHandler;
- (void)application:(UIApplication*)application handleActionWithIdentifier:(NSString*)identifier forLocalNotification:(UILocalNotification*)notification completionHandler:(void(^)()) completionHandler;
- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification;


- (void)willLoadMain:(id<CoronaRuntime>)runtime;
- (void)didLoadMain:(id<CoronaRuntime>)runtime;

@end
