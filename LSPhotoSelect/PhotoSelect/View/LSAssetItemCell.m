//
//  LSAssetItemCell.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/31.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAssetItemCell.h"

@interface LSAssetItemCell ()

@property (nonatomic, strong) UIButton * normalButton;

//@property (nonatomic, strong) UIButton * selectedButton;

@property (nonatomic, copy) LSSelectSourceBlock block;


@end

@implementation LSAssetItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _sourceSelected = NO;
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];
        
        _livePhotoIcon = [[UIImageView alloc] init];
        _livePhotoIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_livePhotoIcon];
        
        _normalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_normalButton setImage:[UIImage imageNamed:@"source_normal"] forState:UIControlStateNormal];
        [_normalButton setImage:[UIImage imageNamed:@"source_selected"] forState:UIControlStateSelected];
        [_normalButton addTarget:self action:@selector(handleClickNormalButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_normalButton];
        
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
        _playButton.hidden = YES;
        [self addSubview:_playButton];
        
//        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        [self addSubview:_selectedButton];
        
        [self configConstrains];
    }
    return self;
}

- (void)configConstrains {
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_livePhotoIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    
    [_normalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
//    [_selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.right.equalTo(self);
//        make.size.mas_equalTo(CGSizeMake(30, 30));
//    }];
    
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.right.equalTo(self.normalButton.mas_right);
        make.bottom.equalTo(self);
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

- (void)setSourceSelected:(BOOL)sourceSelected {
    _sourceSelected = sourceSelected;
    _normalButton.selected = _sourceSelected;
}

- (void)setIsSelectable:(BOOL)isSelectable {
    _isSelectable = isSelectable;
    if (isSelectable) {
        _normalButton.hidden = NO;
    } else {
        _normalButton.hidden = YES;
    }
}

- (void)setUpSelectSourceBlock:(LSSelectSourceBlock)block {
    if (block) {
        self.block = [block copy];
    }
}

- (void)handleClickNormalButton:(UIButton *)sender {
//    sender.selected = !sender.isSelected;
    if (self.block) {
        self.block(self.localIdentifier);
    }
}

@end
