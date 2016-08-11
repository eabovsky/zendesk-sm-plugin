//
//  ScreenMeetManager.h
//  GServices
//
//  Created by Adrian Cayaco on 13/07/2016.
//  Copyright © 2016 Stratpoint. All rights reserved.
//

@class UIBarButtonItem;

#import <Foundation/Foundation.h>
#import <ScreenMeetSDK/ScreenMeetSDK-Swift.h>

@interface ScreenMeetManager : NSObject

+ (ScreenMeetManager *)sharedManager;

+ (UIBarButtonItem *)createCloseButtonItemWithTarget:(id)target forSelector:(SEL)action;

- (void)showDefaultError;
- (void)loginWithToken:(NSString *)token;
- (void)loginWithToken:(NSString *)token callback:(void (^)(enum CallStatus status))callback;
- (void)logout;
- (void)startStream:(void (^)(NSInteger status))callback;
- (void)stopStream;

@end
