//
//  NSObject+HardShell.m
//  HardShell
//
//  Created by 郭朋 on 28/02/2017.
//  Copyright © 2017 Peng. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+HardShell.h"

@implementation NSObject(HardShell)

- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    NSString *originClass = NSStringFromClass([self class]);
    
    NSLog(@"unregonized selector %@ sent to %@.", NSStringFromSelector(aSelector), originClass);
    
    NSString *stubClassName = @"HardShellStub";
    Class stubClass = NSClassFromString(stubClassName);
    if(stubClass == nil){
        stubClass = objc_allocateClassPair([NSObject class], [stubClassName UTF8String], 0);
    }
    Method forwardingTargetForSelector = class_getInstanceMethod([NSObject class],@selector(forwardingTargetForSelector:));
    const char *types = method_getTypeEncoding(forwardingTargetForSelector);
    IMP imp = imp_implementationWithBlock(^(__unsafe_unretained id self, va_list argp) {
        return 0;
        
    });
    class_addMethod(stubClass, aSelector, imp, types);
    
    id stub = [[stubClass alloc] init];
    
    return stub;
}

@end
