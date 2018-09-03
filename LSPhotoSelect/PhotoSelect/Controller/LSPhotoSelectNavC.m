//
//  LSPhotoSelectNavC.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSPhotoSelectNavC.h"

@interface LSPhotoSelectNavC ()

//@property (nonatomic, weak) UIViewController * fromVC;
@property (nonatomic, assign) LSAssetType assetType;

@property (nonatomic, assign) NSInteger lineItemCount;

@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) CGFloat space;

@end

@implementation LSPhotoSelectNavC

+ (LSPhotoSelectNavC *)ls_defaultPhotoSelectNavC {
    LSAssetCollectionListVC * listVC = [[LSAssetCollectionListVC alloc] init];
    LSPhotoSelectNavC * navC = [[LSPhotoSelectNavC alloc] initWithRootViewController:listVC];
    return navC;
}

- (instancetype)initWithAssetType:(LSAssetType)assetType lineItemCount:(NSInteger)lineItemCount sectionInset:(UIEdgeInsets)sectionInset space:(CGFloat)space {
    _assetType = assetType;
    _lineItemCount = lineItemCount;
    if (_lineItemCount == 0) {
        _lineItemCount = 4;
    }
    _sectionInset = sectionInset;
    _space = space;
    LSAssetCollectionListVC * listVC = [[LSAssetCollectionListVC alloc] initWithAssetType:_assetType lineItemCount:_lineItemCount sectionInset:_sectionInset space:_space];
    self = [super initWithRootViewController:listVC];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
//+ (void)judgePhotoLibraryAuth:(UIViewController *)fromVC {
//    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
//    switch (oldStatus) {
//        case PHAuthorizationStatusNotDetermined: {
//            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//                if (status == PHAuthorizationStatusAuthorized) {
//                    // 允许访问
//                    [fromVC presentViewController:[self ls_defaultPhotoSelectNavC] animated:YES completion:nil];
//                } else {
//                    // 拒绝访问
//                    NSLog(@"拒绝访问");
//                }
//            }];
//        }
//            break;
//        case PHAuthorizationStatusRestricted: {
//            UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"访问受限" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                //  访问受限
//            }];
//            [alertC addAction:cancelAction];
//            [fromVC presentViewController:alertC animated:YES completion:nil];
//        }
//            break;
//        case PHAuthorizationStatusDenied: {
//            UIAlertController * alertC = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前您拒绝app访问相册，如需访问请点击\"前往\"打开权限" preferredStyle:UIAlertControllerStyleAlert];
//            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                //  用户 拒绝打开相册权限
//            }];
//            UIAlertAction * doneAction = [UIAlertAction actionWithTitle:@"前往" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                // 跳转到设置
//                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//                if ([[UIApplication sharedApplication] canOpenURL:url]) {
//                    [[UIApplication sharedApplication] openURL:url];
//                }
//            }];
//            [alertC addAction:doneAction];
//            [alertC addAction:cancelAction];
//            [fromVC presentViewController:alertC animated:YES completion:nil];
//        }
//            break;
//        case PHAuthorizationStatusAuthorized: {
//            [fromVC presentViewController:[self ls_defaultPhotoSelectNavC] animated:YES completion:nil];
//        }
//            break;
//    }
//}

@end
