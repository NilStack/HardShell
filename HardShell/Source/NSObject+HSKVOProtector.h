//
//  NSObject+HSKVOProtector.h
//  HardShell
//
//  Created by 郭朋 on 02/03/2017.
//  Copyright © 2017 Peng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSKVOProtector.h"

@interface NSObject(HSKVOProtector)

@property (nonatomic, strong, setter=setKVOProtector:, getter=kvoProtector)HSKVOProtector *kvoProtector;

@end
