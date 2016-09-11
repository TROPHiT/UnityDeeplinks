#ifndef __has_feature
#define __has_feature(x) 0 /* for non-clang compilers */
#endif

#if !__has_feature(objc_arc)
#error ARC must be enabled by adding -fobjc-arc under your target => Build Phases => Compile Sources => UnityDeeplinks.mm => Compiler Flags
#endif

#import <UIKit/UIKit.h>

// Include Unity types from the Unity app itself:
#import "AppDelegateListener.h"

//
#define UNITYDEEPLINKS_DEEPLINK_METHOD "onDeeplink"



extern "C" {
    // There is no public unity header, need to declare this manually:
    // http://answers.unity3d.com/questions/58322/calling-unitysendmessage-requires-which-library-on.html
    extern void UnitySendMessage(const char *, const char *, const char *);
    
    // Forward declarations needed for some ObjC internal code:
    void UnityDeeplinks_init(const char* gameObject, const char* deeplinkMethod);
    void UnityDeeplinks_dispatch(NSString* message);
    
}



@interface UnityDeeplinksNotificationObserver : NSObject <AppDelegateListener>
- (void)onNotification:(NSNotification*)notification;
- (void)onOpenURL:(NSNotification *)notification;
@end



@implementation UnityDeeplinksNotificationObserver

+ (UnityDeeplinksNotificationObserver*)instance {
    static UnityDeeplinksNotificationObserver* singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

- (void)onNotification:(NSNotification*)notification {
    if (![kUnityOnOpenURL isEqualToString:notification.name]) return;
    NSURL* url = [notification.userInfo objectForKey:@"url"];
    if (url == nil) {
        NSLog(@"UnityDeeplinks: unexpected missing url in kUnityOnOpenURL notification");
        return;
    }
    UnityDeeplinks_dispatch([url absoluteString]);
}

- (void)onOpenURL:(NSNotification *)notification {
    [self onNotification:notification];
}

@end




extern "C" {
    
    static NSString* gameObjectName = @"UnityDeeplinks";
    static NSString* deeplinkMethodName = @"onDeeplink";
    
    
    void UnityDeeplinks_init(const char* gameObject, const char* deeplinkMethod) {
        if (gameObject != nil) {
            NSString* gameObjectStr = [NSString stringWithCString:gameObject encoding:NSUTF8StringEncoding];
            if ([gameObjectStr length] > 0)
                gameObjectName = gameObjectStr;
        }
        if (deeplinkMethod != nil) {
            NSString* deeplinkMethodStr = [NSString stringWithCString:deeplinkMethod encoding:NSUTF8StringEncoding];
            if ([deeplinkMethodStr length] > 0)
                deeplinkMethodName = deeplinkMethodStr;
        }
        UnityRegisterAppDelegateListener([UnityDeeplinksNotificationObserver instance]);
    }
    
    
    
    void UnityDeeplinks_dispatch(NSString* message) {
        const char* name = (const char*) [gameObjectName UTF8String];
        const char* level = (const char*) [deeplinkMethodName UTF8String];
        const char* code = (const char*) [message UTF8String];
        NSLog(@"UnityDeeplinks: Dispatching %@ (%@)",
              [NSString stringWithCString:level encoding:NSUTF8StringEncoding],
              [NSString stringWithCString:code encoding:NSUTF8StringEncoding]
              );
        UnitySendMessage(name, level, code);
    }
    
    
}
