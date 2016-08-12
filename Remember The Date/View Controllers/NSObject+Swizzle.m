//
//  NSObject+Swizzle.m
//  Remember The Date
//
//  Created by Adrian Cayaco on 12/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import "NSObject+Swizzle.h"
#import <objc/runtime.h>

@implementation NSObject (Swizzle)

+ (BOOL)swizzleMethods:(SEL)originalSelector withMethod:(SEL)newSwizzleSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newSwizzleMethod = class_getInstanceMethod(self, newSwizzleSelector);
    
    if (originalMethod && newSwizzleMethod) {
        if (class_addMethod(self, originalSelector, method_getImplementation(newSwizzleMethod), method_getTypeEncoding(newSwizzleMethod))) {
            
            class_replaceMethod(self, newSwizzleSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, newSwizzleMethod);
        }
        return YES;
    }
    return NO;
}

@end
