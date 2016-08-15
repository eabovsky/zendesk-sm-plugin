//
//  ScreenMeetToast.h
//  Remember The Date
//
//  Created by Adrian Cayaco on 15/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScreenMeetToast : UIView

@property (strong, nonatomic) NSString *message;
@property (assign, nonatomic) CGFloat  fadeTime;
@property (assign, nonatomic) CGFloat  displayTime;

- (instancetype)initWithMessage:(NSString *)message andFrame:(CGRect)frame;
- (instancetype)initWithMessage:(NSString *)message;
- (void)showToastToView:(UIView *)view;

@end
