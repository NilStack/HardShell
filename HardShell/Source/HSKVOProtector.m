//
//  HSKVOProtector.m
//  HardShell
//
//  Created by 郭朋 on 02/03/2017.
//  Copyright © 2017 Peng. All rights reserved.
//

#import "HSKVOProtector.h"

@implementation HSKVOProtector

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.observerDict = [[NSDictionary alloc] init];
    }
    return self;
}

@end
