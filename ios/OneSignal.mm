/**
* Modified MIT License
*
* Copyright 2019 OneSignal
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* 1. The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* 2. All copies of substantial portions of the Software may only be used in connection
* with services provided by OneSignal.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <OneSignal/OneSignal.h>
#import "OneSignal.h"
#include "CoronaRuntime.h"

static BOOL coronaInitDone = false;
static BOOL autoRegister = true;

NSString* CreateNSString(const char* string) {
    return [NSString stringWithUTF8String: string ? string : ""];
}

const char* dictionaryToJsonChar(NSDictionary* dictionaryToConvert) {
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionaryToConvert options:0 error:nil];
    NSString* jsonRequestData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return [jsonRequestData UTF8String];
}

void processNotificationOpened();

@interface UIApplication()
void initOneSignalObject(NSDictionary* launchOptions, const char* appId, BOOL autoRegister);

@end

// ----------------------------------------------------------------------------

class OneSignalLibrary {
public:
    typedef OneSignalLibrary Self;

    static const char kName[];
    
    static int getTagsCallbackIndex,
               idsAvailableCallbackIndex,
               getTriggerValueForKeyCallbackIndex;
    
    static int notificationOpenCallbackIndex;
    static int postNotificationOnSuccessIndex, postNotificationOnFailureIndex;
    static int inAppMessageClickCallbackIndex;
    
    static lua_State* lua_state;

protected:
    OneSignalLibrary();

public:
    bool Initialize(CoronaLuaRef listener );

    static int Open(lua_State* L);

protected:
    static int Finalizer(lua_State* L);

public:
    static Self* ToLibrary(lua_State* L);

    static int disableAutoRegister(lua_State* L);
    static int registerForNotifications(lua_State* L);
    static int init(lua_State* L);
    static int sendTags(lua_State* L);
    static int getTags(lua_State* L);
    static int idsAvailable(lua_State* L);
    static int setLogLevel(lua_State* L);
    static int enableInAppAlertNotification(lua_State* L);
    static int setSubscription(lua_State* L);
    static int postNotification(lua_State* L);
    static int setEmail(lua_State* L);
    static int promptLocation(lua_State* L);
    static int clearAllNotifications(lua_State* L);
    static int setInAppMessageClickHandler(lua_State* L);
    static int addTrigger(lua_State* L);
    static int addTriggers(lua_State* L);
    static int removeTriggerForKey(lua_State* L);
    static int removeTriggersForKeys(lua_State* L);
    static int getTriggerValueForKey(lua_State* L);
    static int pauseInAppMessages(lua_State* L);

private:
    CoronaLuaRef fListener; // TODO: Remove if not needed.
};

// ----------------------------------------------------------------------------

int OneSignalLibrary::getTagsCallbackIndex,
    OneSignalLibrary::idsAvailableCallbackIndex,
    OneSignalLibrary::getTriggerValueForKeyCallbackIndex;

int OneSignalLibrary::notificationOpenCallbackIndex = -1;
int OneSignalLibrary::postNotificationOnSuccessIndex = -1, OneSignalLibrary::postNotificationOnFailureIndex = -1;
int OneSignalLibrary::inAppMessageClickCallbackIndex;

lua_State* OneSignalLibrary::lua_state;

// This corresponds to the name of the library, e.g. [Lua] require "plugin.library"
const char OneSignalLibrary::kName[] = "OneSignal";

OneSignalLibrary::OneSignalLibrary() : fListener( NULL ) {
}

int OneSignalLibrary::Open(lua_State* L) {
    // Register __gc callback
    const char kMetatableName[] = __FILE__; // Globally unique string to prevent collision
    CoronaLuaInitializeGCMetatable(L, kMetatableName, Finalizer);

    // Functions in library
    const luaL_Reg kVTable[] = {
        { "disableAutoRegister", disableAutoRegister },
        { "registerForNotifications", registerForNotifications },
        { "init", init },
        { "sendTags", sendTags },
        { "getTags", getTags },
        { "idsAvailable", idsAvailable },
        { "setLogLevel", setLogLevel },
        { "enableInAppAlertNotification", enableInAppAlertNotification },
        { "setSubscription", setSubscription },
        { "postNotification", postNotification },
        { "setEmail", setEmail },
        { "promptLocation", promptLocation },
        { "clearAllNotifications", clearAllNotifications},
        { "setInAppMessageClickHandler", setInAppMessageClickHandler},
        { "addTrigger", addTrigger},
        { "addTriggers", addTriggers},
        { "removeTriggerForKey", removeTriggerForKey},
        { "removeTriggersForKeys", removeTriggersForKeys},
        { "getTriggerValueForKey", getTriggerValueForKey},
        { "pauseInAppMessages", pauseInAppMessages},
        { NULL, NULL }
    };

    // Set library as upvalue for each library function
    Self* library = new Self;
    CoronaLuaPushUserdata(L, library, kMetatableName);

    luaL_openlib(L, kName, kVTable, 1); // leave "library" on top of stack

    return 1;
}

int OneSignalLibrary::Finalizer(lua_State* L) {
    Self* library = (Self*)CoronaLuaToUserdata(L, 1 );
    // TODO: Do we need to clean up at all?

    return 0;
}

// TODO: Not sure when this is called from Corona or is not used at all.
OneSignalLibrary* OneSignalLibrary::ToLibrary(lua_State* L) {
    // library is pushed as part of the closure
    Self* library = (Self*)CoronaLuaToUserdata(L, lua_upvalueindex(1));

    return library;
}

int OneSignalLibrary::disableAutoRegister(lua_State* L) {
    autoRegister = false;
    return 0;
}

int OneSignalLibrary::registerForNotifications(lua_State* L) {
    [OneSignal registerForPushNotifications];
    return 0;
}

// [Lua] library.init( listener )
int OneSignalLibrary::init(lua_State* L) {
    lua_state = L;

    const char* appId = luaL_checkstring(L, 1);

    notificationOpenCallbackIndex = lua_ref(L, LUA_REGISTRYINDEX); // returns -1 if there isn't a lua callback
    initOneSignalObject(nil, appId, autoRegister);
    coronaInitDone = true;
    processNotificationOpened();

    return 0;
}

int OneSignalLibrary::sendTags(lua_State* L) {
    const char* jsonString = luaL_checkstring(L, 1);
    NSString* nsJsonString = CreateNSString(jsonString);
    NSData* jsonData = [nsJsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *e;
    NSDictionary* JSON = [NSJSONSerialization JSONObjectWithData: jsonData
                                                         options: NSJSONReadingMutableContainers
                                                           error: &e];
    
    [OneSignal sendTags:JSON];
    return 0;
}

int OneSignalLibrary::getTags(lua_State* L) {
    getTagsCallbackIndex = lua_ref(L, LUA_REGISTRYINDEX);

    [OneSignal getTags:^(NSDictionary* result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            lua_State* L = lua_state;
            lua_rawgeti(L, LUA_REGISTRYINDEX, getTagsCallbackIndex);
            luaL_unref(L, LUA_REGISTRYINDEX, getTagsCallbackIndex);

            // Deep clone of tag callback results before sending as encoded string
            if (result && result.count > 0) {
                NSDictionary* tags = [[NSDictionary alloc] initWithDictionary:result copyItems:YES];
                lua_pushstring(L, dictionaryToJsonChar(tags));
            }
            else
                lua_pushnil(L);

            lua_pcall(L, 1, 0, 0);
        });
    }];
    return 0;
}

int OneSignalLibrary::idsAvailable(lua_State* L) {
    idsAvailableCallbackIndex = lua_ref(L, LUA_REGISTRYINDEX);

    [OneSignal IdsAvailable:^(NSString* userId, NSString* pushToken) {
        dispatch_async(dispatch_get_main_queue(), ^{
            lua_State* L = lua_state;
            lua_rawgeti(L, LUA_REGISTRYINDEX, idsAvailableCallbackIndex);

            lua_pushstring(L, [userId UTF8String]);

            if (pushToken != nil)
                lua_pushstring(L, [pushToken UTF8String]);
            else
                lua_pushnil(L);

            lua_pcall(L, 2, 0, 0);
        });
    }];

    return 0;
}

int OneSignalLibrary::setLogLevel(lua_State* L) {
    NSLog(@"Corona setLogLevel");
    [OneSignal setLogLevel:luaL_checkinteger(L, 1) visualLevel:luaL_checkinteger(L, 2)];
    return 0;
}

int OneSignalLibrary::enableInAppAlertNotification(lua_State* L) {
    [OneSignal enableInAppAlertNotification:lua_toboolean(L, 1)];
    return 0;
}

int OneSignalLibrary::setSubscription(lua_State* L) {
    [OneSignal setSubscription:lua_toboolean(L, 1)];
    return 0;
}

int OneSignalLibrary::postNotification(lua_State* L) {
    postNotificationOnFailureIndex = lua_ref(L, LUA_REGISTRYINDEX);
    postNotificationOnSuccessIndex = lua_ref(L, LUA_REGISTRYINDEX);

    const char* jsonString = luaL_checkstring(L, 1);

    NSString* nsJsonString = CreateNSString(jsonString);
    NSData* jsonData = [nsJsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *e;
    NSDictionary* JSON = [NSJSONSerialization JSONObjectWithData: jsonData
                                                         options: NSJSONReadingMutableContainers
                                                           error: &e];
    
    [OneSignal postNotification:JSON
                    onSuccess:^(NSDictionary* results) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            lua_State* L = lua_state;
                            lua_rawgeti(L, LUA_REGISTRYINDEX, postNotificationOnSuccessIndex);
                            luaL_unref(L, LUA_REGISTRYINDEX, postNotificationOnSuccessIndex);

                            lua_pushstring(L, dictionaryToJsonChar(results));

                            lua_pcall(L, 1, 0, 0);
                            luaL_unref(L, LUA_REGISTRYINDEX, postNotificationOnFailureIndex);
                        });
                    }
                    onFailure:^(NSError* error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            lua_State* L = lua_state;
                            lua_rawgeti(L, LUA_REGISTRYINDEX, postNotificationOnFailureIndex);
                            luaL_unref(L, LUA_REGISTRYINDEX, postNotificationOnFailureIndex);

                            if (error.userInfo && error.userInfo[@"returned"])
                                lua_pushstring(L, dictionaryToJsonChar(error.userInfo[@"returned"]));
                            else
                                lua_pushstring(L, "{\"error\": \"HTTP no response error\"}");

                            lua_pcall(L, 1, 0, 0);
                            luaL_unref(L, LUA_REGISTRYINDEX, postNotificationOnSuccessIndex);
                        });
                    }];
    return 0;
}

int OneSignalLibrary::setEmail(lua_State* L) {
    const char* emailChar = luaL_checkstring(L, 1);
    NSString* emailStr = CreateNSString(emailChar);
    [OneSignal setEmail:emailStr];
    return 0;
}

int OneSignalLibrary::promptLocation(lua_State* L) {
    [OneSignal promptLocation];
    return 0;
}

int OneSignalLibrary::clearAllNotifications(lua_State* L) {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

    return 0;
}

int OneSignalLibrary::setInAppMessageClickHandler(lua_State* L) {
    inAppMessageClickCallbackIndex = lua_ref(L, LUA_REGISTRYINDEX);
    
    [OneSignal setInAppMessageClickHandler:^(OSInAppMessageAction *action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            lua_State* L = lua_state;
            lua_rawgeti(L, LUA_REGISTRYINDEX, inAppMessageClickCallbackIndex);
            
            NSDictionary* actionJson = @{
                @"click_name" : action.clickName ? action.clickName : @"",
                @"click_url" : action.clickUrl ? action.clickUrl.absoluteString : @"",
                @"first_click" : @(action.firstClick),
                @"closes_message" : @(action.closesMessage)
            };
            
            lua_pushstring(L, dictionaryToJsonChar(actionJson));

            lua_pcall(L, 1, 0, 0);
        });
    }];
    
    return 0;
}

int OneSignalLibrary::addTrigger(lua_State* L) {
    const char* jsonString = luaL_checkstring(L, 1);
    NSString* nsJsonString = CreateNSString(jsonString);
    
    NSData* jsonData = [nsJsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *e;
    NSDictionary* JSON = [NSJSONSerialization JSONObjectWithData: jsonData
                                                         options: NSJSONReadingMutableContainers
                                                           error: &e];

    [OneSignal addTriggers:JSON];
    return 0;
}

int OneSignalLibrary::addTriggers(lua_State* L) {
    const char* jsonString = luaL_checkstring(L, 1);
    NSString* nsJsonString = CreateNSString(jsonString);
    NSData* jsonData = [nsJsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *e;
    NSDictionary* JSON = [NSJSONSerialization JSONObjectWithData: jsonData
                                                         options: NSJSONReadingMutableContainers
                                                           error: &e];
    
    [OneSignal addTriggers:JSON];
    return 0;
}

int OneSignalLibrary::removeTriggerForKey(lua_State* L) {
    const char* jsonString = luaL_checkstring(L, 1);
    NSString* nsJsonString = CreateNSString(jsonString);

    [OneSignal removeTriggerForKey:nsJsonString];
    return 0;
}

int OneSignalLibrary::removeTriggersForKeys(lua_State* L) {
    const char* jsonString = luaL_checkstring(L, 1);
    NSString* nsJsonString = CreateNSString(jsonString);
    NSData* jsonData = [nsJsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *e;
    NSArray* JSON = [NSJSONSerialization JSONObjectWithData: jsonData
                                                    options: NSJSONReadingMutableContainers
                                                      error: &e];

    [OneSignal removeTriggersForKeys:JSON];
    return 0;
}

int OneSignalLibrary::getTriggerValueForKey(lua_State* L) {
    getTriggerValueForKeyCallbackIndex = lua_ref(L, LUA_REGISTRYINDEX);
    
    const char* key = luaL_checkstring(L, 1);
    NSString* triggerKey = CreateNSString(key);

    NSString* triggerValue = (NSString*) [OneSignal getTriggerValueForKey:triggerKey];
    const char* value = [triggerValue UTF8String];
    
    lua_rawgeti(L, LUA_REGISTRYINDEX, getTriggerValueForKeyCallbackIndex);
    luaL_unref(L, LUA_REGISTRYINDEX, getTriggerValueForKeyCallbackIndex);

    lua_pushstring(L, key);
    lua_pushstring(L, value);

    lua_pcall(L, 2, 0, 0);
    
    return 0;
}

int OneSignalLibrary::pauseInAppMessages(lua_State* L) {
    [OneSignal pauseInAppMessages:lua_toboolean(L, 1)];
    return 0;
}

// ----------------------------------------------------------------------------

CORONA_EXPORT int luaopen_OneSignal(lua_State* L) {
    return OneSignalLibrary::Open(L);
}

// ----------- Object-c below -------------

@implementation UIApplication(OneSignalCoronaPush)

static NSString* mAlertMessage;
static NSDictionary* mAdditionalData;
static BOOL mIsActive;

void initOneSignalObject(NSDictionary* launchOptions, const char* appId, BOOL autoRegister) {
    NSString* appIdStr = (appId ? [NSString stringWithUTF8String: appId] : nil);

    [OneSignal setValue:@"corona" forKey:@"mSDKType"];
    
    [OneSignal initWithLaunchOptions:launchOptions appId:appIdStr handleNotificationAction:^(OSNotificationOpenedResult *result) {
        // Need to deep copy as we will be going across threads.
        mAlertMessage = [result.notification.payload.body copy];
        mAdditionalData = [[NSDictionary alloc] initWithDictionary:result.notification.payload.additionalData copyItems:YES];
        mIsActive = result.notification.isAppInFocus;
        
        if (coronaInitDone)
            processNotificationOpened();
    } settings:@{
        @"kOSSettingsKeyAutoPrompt" : @(autoRegister)
    }];
}


static void switchMethods(Class inClass, SEL oldSel, SEL newSel, IMP impl, const char* sig)
{
    class_addMethod(inClass, newSel, impl, sig);
    method_exchangeImplementations(class_getInstanceMethod(inClass, oldSel), class_getInstanceMethod(inClass, newSel));
}

+ (void)load {
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(setDelegate:)), class_getInstanceMethod(self, @selector(setOneSignalCoronaDelegate:)));
}

- (void) setOneSignalCoronaDelegate:(id<UIApplicationDelegate>)delegate {
    static Class delegateClass = [delegate class];

    switchMethods(delegateClass, @selector(application:didFinishLaunchingWithOptions:),
                  @selector(application:selectorDidFinishLaunchingWithOptions:), (IMP)didFinishLaunchingWithOptions_GTLocal, "v@:::");

    [self setOneSignalCoronaDelegate:delegate];
}

BOOL didFinishLaunchingWithOptions_GTLocal(id self, SEL _cmd, id application, id launchOptions) {
    BOOL result = YES;

    if ([self respondsToSelector:@selector(application:selectorDidFinishLaunchingWithOptions:)]) {
        BOOL openedFromNotification = ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil);
        if (openedFromNotification)
            initOneSignalObject(launchOptions, nil, true);

        if (![self application:application selectorDidFinishLaunchingWithOptions:launchOptions])
            result = NO;
    }
    else {
        [self applicationDidFinishLaunching:application];
        result = YES;
    }

    return result;
}


void processNotificationOpened() {
    if (mAlertMessage && OneSignalLibrary::notificationOpenCallbackIndex != -1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            lua_State* L = OneSignalLibrary::lua_state;
            lua_rawgeti(L, LUA_REGISTRYINDEX, OneSignalLibrary::notificationOpenCallbackIndex);
            lua_pushstring(L, [mAlertMessage UTF8String]);

            if (mAdditionalData && mAdditionalData.count > 0)
                lua_pushstring(L, dictionaryToJsonChar(mAdditionalData));
            else
                lua_pushnil(L);

            lua_pushboolean(L, mIsActive);
            lua_pcall(L, 3, 0, 0);
            mAlertMessage = nil;
        });
    }
}

@end
