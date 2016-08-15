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

- (void)showWidget;
- (void)hideWidget;

- (void)activateChat;
- (void)endChat;

@end
