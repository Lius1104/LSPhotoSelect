//
//  LSAssetCollectionVC.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LSAssetTypeImages,
    LSAssetTypeVideos,
    LSAssetTypeAll,
} LSAssetType;

@interface LSAssetCollectionVC : UIViewController

@property (nonatomic, strong, readonly) PHAssetCollection * assetCollection;

@property (nonatomic, assign, readonly) LSAssetType assetType;

- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection assetType:(LSAssetType)assetType itemSize:(CGSize)itemSize;

@end
