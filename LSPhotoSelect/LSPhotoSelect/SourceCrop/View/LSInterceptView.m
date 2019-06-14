//
//  LSInterceptView.m
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import "LSInterceptView.h"
#import "LSVideoFrameCell.h"

@interface LSInterceptView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) CGSize itemCellSize;

@property (nonatomic, assign) CGSize itemImgSize;

/**
 视频时间长度
 */
@property (nonatomic, assign) NSUInteger duration;

@property (nonatomic, strong) AVAssetImageGenerator * generator;
@property (nonatomic, strong) NSMutableArray * imageSource;

@property (nonatomic, strong) UICollectionView * collection;

@property (nonatomic, strong) UIView * cropView;

@end

@implementation LSInterceptView

- (instancetype)initWithAsset:(AVAsset *)asset videoDuration:(NSUInteger)duration {
    self = [super init];
    if (self) {
        
        [self commonInit];
        
        self.asset = asset;
        _duration = duration;
        [self configSubviews];
    }
    return self;
}

- (void)commonInit {
    _itemCellSize = CGSizeMake(28, 50);
    _itemImgSize = CGSizeMake(56, 100);
}

- (void)configSubviews {
    [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setAsset:(AVAsset *)asset {
    _asset = asset;
    if (_asset == nil) {
        return;
    }
    
    _duration = _asset.duration.value * 1.f / _asset.duration.timescale;
    self.collection.contentOffset = CGPointMake(-self.collection.contentInset.left, 0);
    
    _generator = [[AVAssetImageGenerator alloc] initWithAsset:_asset];
    _generator.maximumSize = _itemImgSize;
    _generator.appliesPreferredTrackTransform = YES;
    _generator.requestedTimeToleranceBefore = kCMTimeZero;
    _generator.requestedTimeToleranceAfter = kCMTimeZero;
    _generator.apertureMode = AVAssetImageGeneratorApertureModeProductionAperture;
    
    //获取视频每帧的图片
    [self configImageSource];
}

- (void)configImageSource {
    CGFloat timeUnit = 15 * 1.0f / 10;
    int count = _duration / timeUnit;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < count; i++) {
            CMTime item = CMTimeMake(timeUnit * i * self->_asset.duration.timescale, self->_asset.duration.timescale);
            NSError * err = nil;
            CGImageRef imageRef = [self->_generator copyCGImageAtTime:item actualTime:NULL error:&err];
            if (imageRef == nil || err) {
                continue;
            }
            UIImage * frameImage = imageRef ? [UIImage imageWithCGImage:imageRef] : nil;
            CGImageRelease(imageRef);
            if (frameImage == nil) {
                continue;
            }
            [self.imageSource addObject:frameImage];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collection reloadData];
        });
    });
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSVideoFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LSVideoFrameCell" forIndexPath:indexPath];
    cell.imageView.image = [self.imageSource objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - getter or setter
- (UICollectionView *)collection {
    if (!_collection) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(28, 50);
        layout.sectionInset = UIEdgeInsetsZero;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 375, 50) collectionViewLayout:layout];
        [_collection registerNib:[UINib nibWithNibName:@"LSVideoFrameCell" bundle:nil] forCellWithReuseIdentifier:@"LSVideoFrameCell"];
        _collection.delegate = self;
        _collection.dataSource = self;
        _collection.showsHorizontalScrollIndicator = NO;
        _collection.contentInset = UIEdgeInsetsMake(0, 45, 0, 45);
        [self addSubview:_collection];
    }
    return _collection;
}

- (NSMutableArray *)imageSource {
    if (!_imageSource) {
        _imageSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _imageSource;
}

@end
