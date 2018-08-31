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

@interface LSAssetCollectionListVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray <LSAlbumModel *>* albumSource;

@property (nonatomic, strong) PHAssetCollection * userLibrary;

@end

@implementation LSAssetCollectionListVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _albumSource = [NSMutableArray arrayWithCapacity:1];
        // 获取所有相册
        [self getAllAssetCollections];
    }
    return self;
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
    [self.albumSource removeAllObjects];
    PHFetchOptions * options = [[PHFetchOptions alloc] init];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld || mediaType == %ld", PHAssetMediaTypeImage, PHAssetMediaTypeVideo];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection * assetCollection in smartAlbums) {
        if (assetCollection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumAllHidden) {
            PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
            if (assetCollection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                _userLibrary = assetCollection;
            }
            LSAlbumModel * album = [[LSAlbumModel alloc] init];
            album.assetCollection = assetCollection;
            album.sourceCount = result.count;
            [self.albumSource addObject:album];
            // 获取 相册封面
            [self getAssetCollection:assetCollection coverImg:^(UIImage *coverImg) {
                album.coverImg = coverImg;
            }];
        }
    }
    
    PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    for (PHAssetCollection * assetCollection in albums) {
        PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
        if (result.count > 0) {
            LSAlbumModel * album = [[LSAlbumModel alloc] init];
            album.assetCollection = assetCollection;
            album.sourceCount = result.count;
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
    
    PHImageManager * manager = [[PHImageManager alloc] init];
    PHAsset * asset = [fetchResult firstObject];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;//为了效果，我这里选择了同步 因为只获取一张照片，不会对界面产生很大的影响
    [manager requestImageForAsset:asset targetSize:CGSizeMake(60, 60) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        coverImageBlock(result);
    }];
}

- (void)jumpToAlbum:(PHAssetCollection *)assetCollection animated:(BOOL)animated {
    LSAssetCollectionVC * assetVC = [[LSAssetCollectionVC alloc] initWithAssetCollection:assetCollection assetType:LSAssetTypeAll itemSize:CGSizeZero];
    UIBarButtonItem * backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:assetVC animated:animated];
}

#pragma mark - action
- (void)handleBack {
    [self dismissViewControllerAnimated:YES completion:nil];
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
//        cell.intoImageView.image = [UIImage imageNamed:@"into"];
    }
    
    LSAlbumModel * album = [self.albumSource objectAtIndex:indexPath.row];
    cell.coverImageView.image = album.coverImg;
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

@end
