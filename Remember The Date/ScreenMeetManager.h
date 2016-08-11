//
//  ScreenMeetManager.h
//  GServices
//
//  Created by Adrian Cayaco on 13/07/2016.
//  Copyright © 2016 Stratpoint. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenMeetManager : NSObject

+ (ScreenMeetManager *)sharedManager;

- (void)showDefaultError;
- (void)loginWithToken:(NSString *)token;
- (void)logout;
- (void)startStream:(void (^)(NSInteger status))callback;
- (void)stopStream;

@end
