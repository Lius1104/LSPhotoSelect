//
//  UIViewController+LSAuthorization.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "UIViewController+LSAuthorization.h"

@implementation UIViewController (LSAuthorization)

- (void)judgeAppPhotoLibraryUsageAuth:(PhotoLibraryUsageAuthBlock)authBlock {
    [NSObject judgeAppPhotoLibraryUsageAuth:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusNotDetermined: {
                authBlock(PHAuthorizationStatusDenied);
            }
                break;
            case PHAuthorizationStatusRestricted: {
                UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"访问受限" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    //  访问受限
                    authBlock(PHAuthorizationStatusRestricted);
                }];
                [alertC addAction:cancelAction];
                [self presentViewController:alertC animated:YES completion:nil];
            }
                break;
            case PHAuthorizationStatusDenied: {
                UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前您拒绝app访问相册，如需访问请点击\"前往\"打开权限" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    //  用户 拒绝打开相册权限
                    authBlock(PHAuthorizationStatusDenied);
                }];
                UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 跳转到设置
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }];
                [alertC addAction:doneAction];
                [alertC addAction:cancelAction];
                [self presentViewController:alertC animated:YES completion:nil];
            }
                break;
            case PHAuthorizationStatusAuthorized: {
                authBlock(PHAuthorizationStatusAuthorized);
            }
                break;
        }
    }];
}

@end
