//
//  LSAssetCollectionVC.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LSAssetCollectionVC : UIViewController

@property (nonatomic, strong, readonly) PHAssetCollection * assetCollection;

@property (nonatomic, assign, readonly) LSAssetType assetType;

- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection assetType:(LSAssetType)assetType lineItemCount:(NSInteger)lineItemCount sectionInset:(UIEdgeInsets)sectionInset space:(CGFloat)space sortOrder:(NSUInteger)sortOrder maxSelectedCount:(NSUInteger)maxSelectedCount;

@end
