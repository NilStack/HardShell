//
//  NSObject+HardShell.m
//  HardShell
//
//  Created by 郭朋 on 28/02/2017.
//  Copyright © 2017 Peng. All rights reserved.
//

#import <objc/runtime.h>
#import "JRSwizzle.h"
#import "NSObject+HardShell.h"
#import "NSObject+HSKVOProtector.h"

static const void *keypathMapKey=&keypathMapKey;

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

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleAddObserver];
        [self swizzleRemoveObserver];
    });
}

- (void)hsAddObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context {
    
    if(!self.kvoProtector) {
        HSKVOProtector *kvoProtector = [[HSKVOProtector alloc] init];
        [self setKVOProtector:kvoProtector];
    }
        
    NSDictionary *kvoInfo;
    if(context) {
       kvoInfo = @{@"Observer": observer, @"KeyPath": keyPath, @"Options": [NSNumber numberWithInteger:options], @"Context": (__bridge NSObject *)(context)};
    } else {
       kvoInfo = @{@"Observer": observer, @"KeyPath": keyPath, @"Options": [NSNumber numberWithInteger:options]};
    }
    
    HSKVOProtector *kvoProtector = self.kvoProtector;
    NSDictionary *observerDict = kvoProtector.observerDict;
    NSArray *kvoInfoArray = [observerDict objectForKey:keyPath];
    
    if(!kvoInfoArray){
        kvoInfoArray = @[kvoInfo];
        
    } else {
        
        for (NSDictionary *info in kvoInfoArray) {
            if([info objectForKey:@"Observer"] == observer) {
                NSLog(@"Error: %@ has been observed by %@", keyPath, observer.description);
                return;
            }
        }
    }
    
    NSMutableArray *mutableKVOInfoArray = [kvoInfoArray mutableCopy];
    [mutableKVOInfoArray addObject:kvoInfo];

    NSMutableDictionary *mutableObserverDict = [observerDict mutableCopy];
    [mutableObserverDict setValue:[mutableKVOInfoArray copy] forKey:keyPath];
    kvoProtector.observerDict = [mutableObserverDict copy];
    [self hsAddObserver:kvoProtector forKeyPath:keyPath options:options context:context];
}

- (void)hsRemoveObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    
    if(!self.kvoProtector) {
        NSLog(@"Error: no observer obserse you.");
        return;
    } else {
        HSKVOProtector *kvoProtector = self.kvoProtector;
        NSDictionary *observerDict = kvoProtector.observerDict;
        NSArray *kvoInfoArray = [observerDict objectForKey:keyPath];
        if(!kvoInfoArray) {
            NSLog(@"Error: no observer obserse %@.", keyPath);
            return;
        } else {
            for (NSDictionary *info in kvoInfoArray) {
                if([info objectForKey:@"Observer"] == observer || [info objectForKey:@"Observer"] == nil) {
                    NSMutableArray *mutableKVOInfoArray = [kvoInfoArray mutableCopy];
                    [mutableKVOInfoArray removeObject:info];
                    kvoInfoArray = [mutableKVOInfoArray copy];
                }
            }
            
            if (kvoInfoArray.count == 0) {
                NSMutableDictionary *mutableObserverDict = [observerDict mutableCopy];
                [mutableObserverDict removeObjectForKey:keyPath];
                [self removeObserver:kvoProtector forKeyPath:keyPath];
            }
            
        }
    }
    
}

- (void)hsObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    NSLog(@"hsObserveValueForKeyPath");
    
}

+ (void)swizzleAddObserver {
    NSError *error;
    BOOL success = [[self class] jr_swizzleMethod:@selector(addObserver:forKeyPath:options:context:) withMethod:@selector(hsAddObserver:forKeyPath:options:context:) error:&error];
    if (!success || error) {
        NSLog(@"Can't swizzle methods - %@", [error description]);
    }
}

+ (void)swizzleRemoveObserver {
    NSError *error;
    BOOL success = [[self class] jr_swizzleMethod:@selector(removeObserver:forKeyPath:) withMethod:@selector(hsRemoveObserver:forKeyPath:) error:&error];
    if (!success || error) {
        NSLog(@"Can't swizzle methods - %@", [error description]);
    }
}

+ (void)swizzleObserveValueForKeyPath {
    NSError *error;
    BOOL success = [[self class] jr_swizzleMethod:@selector(removeObserver:forKeyPath:) withMethod:@selector(hsObserveValueForKeyPath:ofObject:change:context:) error:&error];
    if (!success || error) {
        NSLog(@"Can't swizzle methods - %@", [error description]);
    }
}

@end
