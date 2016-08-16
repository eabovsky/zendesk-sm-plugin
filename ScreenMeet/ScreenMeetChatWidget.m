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
#import "ScreenMeetChatContainer.h"
#import "ScreenMeetManager.h"

#define kDefaultFrame CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)

@interface ScreenMeetChatWidget ()

@property (strong, nonatomic) UIButton                *actionButton;
@property (strong, nonatomic) UIImageView             *widgetImageView;
@property (strong, nonatomic) ScreenMeetChatContainer *chatContainer;

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
    CGRect frame = kDefaultFrame;
    
    if (self.frame.size.height != 0.0f || self.frame.size.width != 0.0f) {
        frame.size = self.frame.size;
    } else {
        self.frame = frame;
    }
    
    self.widgetImageView             = [[UIImageView alloc] init];
    self.widgetImageView.frame       = self.bounds;
    self.widgetImageView.contentMode = UIViewContentModeCenter;

    [self addSubview:self.widgetImageView];
    
    self.actionButton = [[UIButton alloc] initWithFrame:frame];
    
    // listener events for the drag
    [self.actionButton addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.actionButton addTarget:self action:@selector(actionButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.actionButton];
    
    // set UI
    [self showDefaultUI];
}

- (void)dragMoving:(UIControl *)control withEvent:(UIEvent *)event
{
    // set flag to eliminate false positives
    self.wasDragged = YES;
    
    // calculate the position for the touch event and adjust the current center
    // only allow vertical movement
    CGPoint movement = [[[event allTouches] anyObject] locationInView:self.superview];
    self.center      = CGPointMake(self.center.x, movement.y);
    
    if (self.chatContainer) {
        CGRect frame             = self.chatContainer.frame;
        frame.origin.y           = self.frame.origin.y;
        self.chatContainer.frame = frame;
    }
}

- (void)actionButtonWasPressed:(UIButton *)button
{
    if (self.wasDragged) {
        // don't trigger since it was a false positive
        // the message came from an event from drag
        // reset flag
        self.wasDragged = NO;
    } else {
        [self activateChat];
    }
}

#pragma mark - Public Methods

- (void)updateUI
{
    if ([[ScreenMeetManager sharedManager] isStreaming]) {
        [self showStreamingUI];
    } else if (self.isLive) {
        [self showLiveUI];
    } else {
        [self showDefaultUI];
    }
}

- (void)showDefaultUI
{
    [self.actionButton setTitle:@"•••" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    self.widgetImageView.image  = nil;
    
    self.backgroundColor        = [UIColor whiteColor];
    self.layer.borderColor      = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth      = 2.0f;
}

- (void)showLiveUI
{
    // same as default UI.
    [self showDefaultUI];
}

- (void)showStreamingUI
{
    [self.actionButton setTitle:@"" forState:UIControlStateNormal];
    [self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.widgetImageView.image  = [UIImage imageNamed:@"icon_widget"];
    
    self.backgroundColor        = [UIColor redColor];
    self.layer.borderColor      = [UIColor whiteColor].CGColor;
    self.layer.borderWidth      = 2.0f;
}

- (void)showWidget
{
    if (self.hidden) {
        // just to make sure
        self.alpha  = 0.0f;
        self.hidden = NO;
        
        [UIView animateWithDuration:0.25f animations:^{
            self.alpha = 1.0f;
        } completion:^(BOOL finished) {
            [self delayLine:0 andMaxCount:10];
        }];

        if (self.chatContainer) {
            [self.superview bringSubviewToFront:self.chatContainer];
        } else {
            CGFloat originX           = self.frame.origin.x + self.frame.size.width + 10.0f;
            self.chatContainer        = [[ScreenMeetChatContainer alloc] initWithFrame:CGRectMake(originX, self.frame.origin.y, [UIScreen mainScreen].bounds.size.width - originX - 10.0f, 30.0f)];
            
            [self.superview addSubview:self.chatContainer];
        }
    }
    
    [self updateUI];
}

// for testing purposes
- (void)delayLine:(NSInteger)iteration andMaxCount:(NSInteger)maxCount
{
    if (iteration < maxCount) {
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self addStackableToastMessage:[NSString stringWithFormat:@"A sample toast:%ld", iteration+1]];
            [self delayLine:(iteration+1) andMaxCount:maxCount];
        });
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
    [self hideWidget];
}

- (void)addStackableToastMessage:(NSString *)message
{
    [self.chatContainer addStackableToastMessage:message];
}

@end
