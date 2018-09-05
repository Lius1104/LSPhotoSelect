//
//  LSAssetCollectionListVC.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAssetCollectionListVC.h"
#import "LSAlbumModel.h"
#import "LSAlbumListCell.h"

#define ARC4RANDOM_MAX      0x100000000

typedef void(^PHCoverImageBlock)(UIImage * coverImg);

@interface LSAssetCollectionListVC ()<UITableViewDelegate, UITableViewDataSource, PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) PHCachingImageManager * manager;

@property (nonatomic, strong) PHImageRequestOptions * options;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray <LSAlbumModel *>* albumSource;

@property (nonatomic, strong) PHFetchResult <PHAssetCollection *>* smartAlbums;

@property (nonatomic, strong) PHFetchResult <PHAssetCollection *>* userAlbums;

@property (nonatomic, strong) PHAssetCollection * userLibrary;

@property (nonatomic, assign) LSAssetType assetType;

@property (nonatomic, assign) NSInteger lineItemCount;

@property (nonatomic, assign) UIEdgeInsets sectionInset;

@property (nonatomic, assign) CGFloat space;

@property (nonatomic, assign) LSSortOrder sortOrder;

@property (nonatomic, assign) NSUInteger maxSelectedCount;


@end

@implementation LSAssetCollectionListVC

- (instancetype)initWithAssetType:(LSAssetType)assetType lineItemCount:(NSInteger)lineItemCount sectionInset:(UIEdgeInsets)sectionInset space:(CGFloat)space sortOrder:(LSSortOrder)sortOrder maxSelectedCount:(NSUInteger)maxSelectedCount {
    self = [super init];
    if (self) {
        _assetType = assetType;
        if (lineItemCount == 0) {
            _lineItemCount = 4;
        } else {
            _lineItemCount = lineItemCount;
        }
        
        _sectionInset = sectionInset;
        _space = space < 0 ? 0 : space;
        _sortOrder = sortOrder;
        _maxSelectedCount = maxSelectedCount;
        
        _albumSource = [NSMutableArray arrayWithCapacity:1];
        
        // 获取所有相册
        [self getAllAssetCollections];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 默认值
        _assetType = LSAssetTypeAll;
        _lineItemCount = 4;
        _space = 3;
        _sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
        _sortOrder = LSSortOrderAscending;
        _maxSelectedCount = 0;
        
        _albumSource = [NSMutableArray arrayWithCapacity:1];
        
        // 获取所有相册
        [self getAllAssetCollections];
    }
    return self;
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"相册";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(handleBack)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];

    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    // 跳转到 所有照片中
    [self jumpToAlbum:_userLibrary animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 获取所有相册
    [self getAllAssetCollections];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
- (void)getAllAssetCollections {
    // 监测权限，哈哈，不知道为什么今天很开心
    _smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    _userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [self updateAlbums];
}

- (void)updateAlbums {
    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    switch (_assetType) {
        case LSAssetTypeNone:
        case LSAssetTypeAll: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
        }
            break;
        case LSAssetTypeImages: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        }
            break;
        case LSAssetTypeVideos: {
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        }
            break;
    }
    
    [self.albumSource removeAllObjects];
    for (PHAssetCollection * assetCollection in _smartAlbums) {
        if (assetCollection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumAllHidden) {
            LSAlbumModel * album = [[LSAlbumModel alloc] init];
            album.assetCollection = assetCollection;
            if (assetCollection.estimatedAssetCount == NSNotFound) {
                PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                album.sourceCount = result.count;
            } else {
                album.sourceCount = assetCollection.estimatedAssetCount;
            }
            if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                _userLibrary = assetCollection;
                [self.albumSource insertObject:album atIndex:0];
            } else {
                [self.albumSource addObject:album];
            }
            if (album.sourceCount > 0) {
                // 获取 相册封面
                [self getAssetCollection:assetCollection coverImg:^(UIImage *coverImg) {
                    album.coverImg = coverImg;
                }];
            }
        }
    }
    for (PHAssetCollection * assetCollection in _userAlbums) {
        NSUInteger count = assetCollection.estimatedAssetCount;
        if (count == NSNotFound) {
            PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            count = result.count;
        }
        
        if (count > 0) {
            LSAlbumModel * album = [[LSAlbumModel alloc] init];
            album.assetCollection = assetCollection;
            album.sourceCount = count;
            [self.albumSource addObject:album];
            // 获取 相册封面
            [self getAssetCollection:assetCollection coverImg:^(UIImage *coverImg) {
                album.coverImg = coverImg;
            }];
        }
    }
}

- (void)getAssetCollection:(PHAssetCollection *)assetCollection coverImg:(PHCoverImageBlock)coverImageBlock {
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    if (fetchResult.count <= 0) {
        coverImageBlock(nil);
        return;
    }
    
    PHAsset * asset = [fetchResult firstObject];
    [self.manager requestImageForAsset:asset targetSize:CGSizeMake(60, 60) contentMode:PHImageContentModeAspectFill options:self.options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        coverImageBlock(result);
    }];
}

- (void)jumpToAlbum:(PHAssetCollection *)assetCollection animated:(BOOL)animated {
    LSAssetCollectionVC * assetVC = [[LSAssetCollectionVC alloc] initWithAssetCollection:assetCollection assetType:_assetType lineItemCount:_lineItemCount sectionInset:_sectionInset space:_space sortOrder:_sortOrder maxSelectedCount:_maxSelectedCount];
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:assetVC animated:animated];
}

#pragma mark - action
- (void)handleBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        PHFetchResultChangeDetails * changeDetail = [changeInstance changeDetailsForFetchResult:self.smartAlbums];
        if (changeDetail) {
            self.smartAlbums = changeDetail.fetchResultAfterChanges;
        }
        changeDetail = [changeInstance changeDetailsForFetchResult:self.userAlbums];
        if (changeDetail) {
            self.userAlbums = changeDetail.fetchResultAfterChanges;
        }
        [self updateAlbums];
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [self.albumSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSAlbumListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ls_assetCollectionList_cell"];
    if (cell == nil) {
        cell = [[LSAlbumListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ls_assetCollectionList_cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.intoImageView.image = [UIImage imageNamed:@"into"];
    }
    
    LSAlbumModel * album = [self.albumSource objectAtIndex:indexPath.row];
    [cell setUpCoverImage:album.coverImg];
    NSMutableAttributedString * titleString = [[NSMutableAttributedString alloc] initWithString:album.assetCollection.localizedTitle attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15], NSForegroundColorAttributeName: [UIColor blackColor]}];
    NSAttributedString * countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" (%d)", (int)album.sourceCount] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13], NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    [titleString appendAttributedString:countString];
    cell.titleLabel.attributedText = titleString;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _albumSource.count) {
        LSAlbumModel * album = [_albumSource objectAtIndex:indexPath.row];
        [self jumpToAlbum:album.assetCollection animated:YES];
    }
}

#pragma mark - lazy load
//- (NSMutableArray *)albumSource {
//    if (!_albumSource) {
//        _albumSource = [NSMutableArray arrayWithCapacity:1];
//    }
//    return _albumSource;
//}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (PHCachingImageManager *)manager {
    if (!_manager) {
        _manager = [[PHCachingImageManager alloc] init];
    }
    return _manager;
}

- (PHImageRequestOptions *)options {
    if (!_options) {
        _options = [[PHImageRequestOptions alloc] init];
        _options.synchronous = YES;//为了效果，我这里选择了同步 因为只获取一张照片，不会对界面产生很大的影响
        _options.resizeMode = PHImageRequestOptionsResizeModeFast;
        _options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    }
    return _options;
}

@end
