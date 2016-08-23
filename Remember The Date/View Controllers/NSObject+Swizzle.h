//
//  NSObject+Swizzle.h
//  Remember The Date
//
//  Created by Adrian Cayaco on 12/08/2016.
//  Copyright © 2016 RememberTheDate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Swizzle)

+ (BOOL)swizzleMethods:(SEL)originalSelector withMethod:(SEL)newSwizzleSelector;

@end
