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
#import "LSEditFrameView.h"

@interface LSInterceptView ()<UICollectionViewDelegate, UICollectionViewDataSource, LSEditFrameViewDelegate>

@property (nonatomic, assign) CGSize itemCellSize;

@property (nonatomic, assign) CGSize itemImgSize;

/**
 视频时间长度
 */
@property (nonatomic, assign) NSUInteger duration;

@property (nonatomic, strong) AVAssetImageGenerator * generator;

@property (nonatomic, strong) NSMutableArray * timeSource;
@property (nonatomic, strong) NSMutableDictionary <NSString *, UIImage *> * imageCache;

@property (nonatomic, strong) UICollectionView * collection;

@property (nonatomic, strong) LSEditFrameView * cropView;

@property (nonatomic, strong) UIView * progressLine;

@end

@implementation LSInterceptView

@synthesize validRect = _validRect;

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
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _validRect = CGRectMake(45, 0, width - 45 * 2, _itemCellSize.height);
}

- (void)configSubviews {
    [self.collection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.cropView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    // 开始动画
    [self startProgress];
}

- (void)configImageSource {
    _timeUnit = 1.f;
    NSUInteger imageCount = 0;
    if (_duration <= kMaximumDuration) {
        _timeUnit = _duration / 10.f;
        imageCount = 10;
    } else {
        _timeUnit = 1.5f;
        imageCount = _duration / 1.5f;
    }
    NSLog(@"before : %@", [NSDate date]);
    for (int i = 0; i < imageCount; i++) {
        CMTime item = CMTimeMake(_timeUnit * i * self->_asset.duration.timescale, self->_asset.duration.timescale);
        [self.timeSource addObject:[NSValue valueWithCMTime:item]];
    }
    NSLog(@"after : %@", [NSDate date]);
    [self.collection reloadData];
}

- (CMTime)getStartTime {
    CGRect rect = [self.collection convertRect:self.cropView.validRect fromView:self.cropView];
    CGFloat s = MAX(0, _timeUnit * rect.origin.x / (_itemCellSize.width));
    return CMTimeMakeWithSeconds(s, _asset.duration.timescale);
}

- (CMTime)getEndTime {
    CGRect rect = [self.collection convertRect:self.cropView.validRect fromView:self.cropView];
    CGFloat s = MAX(0, _timeUnit * CGRectGetMaxX(rect) / (_itemCellSize.width));
    return CMTimeMakeWithSeconds(s, _asset.duration.timescale);
}

- (void)startProgress {
    [self stopProgress];
    
    CGFloat duration = _timeUnit * self.validRect.size.width / (_itemCellSize.width);

    self.progressLine.frame = CGRectMake(self.validRect.origin.x, 0, 2, _itemCellSize.height);
    [self.cropView addSubview:_progressLine];
    [UIView animateWithDuration:duration delay:.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
        self->_progressLine.frame = CGRectMake(CGRectGetMaxX(self->_validRect) - 2, 0, 2, self->_itemCellSize.height);
    } completion:nil];
}

- (void)stopProgress {
    [_progressLine removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self stopProgress];
    if ([self.delegate respondsToSelector:@selector(ls_interceptViewDidSeekToTime:)]) {
        [self.delegate ls_interceptViewDidSeekToTime:[self getStartTime]];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if ([self.delegate respondsToSelector:@selector(ls_interceptViewDidEndChangeTime:duration:)]) {
            [self startProgress];
            CGFloat duration = _timeUnit * self.validRect.size.width / (_itemCellSize.width);
            [self.delegate ls_interceptViewDidEndChangeTime:[self getStartTime] duration:duration];
        }
        [self loadImageForOnScreenRows];
    }
}

// table view 停止滚动了
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(ls_interceptViewDidEndChangeTime:duration:)]) {
        [self startProgress];
        CGFloat duration = _timeUnit * self.validRect.size.width / (_itemCellSize.width);
        [self.delegate ls_interceptViewDidEndChangeTime:[self getStartTime] duration:duration];
    }
    [self loadImageForOnScreenRows];
}

