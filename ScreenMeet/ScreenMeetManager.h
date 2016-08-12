//
//  ScreenMeetManager.h
//  GServices
//
//  Created by Adrian Cayaco on 13/07/2016.
//  Copyright © 2016 Stratpoint. All rights reserved.
//

@class UIBarButtonItem;
@class MessageViewController;

#import <Foundation/Foundation.h>
#import <ScreenMeetSDK/ScreenMeetSDK-Swift.h>

@interface ScreenMeetManager : NSObject

@property (strong, nonatomic) MessageViewController *mVC;

+ (ScreenMeetManager *)sharedManager;

+ (UIBarButtonItem *)createCloseButtonItemWithTarget:(id)target forSelector:(SEL)action;

+ (void)presentViewController:(id)viewController animated:(BOOL)flag completion:(void (^)(void))completion;

- (void)showDefaultError;
- (void)loginWithToken:(NSString *)token;
- (void)loginWithToken:(NSString *)token callback:(void (^)(enum CallStatus status))callback;
- (void)logout;
- (void)startStream:(void (^)(NSInteger status))callback;
- (void)stopStream;

@end
