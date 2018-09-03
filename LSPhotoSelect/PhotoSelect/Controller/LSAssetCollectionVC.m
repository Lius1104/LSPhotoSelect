//
//  LSAssetCollectionVC.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAssetCollectionVC.h"
#import "LSAssetItemCell.h"

@interface LSAssetCollectionVC ()<UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver> {
    CGRect previousPreheatRect;
}

@property (nonatomic, assign) BOOL isNeedScroll;

@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) PHCachingImageManager * manager;

@property (nonatomic, strong) PHImageRequestOptions * options;

@property (nonatomic, strong) PHFetchResult <PHAsset *>* fetchResult;

@property (nonatomic, assign, readonly) NSInteger lineItemCount;

@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) CGFloat itemSpace;

@end

@implementation LSAssetCollectionVC

- (void)dealloc {
    [self resetCachedAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection assetType:(LSAssetType)assetType lineItemCount:(NSInteger)lineItemCount sectionInset:(UIEdgeInsets)sectionInset space:(CGFloat)space {
    self = [super init];
    if (self) {
        _assetCollection = assetCollection;
        _assetType = assetType;
        _sectionInset = sectionInset;
        _itemSpace = space;
        _isNeedScroll = YES;
        
        if (lineItemCount == 0) {
            _lineItemCount = 4;
        } else {
            _lineItemCount = lineItemCount;
        }
        
        CGFloat availableWidth = CGRectGetWidth([UIScreen mainScreen].bounds) - _sectionInset.left - _sectionInset.right - (space * (lineItemCount - 1));
        CGFloat width = availableWidth / _lineItemCount;
        _itemSize = CGSizeMake(width, width);
        
        _manager = [[PHCachingImageManager alloc] init];
        _options = [[PHImageRequestOptions alloc] init];
        _options.resizeMode = PHImageRequestOptionsResizeModeFast;
        _options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = _assetCollection.localizedTitle;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(handleBack)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self getAllAssets];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.isNeedScroll == YES) {
        if (_fetchResult.count > 0) {
            [_collectionView reloadData];
            NSInteger count = _fetchResult.count;
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
            [_collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        }
        self.isNeedScroll = NO;
    }
}

- (void)getAllAssets {
    if (_assetCollection == nil) {
        return;
    }
    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    switch (_assetType) {
        case LSAssetTypeImages: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }
            break;
        case LSAssetTypeVideos: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
            break;
        case LSAssetTypeAll: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        }
            break;
    }
    _fetchResult = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:options];
}

- (void)resetCachedAssets {
    [_manager stopCachingImagesForAllAssets];
    previousPreheatRect = CGRectZero;
}

