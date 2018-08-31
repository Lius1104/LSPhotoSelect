//
//  LSAssetItemCell.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/31.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSAssetItemCell : UICollectionViewCell

@property (nonatomic, copy) NSString * localIdentifier;

@property (nonatomic, strong) UIImageView * coverImageView;

@property (nonatomic, strong) UIImage * normalImage;

@property (nonatomic, strong) UIImage * selectedImage;

@end