//节约性能，只加载当前显示在屏幕上的cell包含的image
- (void)loadImageForOnScreenRows {
    [_generator cancelAllCGImageGeneration];
    NSArray *visiableIndexPathes = [self.collection indexPathsForVisibleItems];
    for (NSIndexPath * indexPath in visiableIndexPathes) {
        UIImage * image = [self.imageCache objectForKey:[@(indexPath.row) stringValue]];
        if (!image) {
            LSVideoFrameCell * cell = (LSVideoFrameCell *)[self.collection cellForItemAtIndexPath:indexPath];
            [self configCellImage:cell index:indexPath.row];
        }
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.timeSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSVideoFrameCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LSVideoFrameCell" forIndexPath:indexPath];
    UIImage * image = self.imageCache[@(indexPath.row).stringValue];
    if (image) {
        cell.imageView.image = image;
    } else {
        [self configCellImage:cell index:indexPath.row];
    }
    return cell;
}

- (void)configCellImage:(LSVideoFrameCell *)cell index:(NSUInteger)index {
    NSValue * value = [self.timeSource objectAtIndex:index];
    [_generator generateCGImagesAsynchronouslyForTimes:@[value] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded) {
            [self.imageCache setValue:[UIImage imageWithCGImage:image] forKey:[@(index) stringValue]];
            [self performSelectorOnMainThread:@selector(handleUpdateCellImage:) withObject:cell waitUntilDone:NO];
        }
    }];
}

- (void)handleUpdateCellImage:(LSVideoFrameCell *)cell {
    NSIndexPath * indexPath = [self.collection indexPathForCell:cell];
    UIImage * image = self.imageCache[@(indexPath.row).stringValue];
    if (image) {
//        cell.imageView.image = image;
        [self.collection reloadData];
    }
}

#pragma mark - LSEditFrameViewDelegate
- (void)ls_editFrameValidRectChanged {
    if ([self.delegate respondsToSelector:@selector(ls_interceptViewDidChanged:)]) {
        [self stopProgress];
        [self.delegate ls_interceptViewDidChanged:[self getStartTime]];
    }
}

- (void)ls_editFrameValidRectEndChange {
    if ([self.delegate respondsToSelector:@selector(ls_interceptViewDidEndChangeTime:duration:)]) {
        [self startProgress];
        CGFloat duration = _timeUnit * self.validRect.size.width / (_itemCellSize.width);
        [self.delegate ls_interceptViewDidEndChangeTime:[self getStartTime] duration:duration];
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

- (NSMutableArray *)timeSource {
    if (!_timeSource) {
        _timeSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _timeSource;
}

- (NSMutableDictionary<NSString *,UIImage *> *)imageCache {
    if (!_imageCache) {
        _imageCache = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return _imageCache;
}

- (LSEditFrameView *)cropView {
    if (!_cropView) {
        _cropView = [[LSEditFrameView alloc] initWithItemSize:_itemCellSize initRect:_validRect];
        _cropView.delegate = self;
        _cropView.validRect = _validRect;
        [self addSubview:_cropView];
    }
    return _cropView;
}

- (UIView *)progressLine {
    if (!_progressLine) {
        _progressLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, _itemCellSize.height)];
        _progressLine.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.7];
    }
    return _progressLine;
}

- (void)setValidRect:(CGRect)validRect {
    if (validRect.origin.x == _validRect.origin.x && validRect.origin.y == _validRect.origin.y && _validRect.size.width == validRect.size.width && _validRect.size.height == validRect.size.height) {
    } else {
        _validRect = validRect;
        _cropView.validRect = _validRect;
    }
}

- (CGRect)validRect {
    _validRect = _cropView.validRect;
    return _validRect;
}

@end
