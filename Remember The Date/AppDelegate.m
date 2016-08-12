//
//  AppDelegate.m
//  Remember The Date
//
//  Created by Zendesk on 10/9/14.
//  Copyright (c) 2014 RememberTheDate. All rights reserved.
//

#import "AppDelegate.h"
#import "NSData+RememberTheDate.h"
#import <ZendeskSDK/ZendeskSDK.h>
#import <ZendeskSDK/ZDKSupportView.h>
#import <ZDCChat/ZDCChat.h>

#define RED_COLOR [UIColor colorWithRed:232.0f/255.f green:42.0f/255.0f blue:42.0f/255.0f alpha:1.0f]
#define ORANGE_COLOR [UIColor colorWithRed:253.0f/255.f green:144.0f/255.0f blue:38.0f/255.0f alpha:1.0f]
#define ORANGE_COLOR_40 [UIColor colorWithRed:253.0f/255.f green:144.0f/255.0f blue:38.0f/255.0f alpha:0.4f]

#define TEXT_COLOR [UIColor colorWithRed:150.0f/255.f green:110.0f/255.0f blue:90.0f/255.0f alpha:1.0f]
#define TEXT_COLOR_40 [UIColor colorWithRed:150.0f/255.f green:110.0f/255.0f blue:90.0f/255.0f alpha:.4f]

#define PLACEHOLDER_COLOR [UIColor colorWithRed:217.0f/255.f green:205.0f/255.0f blue:200.0f/255.0f alpha:1.0f]
#define NAVBAR_COLOR [UIColor colorWithRed:240.0f/255.f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f]
#define EMAIL_COLOR [UIColor colorWithRed:214.0f/255.f green:214.0f/255.0f blue:214.0f/255.0f alpha:1.0f]

static NSString * APP_ID      = @"8ecc5e5b0177e72437db6ee0c0889ea6b87023348faeb750";
static NSString * ZENDESK_URL = @"https://screenmeetdev.zendesk.com";
static NSString * CLIENT_ID   = @"mobile_sdk_client_a224f34d64dae33a666a";

NSString * const APNS_ID_KEY  = @"APNS_ID_KEY";

@interface AppDelegate ()

@end

@implementation AppDelegate


-(void) setupSDKStyle {

    // status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // nav bar
    NSDictionary *navbarAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [UIColor whiteColor] ,NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:navbarAttributes];
    
    if ([ZDKUIUtil isNewerVersion:@6]){
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setBarTintColor:RED_COLOR];
    } else {
        [[UINavigationBar appearance] setTintColor:RED_COLOR];
    }

    [[ZDKRequestListTableCell appearance] setUnreadColor:RED_COLOR];

    // chat SDK
    [[ZDCChatOverlay appearance] setInsets:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(75.0f, 15.0f, 70.0f, 15.0f)]];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // sync the default
    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];

    // Visual setup
    
    [[UITabBar appearance] setSelectedImageTintColor: [UIColor colorWithRed:0.38 green:0.85 blue:0.82 alpha:1.0]];
    [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Request Local Notifications
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }

    // Register for remote notfications    
    if ([UIApplication instancesRespondToSelector:@selector(registerForRemoteNotifications)]) {
        
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
        
    } else if ([UIApplication instancesRespondToSelector:@selector(registerForRemoteNotificationTypes:)]) {
        
        UIRemoteNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;
        
        [application registerForRemoteNotificationTypes:types];
    }
    
    //
    // Enable logging for debug builds
    //
    
#ifdef DEBUG
    [ZDKLogger enable:YES];
#else
    [ZDKLogger enable:NO];
#endif

    //
    // Initialize the Zendesk SDK
    //
    
    [[ZDKConfig instance] initializeWithAppId:APP_ID
                                   zendeskUrl:ZENDESK_URL
                                     clientId:CLIENT_ID];
    
    //
    // Style the SDK
    //
    
    [self setupSDKStyle];

    //
    // Initialise the chat SDK
    //
    [ZDCChat configure:^(ZDCConfig *defaults) {

        defaults.accountKey                         = @"476NiNORvNGOc4WSDE87u8zKNUvtYxBx";
        defaults.preChatDataRequirements.department = ZDCPreChatDataOptional;
        defaults.preChatDataRequirements.message    = ZDCPreChatDataOptional;
    }];
    
    //
    //  The rest of the Mobile SDK code can be found in ZenHelpViewController.m
    //
    
//    ZDCChatOverlay *overlay = [[ZDCChatOverlay alloc] initWithFrame:CGRectMake(0.0f, 30.0f, 50.0f, 50.0f)];
//    
//    [self.window addSubview:overlay];
//    [self.window bringSubviewToFront:overlay];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {

    //
    // Register SDK for push notifications
    //

    NSString *identifier = [deviceToken deviceIdentifier];
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:APNS_ID_KEY];
    
    if([[ZDKConfig instance] userIdentity] != nil) {
        
    [[ZDKConfig instance] enablePushWithDeviceID:identifier callback:^(ZDKPushRegistrationResponse *registrationResponse, NSError *error) {

        if (error) {

            NSLog(@"Couldn't register device: %@. Error: %@ in %@", identifier, error, self.class);

        } else if (registrationResponse) {

            NSLog(@"Successfully registered device: %@ in %@", identifier, self.class);
        }
    }];
        
    }

}

//iOS 7 and 8
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [ZDKPushUtil handlePush:userInfo
             forApplication:application
          presentationStyle:UIModalPresentationFormSheet
                layoutGuide:ZDKLayoutRespectTop
                  withAppId:APP_ID
                 zendeskUrl:ZENDESK_URL
                   clientId:CLIENT_ID
     fetchCompletionHandler:completionHandler];
    
}

//iOS 6
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [ZDKPushUtil handlePush:userInfo
             forApplication:application
          presentationStyle:UIModalPresentationFormSheet
                layoutGuide:ZDKLayoutRespectTop
                  withAppId:APP_ID
                 zendeskUrl:ZENDESK_URL
                   clientId:CLIENT_ID];
    
}
@end
