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

/**
 默认跳转

 @param fromVC 需要跳转的页面
 */
//+ (void)ls_presentDefaultPhotoSelectNavCFrom:(UIViewController *)fromVC;

/**
 自定义初始化方法

 @param assetType 资源类型
 @param lineItemCount 每行的 item 个数
 @param sectionInset section inset
 @param space item 之间的间距
 @return navigationController
 */
- (instancetype)initWithAssetType:(LSAssetType)assetType lineItemCount:(NSInteger)lineItemCount sectionInset:(UIEdgeInsets)sectionInset space:(CGFloat)space sortOrder:(LSSortOrder)sortOrder maxSelectedCount:(NSUInteger)maxSelectedCount;

//- (void)ls_presentPhotoSelectNavCFrom:(UIViewController *)fromVC;

@end
