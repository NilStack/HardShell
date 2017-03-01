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

/* TODO: 1. what if forwardInvocation: is rewritten by original class
 *       2. what if class_addMethod fails?
 *
 */
- (id)forwardingTargetForSelector:(SEL)aSelector {
    
    NSString *originClass = NSStringFromClass([self class]);
    
    NSLog(@"unregonized selector %@ sent to %@.", NSStringFromSelector(aSelector), originClass);
    
    NSString *stubClassName = @"HardShellStub";
    Class stubClass = NSClassFromString(stubClassName);
    if(stubClass == nil){
        stubClass = objc_allocateClassPair([NSObject class], [stubClassName UTF8String], 0);
    }
    IMP imp = imp_implementationWithBlock(^(__unsafe_unretained id self, va_list argp) {
        return 0;
        
    });
    // TODO: give default types "v@:", don't know if it's good choice
    class_addMethod(stubClass, aSelector, imp, "v@:");
    
    id stub = [[stubClass alloc] init];
    
    return stub;
}

@end
