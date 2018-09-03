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
    [self judgeAppPhotoLibraryUsageAuth:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusRestricted: {
                NSLog(@"访问限制.");
            }
                break;
            case PHAuthorizationStatusDenied: {
                NSLog(@"访问被拒.");
            }
                break;
            case PHAuthorizationStatusAuthorized: {
                [self presentViewController:[LSPhotoSelectNavC ls_defaultPhotoSelectNavC] animated:YES completion:nil];
            }
                break;
            case PHAuthorizationStatusNotDetermined: {
                NSLog(@"未决定.");
            }
                break;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
