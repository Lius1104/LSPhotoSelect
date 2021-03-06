//
//  LSInterceptVideo.m
//  LSPhotoSelect
//
//  Created by LiuShuang on 2019/6/14.
//  Copyright © 2019 Shuang Lau. All rights reserved.
//

#import "LSInterceptVideo.h"
#import "LSInterceptView.h"
#import "LSSaveToAlbum.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LSInterceptVideo ()<LSInterceptViewDelegate>

@property (nonatomic, strong) UIView * playerView;
@property (nonatomic, strong) AVPlayer * player;
@property (nonatomic, strong) AVPlayerItem * playerItem;
@property (nonatomic, strong) AVPlayerLayer * playerLayer;

@property (nonatomic, strong) LSInterceptView * operationView;

@property (nonatomic, strong) UIButton * cancelButton;

@property (nonatomic, strong) UIButton * doneButton;

@property (nonatomic, strong) AVAsset * avasset;

@property (nonatomic, strong) PHVideoRequestOptions * videoOptions;

@property (nonatomic, weak) NSTimer * timer;
@property (nonatomic, assign) CMTime startRange;
@property (nonatomic, assign) CGFloat playDuration;

@property (nonatomic, strong) MBProgressHUD * hud;

@end

@implementation LSInterceptVideo

- (void)dealloc {
    _player = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidBecomActive) name:UIApplicationDidBecomeActiveNotification object:nil];

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

- (void)startTimer {
    [self stopTimer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:_playDuration target:self selector:@selector(handlePlayPartVideo:) userInfo:nil repeats:YES];
    [_timer fire];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
    [self.playerLayer.player pause];
}

- (void)cropVideo {
    if (_hud) {
        [_hud hideAnimated:YES];
        _hud = nil;
    }
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    CMTime end = [_operationView getEndTime];
    [[PHImageManager defaultManager] requestExportSessionForVideo:_asset options:self.videoOptions exportPreset:AVAssetExportPresetPassthrough resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
        CMTimeRange range = CMTimeRangeMake(self->_startRange, end);
        exportSession.timeRange = range;
        exportSession.shouldOptimizeForNetworkUse = YES;
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) firstObject];
        filePath = [NSString stringWithFormat:@"%@/cropVideo.mp4", filePath];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        exportSession.outputURL = [NSURL fileURLWithPath:filePath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown:
                    break;
                case AVAssetExportSessionStatusWaiting:
                    break;
                case AVAssetExportSessionStatusExporting:
                    break;
                case AVAssetExportSessionStatusCompleted: {
                    [[LSSaveToAlbum mainSave] saveVideoWithUrl:[NSURL fileURLWithPath:filePath] successBlock:^(NSString *assetLocalId) {
                        if ([assetLocalId length] > 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self->_hud hideAnimated:YES];
                                [self dismissViewControllerAnimated:YES completion:nil];
                                if ([self.delegate respondsToSelector:@selector(ls_interceptVideoDidCropVideo:)]) {
                                    [self.delegate ls_interceptVideoDidCropVideo:assetLocalId];
                                }
                            });
                        } else {
                            self->_hud.label.text = @"保存到本地相册失败";
                            [self->_hud hideAnimated:YES afterDelay:1.5];
                        }
                    }];
                }
                    break;
                case AVAssetExportSessionStatusFailed:
                    self->_hud.label.text = @"裁剪失败，请重试";
                    [self->_hud hideAnimated:YES afterDelay:1.5];
                    break;
                case AVAssetExportSessionStatusCancelled:
                    self->_hud.label.text = @"裁剪被取消，请重试";
                    [self->_hud hideAnimated:YES afterDelay:1.5];
                    break;
                default:
                    break;
            }
        }];
    }];
}

#pragma mark - action
- (void)handleClickCancelButton {
    [self stopTimer];
    [_operationView stopProgress];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)handleClickDoneButton {
    [self stopTimer];
    [_operationView stopProgress];
    //裁剪当前视频
    [self cropVideo];
}

- (void)handlePlayPartVideo:(NSTimer *)timer {
    [self.player seekToTime:_startRange toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.player play];
}

- (void)handleApplicationWillResignActive {
    [_operationView stopProgress];
    [self stopTimer];
}

- (void)handleApplicationDidBecomActive {
    [_operationView startProgress];
    [self startTimer];
}

#pragma mark - LSInterceptViewDelegate
- (void)ls_interceptViewDidChanged:(CMTime)time {
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self stopTimer];
    [self.player pause];
}

- (void)ls_interceptViewDidEndChangeTime:(CMTime)time duration:(CGFloat)duration {
    _startRange = time;
    _playDuration = duration;
    [self startTimer];
}

- (void)ls_interceptViewDidSeekToTime:(CMTime)time {
    [self stopTimer];
    [self.playerLayer.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

#pragma mark - getter or setter
- (void)setAvasset:(AVAsset *)avasset {
    _avasset = avasset;
    _startRange = CMTimeMakeWithSeconds(0, avasset.duration.timescale);
    _operationView.asset = avasset;
    _playDuration = 0;
    if (_asset.duration < kMaximumDuration) {
        _playDuration = _asset.duration;
    } else {
        _playDuration = kMaximumDuration;
    }
    [self startTimer];
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
        _operationView.backgroundColor = [UIColor blackColor];
        _operationView.delegate = self;
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
        _playerLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    return _playerLayer;
}

@end
