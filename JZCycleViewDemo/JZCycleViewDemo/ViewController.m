//
//  ViewController.m
//  JZCycleViewDemo
//
//  Created by Jz on 16/4/25.
//  Copyright © 2016年 Jz. All rights reserved.
//

#import "ViewController.h"
#import "JZCycleView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JZCycleView *view = [[JZCycleView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
    [view setUpImagesArray:@[@"https://img1.doubanio.com/view/photo/photo/public/p2192654839.jpg"]];
    [self.view addSubview:view];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
