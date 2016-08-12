//
//  ZDCChatOverlay+Swizzle.m
//  Remember The Date
//
//  Created by Adrian Cayaco on 12/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import "ZDCChatOverlay+Swizzle.h"
#import "NSObject+Swizzle.h"
#import <objc/runtime.h>

#import "ScreenMeetManager.h"
#import <ZDCChat/ZDCChat.h>

@implementation ZDCChatOverlay (Swizzle)

+ (void)load
{
    [self swizzleMethods:@selector(activate) withMethod:@selector(xxx_activate)];
}

- (void)xxx_activate
{
    NSLog(@"Overlay activate...");
    
    [ScreenMeetManager presentViewController:[[UINavigationController alloc] initWithRootViewController:(UIViewController *)[[ScreenMeetManager sharedManager] mVC]] animated:YES completion:^{
        [[ZDCChat instance].overlay hide];
    }];
    
    // Uncomment to go on with normal flow
//    [self xxx_activate];
}

@end
