//
//  ViewController.m
//  HardShell
//
//  Created by 郭朋 on 28/02/2017.
//  Copyright © 2017 Peng. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+HardShell.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *label = [[UILabel alloc] init];
    label.center = self.view.center;
    label.text = @"HardShell";
    [label sizeToFit];
    [self.view addSubview:label];
    
    // unregonized selector crash
    UIButton *button = [[UIButton alloc] init];
    [button performSelector:@selector(noThisMethod:)];
    [button performSelector:@selector(description)];
    
    // KVO 
    [label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [label removeObserver:self forKeyPath:@"textColor"];
    
    //label.text = @"new text";
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
