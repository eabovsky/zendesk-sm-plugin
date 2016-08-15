//
//  ScreenMeetToast.m
//  Remember The Date
//
//  Created by Adrian Cayaco on 15/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ScreenMeetToast.h"

#define kDefaultHeight      30.0f
#define kDefaultWidth       ([UIScreen mainScreen].bounds.size.width - 20.0f)
#define kDefaultFadeTime    1.0f
#define kDefaultDisplayTime 3.0f

@interface ScreenMeetToast ()

@property (strong, nonatomic) UIView  *backgroundView;
@property (strong, nonatomic) UILabel *toastLabel;

@end

@implementation ScreenMeetToast

@synthesize delegate = __delegate;

- (instancetype)initWithMessage:(NSString *)message andFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.message = message;
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithMessage:(NSString *)message
{
    self = [super init];
    if (self) {
        self.message = message;
        [self commonInit];
    }
    return self;
}

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

#pragma mark - Private Methods

- (void)commonInit
{
    if (self.frame.size.width == 0.0f) {
        self.frame = CGRectMake(10.0f, 44.0f, kDefaultWidth, kDefaultHeight);
    }

    self.fadeTime                       = kDefaultFadeTime;
    self.displayTime                    = kDefaultDisplayTime;
    self.alpha                          = 0.0f;

    self.backgroundColor                = [UIColor clearColor];
    self.layer.cornerRadius             = 10.0f;
    self.clipsToBounds                  = YES;

    self.backgroundView                 = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView.alpha           = 0.50f;

    [self addSubview:self.backgroundView];

    self.toastLabel                     = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, self.frame.size.width - 20.0f, self.frame.size.height - 10.0f)];
    self.toastLabel.backgroundColor     = [UIColor clearColor];
    self.toastLabel.numberOfLines       = 1;
    self.toastLabel.lineBreakMode       = NSLineBreakByTruncatingTail;
    self.toastLabel.textColor           = [UIColor whiteColor];
    self.toastLabel.font                = [UIFont systemFontOfSize:12.0f];
    self.toastLabel.text                = self.message;
    
    [self addSubview:self.toastLabel];
}

- (void)fadeOut
{
    [UIView animateWithDuration:self.fadeTime animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            // trigger delegate
            if ([self.delegate respondsToSelector:@selector(SMToastWasRemovedFromView:)]) {
                [self.delegate SMToastWasRemovedFromView:self];
            }
            
            // remove self
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Public Methods

- (void)showToastToView:(UIView *)view from:(UIView *)sourceView
{
    // acnhoring calculations
    // to do: automatically calculate anchoring from position
    
    // set container view frame
    CGRect frame          = self.frame;

    frame.origin.y        = sourceView.frame.origin.y;
    frame.origin.x        = sourceView.frame.origin.x + sourceView.frame.size.width + 10.0f;

    frame.size.width      = [UIScreen mainScreen].bounds.size.width - frame.origin.x - 10.0f;

    self.frame            = frame;

    // set label frame
    frame                 = self.toastLabel.frame;
    frame.size.width      = self.frame.size.width - 20.0f;

    self.toastLabel.frame = frame;
    
    [view addSubview:self];
    
    [UIView animateWithDuration:self.fadeTime/2 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [self performSelector:@selector(fadeOut) withObject:nil afterDelay:self.displayTime];
        }
    }];
}

@end
