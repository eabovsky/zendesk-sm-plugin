//
//  ScreenMeetChatContainer.m
//  Remember The Date
//
//  Created by Adrian Cayaco on 16/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ScreenMeetChatContainer.h"
#import "ScreenMeetToast.h"

@interface ScreenMeetChatContainer () <ScreenMeetToastDelegate>

@property (assign, nonatomic) CGFloat calculatedHeight;

@end

@implementation ScreenMeetChatContainer

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

- (void)commonInit
{
    self.messageQueue                   = [[NSMutableArray alloc] init];

    self.clipsToBounds                  = YES;
    self.layer.cornerRadius             = 10.0f;
    self.backgroundColor                = [UIColor clearColor];
}

#pragma mark - Private Methods

- (void)processMessageQueue:(ScreenMeetToast *)message
{
    [self.messageQueue addObject:message];
    
    [self updateMessageQueueUI];
}

- (void)updateMessageQueueUI
{
    if (self.messageQueue.count == 0) {
        self.hidden = YES;
    } else {
        
        self.hidden            = NO;
        __block CGFloat offset = 0.0f;
        [self.messageQueue enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                // get the current object from the queue
                ScreenMeetToast *aToast = obj;
                
                CGRect frame   = aToast.frame;
                
                frame.origin.y = offset; // calculation of the position
                
                offset         += frame.size.height;
                
                // perform the animation back in the main queue
                // this will cause a crash if not performed this way since we are using enumaration blocks
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.25f animations:^{
                        aToast.frame = frame;
                    }];
                    
                    [self updateHeight];
                });
            }
        }];
    }
}

- (void)updateHeight
{
    CGRect frame           = self.frame;
    frame.size.height      = self.calculatedHeight;
    
    [UIView animateWithDuration:0.25f animations:^{
        self.frame = frame;
    }];
}

#pragma mark - Public Methods

- (void)addStackableToastMessage:(NSString *)message
{
    ScreenMeetToast *aToast               = [[ScreenMeetToast alloc] initWithMessage:message];
    aToast.delegate                       = self;
    
    // show to a view with a reference
    // the reference will be used for the custom UI
    [aToast showToastToView:self from:self];
    
    self.calculatedHeight += aToast.frame.size.height;
    
    // process the message queue
    [self processMessageQueue:aToast];
}

#pragma mark - ScreenMeetToast Delegate

- (void)SMToastWillBeRemovedFromView:(ScreenMeetToast *)screenMeetToast
{
    self.calculatedHeight -= screenMeetToast.frame.size.height;
    
    // remove the object from the queue
    [self.messageQueue removeObject:screenMeetToast];
    
    [self updateMessageQueueUI];
}

- (void)SMToastWasRemovedFromView:(ScreenMeetToast *)screenMeetToast
{
}

@end