- (void)updateAssetsCache {
    // self.view.window == nil 判断当前view是否显示在屏幕上
    if (!self.isViewLoaded || self.view.window == nil) {
        return;
    }
    
    // 预热区域 preheatRect 是 可见区域 visibleRect 的两倍高
    CGRect visibleRect = CGRectMake(0.f, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    CGRect preheatRect = CGRectInset(visibleRect, 0, -0.5 * visibleRect.size.height);
    
    // 只有当可见区域与最后一个预热区域显著不同时才更新
    CGFloat delta = fabs(CGRectGetMidY(preheatRect) - CGRectGetMidY(previousPreheatRect));
    if (delta > self.view.bounds.size.height / 3.f) {
        // 计算开始缓存和停止缓存的区域
        [self computeDifferenceBetweenRect:previousPreheatRect andRect:preheatRect removedHandler:^(CGRect removedRect) {
            [self imageManagerStopCachingImagesWithRect:removedRect];
        } addedHandler:^(CGRect addedRect) {
            [self imageManagerStartCachingImagesWithRect:addedRect];
        }];
        previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        //添加 向下滑动(往下翻看新的)时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        //添加 向上滑动(往上翻看之前的)时 newRect 除去与 oldRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        //移除 向上滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外底部的预热区域）
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        //移除 向下滑动时 oldRect 除去与 newRect 相交部分的区域（即：屏幕外顶部的预热区域）
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        //当 oldRect 与 newRect 没有相交区域时
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (void)imageManagerStartCachingImagesWithRect:(CGRect)rect {
    NSMutableArray<PHAsset *> *addAssets = [self indexPathsForElementsWithRect:rect];
    [_manager startCachingImagesForAssets:addAssets targetSize:_itemSize contentMode:PHImageContentModeAspectFill options:_options];
}

- (void)imageManagerStopCachingImagesWithRect:(CGRect)rect {
    NSMutableArray<PHAsset *> *removeAssets = [self indexPathsForElementsWithRect:rect];
    [_manager stopCachingImagesForAssets:removeAssets targetSize:_itemSize contentMode:PHImageContentModeAspectFill options:_options];
}

- (NSMutableArray<PHAsset *> *)indexPathsForElementsWithRect:(CGRect)rect {
    UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
    NSArray<__kindof UICollectionViewLayoutAttributes *> *layoutAttributes = [layout layoutAttributesForElementsInRect:rect];
    NSMutableArray<PHAsset *> *assets = [NSMutableArray array];
    for (__kindof UICollectionViewLayoutAttributes *layoutAttr in layoutAttributes) {
        NSIndexPath *indexPath = layoutAttr.indexPath;
        if (indexPath.row < _fetchResult.count) {
            PHAsset *asset = [_fetchResult objectAtIndex:indexPath.item];
            [assets addObject:asset];
        }
    }
    return assets;
}

#pragma mark - action
- (void)handleBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateAssetsCache];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails * changeDetail = [changeInstance changeDetailsForFetchResult:_fetchResult];
    if (changeDetail == nil) {
        return;
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.fetchResult = [changeDetail fetchResultAfterChanges];
        if (changeDetail.hasIncrementalChanges) {
            UICollectionView * collection = self.collectionView;
            if (collection) {
                [collection performBatchUpdates:^{
                    NSIndexSet * removedIndexes = changeDetail.removedIndexes;
                    if (removedIndexes.count > 0) {
                        NSArray <NSIndexPath *>* indexPaths = [NSIndexSet indexPathsFromIndexSet:removedIndexes];
                        [collection deleteItemsAtIndexPaths:indexPaths];
                    }
                    NSIndexSet * insertIndexes = changeDetail.insertedIndexes;
                    if (insertIndexes.count > 0) {
                        NSArray <NSIndexPath *>* indexPaths = [NSIndexSet indexPathsFromIndexSet:insertIndexes];
                        [collection deleteItemsAtIndexPaths:indexPaths];
                    }
                    NSIndexSet * changedIndexes = changeDetail.changedIndexes;
                    if (changedIndexes.count > 0) {
                        NSArray <NSIndexPath *>* indexPaths = [NSIndexSet indexPathsFromIndexSet:changedIndexes];
                        [collection deleteItemsAtIndexPaths:indexPaths];
                    }
                    [changeDetail enumerateMovesWithBlock:^(NSUInteger fromIndex, NSUInteger toIndex) {
                        [collection moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromIndex inSection:0] toIndexPath:[NSIndexPath indexPathForItem:toIndex inSection:0]];
                    }];
                } completion:nil];
            } else {
                //
            }
        } else {
            [self.collectionView reloadData];
        }
        [self resetCachedAssets];
    });
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_fetchResult count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSAssetItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ls_assetItem_Cell" forIndexPath:indexPath];
    if (indexPath.row < _fetchResult.count) {
        PHAsset * asset = [_fetchResult objectAtIndex:indexPath.row];
        if (@available(iOS 9.1, *)) {
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
                cell.livePhotoIcon.image = [PHLivePhotoView livePhotoBadgeImageWithOptions:PHLivePhotoBadgeOptionsOverContent];
            } else {
                cell.livePhotoIcon.image = nil;
            }
        } else {
            cell.livePhotoIcon.image = nil;
        }
        cell.localIdentifier = asset.localIdentifier;
        [_manager requestImageForAsset:asset targetSize:_itemSize contentMode:PHImageContentModeAspectFill options:_options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            if ([cell.localIdentifier isEqualToString:asset.localIdentifier]) {
                cell.coverImageView.image = result;
            }
        }];
    }
    return cell;
}

#pragma mark - getter or setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = _sectionInset;
        layout.itemSize = _itemSize;
        layout.minimumLineSpacing = _itemSpace;
        layout.minimumInteritemSpacing = _itemSpace;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[LSAssetItemCell class] forCellWithReuseIdentifier:@"ls_assetItem_Cell"];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

@end
