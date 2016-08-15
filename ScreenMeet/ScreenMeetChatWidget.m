//
//  ScreenMeetChatWidget.m
//  Remember The Date
//
//  Created by Adrian Cayaco on 14/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ScreenMeetChatWidget.h"
#import "ScreenMeetToast.h"
#import "ScreenMeetManager.h"

#define kDefaultFrame CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)

@interface ScreenMeetChatWidget ()

@property (strong, nonatomic) UIButton *actionButton;

@property (assign, nonatomic) BOOL wasDragged;

@end

@implementation ScreenMeetChatWidget

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)dealloc
{
    [self.actionButton removeTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.actionButton removeTarget:self action:@selector(actionButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Private Methods

- (void)commonInit
{
    self.userInteractionEnabled = YES;
    self.backgroundColor        = [UIColor whiteColor];
    self.layer.borderColor      = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth      = 2.0f;
    
    CGRect frame = kDefaultFrame;
    
    if (self.frame.size.height != 0.0f || self.frame.size.width != 0.0f) {
        frame.size = self.frame.size;
    } else {
        self.frame = frame;
    }
    
    // add recognizers
    
    self.actionButton = [[UIButton alloc] initWithFrame:frame];
    
    [self.actionButton setTitle:@"•••" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.actionButton addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.actionButton addTarget:self action:@selector(actionButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.actionButton];
}

- (void)dragMoving:(UIControl *)control withEvent:(UIEvent *)event
{
    self.wasDragged = YES;
    self.center = [[[event allTouches] anyObject] locationInView:self.superview];
}

- (void)actionButtonWasPressed:(UIButton *)button
{
    if (!self.wasDragged) {
        [self activateChat];
    } else {
        self.wasDragged = NO;
    }
}

#pragma mark - Public Methods

- (void)showWidget
{
    if (self.hidden) {
        // just to make sure
        self.alpha = 0.0f;
        self.hidden = NO;
        
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [self addStackableToastMessage:@"A sample toast!"];
        }];
    }
}

- (void)hideWidget
{
    if (!self.hidden) {
        
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.hidden = YES;
        }];
    }
}

- (void)activateChat
{
    [ScreenMeetManager presentViewControllerFromWindowRootViewController:[[UINavigationController alloc] initWithRootViewController:(UIViewController *)[[ScreenMeetManager sharedManager] mVC]] animated:YES completion:^{
        [self hideWidget];
    }];
}

- (void)endChat
{
    [self showWidget];
}

- (void)addStackableToastMessage:(NSString *)message
{
    ScreenMeetToast *aToast = [[ScreenMeetToast alloc] initWithMessage:message];
    
    [aToast showToastToView:self.superview];
}

@end
