//
//  LSInterceptView.h
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

//NS_ASSUME_NONNULL_BEGIN

@interface LSInterceptView : UIView

@property (nonatomic, strong) AVAsset * asset;

- (instancetype)initWithAsset:(AVAsset *)asset videoDuration:(NSUInteger)duration;

@end

//NS_ASSUME_NONNULL_END
