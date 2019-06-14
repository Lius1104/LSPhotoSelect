//
//  LSInterceptVideo.m
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import "LSInterceptVideo.h"
#import "LSInterceptView.h"

@interface LSInterceptVideo ()

@property (nonatomic, strong) UIView * playerView;
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * playerItem;
@property (nonatomic, strong) AVPlayerLayer * playerLayer;

@property (nonatomic, strong) LSInterceptView * operationView;

@property (nonatomic, strong) UIButton * cancelButton;

@property (nonatomic, strong) UIButton * doneButton;

@property (nonatomic, strong) AVAsset * avasset;

@property (nonatomic, strong) PHVideoRequestOptions * videoOptions;

@end

@implementation LSInterceptVideo

- (instancetype)initWithAsset:(PHAsset *)asset defaultDuration:(NSUInteger)duration {
    self = [super init];
    if (self) {
        _asset = asset;
        if (_asset.duration < duration) {
            _duration = _asset.duration;
        } else {
            _duration = duration;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    [self configSubivews];
    
    [self.playerView.layer addSublayer:self.playerLayer];
    
    [self.view layoutIfNeeded];
    CGRect bounds = self.playerView.bounds;
    _playerLayer.frame = bounds;
    NSLog(@"%@", NSStringFromCGRect(bounds));
    // phasset转化成 avasset
    __weak typeof(self) weak_self = self;
    [[PHImageManager defaultManager] requestAVAssetForVideo:_asset options:self.videoOptions resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weak_self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
            weak_self.player = [[AVPlayer alloc] initWithPlayerItem:weak_self.playerItem];
            weak_self.playerLayer.player = weak_self.player;
            weak_self.avasset = asset;
        });
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    self.playerLayer.frame = self.playerView.bounds;

}

- (void)configSubivews {
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(10);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-15);
        } else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-15);
        }
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(20);
    }];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.cancelButton);
        make.size.equalTo(self.cancelButton);
        make.trailing.equalTo(self.view).offset(-10);
    }];
    
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.cancelButton.mas_top).offset(-25);
        make.height.mas_equalTo(50);
    }];
    
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view);
        }
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.operationView.mas_top).offset(-12);
    }];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - action
- (void)handleClickCancelButton {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)handleClickDoneButton {
    
}

#pragma mark - getter or setter
- (void)setAvasset:(AVAsset *)avasset {
    _avasset = avasset;
    _operationView.asset = avasset;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(handleClickCancelButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_cancelButton];
    }
    return _cancelButton;
}

- (UIButton *)doneButton {
    if (!_doneButton) {
        _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(handleClickDoneButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_doneButton];
    }
    return _doneButton;
}

- (LSInterceptView *)operationView {
    if (!_operationView) {
        _operationView = [[LSInterceptView alloc] initWithAsset:nil videoDuration:0];
        _operationView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_operationView];
    }
    return _operationView;
}

- (UIView *)playerView {
    if (!_playerView) {
        _playerView = [[UIView alloc] init];
        _playerView.contentMode = UIViewContentModeScaleAspectFit;
        _playerView.layer.masksToBounds = YES;
        [self.view addSubview:_playerView];
    }
    return _playerView;
}

- (PHVideoRequestOptions *)videoOptions {
    if (!_videoOptions) {
        _videoOptions = [[PHVideoRequestOptions alloc] init];
        _videoOptions.version = PHVideoRequestOptionsVersionCurrent;
        _videoOptions.networkAccessAllowed = YES;
    }
    return _videoOptions;
}

- (AVPlayerLayer *)playerLayer {
    if (!_playerLayer) {
        _playerLayer = [[AVPlayerLayer alloc] init];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerLayer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    return _playerLayer;
}

@end
