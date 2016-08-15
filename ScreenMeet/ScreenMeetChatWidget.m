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

@interface ScreenMeetChatWidget () <ScreenMeetToastDelegate>

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
    // widget properties
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
    
    // listener events for the drag
    [self.actionButton addTarget:self action:@selector(dragMoving:withEvent:) forControlEvents:UIControlEventTouchDragInside];
    [self.actionButton addTarget:self action:@selector(actionButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.actionButton];
    
    // initialize the message queue
    self.messageQueue = [[NSMutableArray alloc] init];
}

- (void)dragMoving:(UIControl *)control withEvent:(UIEvent *)event
{
    // set flag to eliminate false positives
    self.wasDragged = YES;
    
    // calculate the position for the touch event and adjust the current center
    self.center = [[[event allTouches] anyObject] locationInView:self.superview];
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

- (void)processMessageQueue:(ScreenMeetToast *)message
{
    [self.messageQueue addObject:message];
    
    
    [self.messageQueue enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            ScreenMeetToast *aToast = obj;
            
            CGRect frame = aToast.frame;
            
            frame.origin.y = 44.0f // reference, can be changed depending on the queue position
                                + (self.messageQueue.count - idx) * 30.0f; // calculation of the position
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.25f animations:^{
                    aToast.frame = frame;
                }];
            });
        }
    }];
}

#pragma mark - Public Methods

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
    }
}

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
    [self showWidget];
}

- (void)addStackableToastMessage:(NSString *)message
{
    ScreenMeetToast *aToast = [[ScreenMeetToast alloc] initWithMessage:message];
    aToast.delegate         = self;
    aToast.index            = self.messageQueue.count - 1;
    
    // process the message queue
    [self processMessageQueue:aToast];
    
    // show to a view with a reference
    // the reference will be used for the custom UI
    [aToast showToastToView:self.superview from:self];
}

#pragma mark - ScreenMeetToast Delegate

- (void)SMToastWasRemovedFromView:(ScreenMeetToast *)screenMeetToast
{
    // remove the object from the queue
    [self.messageQueue removeObject:screenMeetToast];
}

@end
