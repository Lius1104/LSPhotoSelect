//
//  LSAssetCollectionToolBar.m
//  LSPhotoSelect
//
//  Created by 刘爽 on 2018/9/6.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAssetCollectionToolBar.h"

@interface LSAssetCollectionToolBar ()

@property (nonatomic, assign) BOOL isShowCount;

@property (nonatomic, assign) BOOL isShowOriginal;


@property (nonatomic, strong) UIButton * previewButton;

@property (nonatomic, strong) UIButton * cropButton;

@property (nonatomic, strong) UIButton * originalButton;

@property (nonatomic, strong) UIButton * doneButton;

@end

@implementation LSAssetCollectionToolBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _isShowCount = YES;
        _isShowOriginal = YES;
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithShowCount:(BOOL)isShowCount isShowOriginal:(BOOL)isShowOriginal {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self = [super initWithFrame:CGRectMake(0, 0, width, 44)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _isShowOriginal = isShowOriginal;
        _isShowCount = isShowCount;
        [self setupSubviews];
    }
    return self;
}

+ (instancetype)ls_assetCollectionToolBarWithShowCount:(BOOL)isShowCount showOriginal:(BOOL)isShowOriginal {
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    LSAssetCollectionToolBar * toolBar = [[LSAssetCollectionToolBar alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    LSAssetCollectionToolBar * toolBar = [[LSAssetCollectionToolBar alloc] initWithShowCount:isShowCount isShowOriginal:isShowOriginal];
    return toolBar;
}

- (void)setupSubviews {
    _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _previewButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _previewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_previewButton addTarget:self action:@selector(handleClickPreviewButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_previewButton];
    
    _cropButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    _cropButton.tintColor =
    [_cropButton setTitle:@"裁剪" forState:UIControlStateNormal];
    [_cropButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_cropButton addTarget:self action:@selector(handleClickCropButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cropButton];
    
    _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_originalButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _originalButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_originalButton setTitle:@"原图" forState:UIControlStateNormal];
    [_originalButton setImage:[UIImage imageNamed:@"source_normal"] forState:UIControlStateNormal];
    [_originalButton setImage:[UIImage imageNamed:@"source_selected"] forState:UIControlStateSelected];
    _originalButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    _originalButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_originalButton addTarget:self action:@selector(handleClickOriginalButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_originalButton];
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
    _doneButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_doneButton addTarget:self action:@selector(handleClickDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneButton];
    
    [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
    [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
    
    [self setUpConstraints];
    
    if (!_isShowOriginal) {
        _originalButton.hidden = YES;
    } else {
        _cropButton.hidden = YES;
    }
}

- (void)setUpConstraints {
    [_previewButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(20);
        make.width.mas_equalTo(80);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(35);
    }];
    
    [_cropButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.previewButton.mas_trailing).offset(12);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(35);
    }];
    
    [_originalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.previewButton.mas_trailing).offset(20);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(35);
    }];
    
    [_doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.mas_trailing).offset(-20);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(80);
    }];
}

- (void)configSourceCount:(NSUInteger)count {
    if (_isShowCount) {
        if (count == 0) {
            [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
            [_doneButton setTitle:@"确定" forState:UIControlStateNormal];
        } else {
            [_previewButton setTitle:[NSString stringWithFormat:@"预览(%d)", (int)count] forState:UIControlStateNormal];
            [_doneButton setTitle:[NSString stringWithFormat:@"确定(%d)", (int)count] forState:UIControlStateNormal];
        }
    }
    // 更新 UI
//    CGFloat width = ceil([_previewButton.currentTitle boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _previewButton.titleLabel.font} context:nil].size.width);
//    
//    [_previewButton mas_updateConstraints:^(MASConstraintMaker *make) {
//        
//    }];
}

#pragma mark - action
- (void)handleClickPreviewButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ls_assetCollectionToolBarDidClickPreviewButton)]) {
        [self.delegate ls_assetCollectionToolBarDidClickPreviewButton];
    }
}

- (void)handleClickCropButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ls_assetCollectionToolBarDidClickCropButton)]) {
        [self.delegate ls_assetCollectionToolBarDidClickCropButton];
    }
}

- (void)handleClickOriginalButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if ([self.delegate respondsToSelector:@selector(ls_assetCollectionToolBarDidClickOriginalButton:)]) {
        [self.delegate ls_assetCollectionToolBarDidClickOriginalButton:sender];
    }
}

- (void)handleClickDoneButton:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(ls_assetCollectionToolBarDidClickDoneButton)]) {
        [self.delegate ls_assetCollectionToolBarDidClickDoneButton];
    }
}

@end
