//
//  ViewController.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)handleJumpToSelectPhoto:(id)sender {
//    LSPhotoSelectNavC * navC = [LSPhotoSelectNavC ls_defaultPhotoSelectNavC];
//    [self presentViewController:navC animated:YES completion:nil];
    [LSPhotoSelectNavC ls_presentDefaultPhotoSelectNavCFrom:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
