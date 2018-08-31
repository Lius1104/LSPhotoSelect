//
//  LSAlbumListCell.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/31.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "LSAlbumListCell.h"

@interface LSAlbumListCell ()

@property (nonatomic, strong) UIView * bottomLine;

@end

@implementation LSAlbumListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
        [self.contentView addSubview:_coverImageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLabel];
        
        _intoImageView = [[UIImageView alloc] init];
        _intoImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_intoImageView];
        
        _bottomLine = [[UIView alloc] init];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_bottomLine];
        
        [self configConstrains];
    }
    return self;
}

- (void)configConstrains {
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.contentView);
        make.width.equalTo(self.coverImageView.mas_height);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverImageView.mas_right).offset(10);
        make.top.bottom.equalTo(self.contentView);
    }];
    
    [_intoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.coverImageView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

@end
