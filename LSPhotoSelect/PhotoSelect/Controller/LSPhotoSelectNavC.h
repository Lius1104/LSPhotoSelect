//
//  LSPhotoSelectNavC.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSPhotoSelectNavC : UINavigationController

/**
 默认照片选择器，（照片视频混流，不带原图按钮，默认是原图）

 @return 自带导航栏的照片选择器
 */
+ (LSPhotoSelectNavC *)ls_defaultPhotoSelectNavC;

+ (void)ls_presentDefaultPhotoSelectNavCFrom:(UIViewController *)fromVC;

@end
