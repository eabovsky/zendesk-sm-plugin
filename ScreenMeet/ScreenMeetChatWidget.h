//
//  ScreenMeetChatWidget.h
//  Remember The Date
//
//  Created by Adrian Cayaco on 14/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenMeetChatWidget : UIView

@property (strong, nonatomic) NSMutableArray *messageQueue;

@property (assign, nonatomic) BOOL isLive;

// to refresh UI
- (void)updateUI;

// set different UI
- (void)showDefaultUI;
- (void)showLiveUI;
- (void)showStreamingUI;


- (void)showWidget;
- (void)hideWidget;

- (void)activateChat;
- (void)endChat;

// add a message to be shown as a toast
- (void)addStackableToastMessage:(NSString *)message;

@end
