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

@property (nonatomic, strong) UIButton * selectedButton;

@end

@implementation LSAssetItemCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self addSubview:_coverImageView];
        
        _normalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_normalButton];
        
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_selectedButton];
        
        [self configConstrains];
    }
    return self;
}

- (void)configConstrains {
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [_normalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [_selectedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

@end
