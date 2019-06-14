//
//  LSInterceptView.m
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import "LSInterceptView.h"
#import <objc/runtime.h>
#import "LSVideoFrameCell.h"

@interface LSInterceptView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) CGSize itemCellSize;

@property (nonatomic, assign) CGSize itemImgSize;

/**
 视频时间长度
 */
@property (nonatomic, assign) NSUInteger duration;

@property (nonatomic, strong) AVAssetImageGenerator * generator;

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary <NSString *, UIImage *> * imageCache;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSBlockOperation *> * opCache;

@property (nonatomic, assign) CGFloat timeUnit;
@property (nonatomic, assign) int imageCount;


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
    _timeUnit = 15 * 1.0f / 7.5;
    _imageCount = _duration / _timeUnit;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (int i = 0; i < count; i++) {
//            CMTime item = CMTimeMake(timeUnit * i * self->_asset.duration.timescale, self->_asset.duration.timescale);
//            NSError * err = nil;
//            CGImageRef imageRef = [self->_generator copyCGImageAtTime:item actualTime:NULL error:&err];
//            if (imageRef == nil || err) {
//                continue;
//            }
//            UIImage * frameImage = imageRef ? [UIImage imageWithCGImage:imageRef] : nil;
//            CGImageRelease(imageRef);
//            if (frameImage == nil) {
//                continue;
//            }
//            [self.imageSource addObject:frameImage];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.collection reloadData];
//        });
//    });
    [self.collection reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSVideoFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LSVideoFrameCell" forIndexPath:indexPath];
    cell.imageView.image = self.imageCache[@(indexPath.row).stringValue];
    return cell;
}

static const char _ZLOperationCellKey;
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (!_asset) return;
    
    if (_imageCache[@(indexPath.row).stringValue] || _opCache[@(indexPath.row).stringValue]) {
        return;
    }
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        NSInteger row = indexPath.row;
//        NSInteger i = row  * self->_timeUnit;
        
        CMTime time = CMTimeMake(row  * self->_timeUnit * self->_asset.duration.timescale, self->_asset.duration.timescale);
        
        NSError *error = nil;
        CGImageRef cgImg = [self.generator copyCGImageAtTime:time actualTime:NULL error:&error];
        if (!error && cgImg) {
            UIImage *image = [UIImage imageWithCGImage:cgImg];
            CGImageRelease(cgImg);
            
            [self->_imageCache setValue:image forKey:@(row).stringValue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSIndexPath *nowIndexPath = [collectionView indexPathForCell:cell];
                if (row == nowIndexPath.row) {
                    [(LSVideoFrameCell *)cell imageView].image = image;
                } else {
                    UIImage *cacheImage = self->_imageCache[@(nowIndexPath.row).stringValue];
                    if (cacheImage) {
                        [(LSVideoFrameCell *)cell imageView].image = cacheImage;
                    }
                }
            });
            [self->_opCache removeObjectForKey:@(row).stringValue];
        }
        objc_removeAssociatedObjects(cell);
    }];
    [self.queue addOperation:op];
    [self.opCache setValue:op forKey:@(indexPath.row).stringValue];
    
    objc_setAssociatedObject(cell, &_ZLOperationCellKey, op, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSBlockOperation *op = objc_getAssociatedObject(cell, &_ZLOperationCellKey);
    if (op) {
        [op cancel];
        objc_removeAssociatedObjects(cell);
        [_opCache removeObjectForKey:@(indexPath.row).stringValue];
    }
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

- (NSOperationQueue *)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 3;
    }
    return _queue;
}

- (NSMutableDictionary<NSString *,UIImage *> *)imageCache {
    if (!_imageCache) {
        _imageCache = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return _imageCache;
}

- (NSMutableDictionary<NSString *,NSBlockOperation *> *)opCache {
    if (!_opCache) {
        _opCache = [[NSMutableDictionary alloc] init];
    }
    return _opCache;
}

@end
