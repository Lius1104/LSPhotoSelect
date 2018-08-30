//
//  LSAssetCollectionListVC.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAssetCollectionListVC.h"

@interface LSAssetCollectionListVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, strong) NSMutableArray * albumSource;

@end

@implementation LSAssetCollectionListVC

- (instancetype)init {
    self = [super init];
    if (self) {
        _albumSource = [NSMutableArray arrayWithCapacity:1];
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 获取所有相册
    [self getAllAssetCollections];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private
- (void)getAllAssetCollections {
    // 监测权限，哈哈，不知道为什么今天很开心
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [self.albumSource removeAllObjects];
    for (PHAssetCollection * album in smartAlbums) {
        [self.albumSource addObject:album];
    }
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
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ls_assetCollectionList_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ls_assetCollectionList_cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:arc4random()];
    return cell;
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
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
