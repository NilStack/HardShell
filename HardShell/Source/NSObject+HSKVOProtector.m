//
//  NSObject+HSKVOProtector.m
//  HardShell
//
//  Created by 郭朋 on 02/03/2017.
//  Copyright © 2017 Peng. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+HSKVOProtector.h"

@implementation NSObject(HSKVOProtector)

- (HSKVOProtector *)kvoProtector {
    return objc_getAssociatedObject(self, @selector(kvoProtector));
}

- (void)setKVOProtector:(HSKVOProtector *)value {
    objc_setAssociatedObject(self, @selector(kvoProtector), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
