//
//  ViewController.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/8/30.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *leftTF;
@property (weak, nonatomic) IBOutlet UITextField *topTF;
@property (weak, nonatomic) IBOutlet UITextField *bottomTF;
@property (weak, nonatomic) IBOutlet UITextField *rightTF;

@property (weak, nonatomic) IBOutlet UITextField *itemSpaceTF;

@property (weak, nonatomic) IBOutlet UITextField *itemOfLineCountTF;

@property (nonatomic, weak) IBOutlet UITextField * maxSelectedCountTF;


@property (nonatomic, weak) IBOutlet UISwitch * sortOrderSwitch;

@property (nonatomic, weak) IBOutlet UIButton * imageButton;

@property (nonatomic, weak) IBOutlet UIButton * videoButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)handleJumpToSelectPhoto:(id)sender {
    [self.view endEditing:YES];
    // 获取用户数据
    UIEdgeInsets sectionInset = UIEdgeInsetsZero;
    if ([self.leftTF.text length] != 0) {
        sectionInset.left = self.leftTF.text.integerValue;
    }
    if ([self.rightTF.text length] != 0) {
        sectionInset.right = self.rightTF.text.integerValue;
    }
    if ([self.topTF.text length] != 0) {
        sectionInset.top = [self.topTF.text integerValue];
    }
    if ([self.bottomTF.text length] != 0) {
        sectionInset.bottom = [self.bottomTF.text integerValue];
    }
    CGFloat itemSpace = 0;
    if ([self.itemSpaceTF.text length] != 0) {
        itemSpace = [self.itemSpaceTF.text floatValue];
    }
    CGFloat itemOfLineCount = 0;
    if ([self.itemOfLineCountTF.text length] != 0) {
        itemOfLineCount = [self.itemOfLineCountTF.text integerValue];
    }
    LSSortOrder sortOrder = self.sortOrderSwitch.isOn ? LSSortOrderAscending : LSSortOrderDescending;
    LSAssetType assetType = LSAssetTypeNone;
    if (!_imageButton.isSelected && _videoButton.isSelected) {
        assetType = LSAssetTypeVideos;
    }
    if (_imageButton.isSelected && !_videoButton.isSelected) {
        assetType = LSAssetTypeImages;
    }
    if (_imageButton.isSelected && _videoButton.isSelected) {
        assetType = LSAssetTypeAll;
    }
    NSUInteger maxSelectedCount = 0;
    if ([_maxSelectedCountTF.text length] > 0) {
        maxSelectedCount = [_maxSelectedCountTF.text integerValue];
    }
    [self judgeAppPhotoLibraryUsageAuth:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusRestricted: {
                NSLog(@"访问限制.");
            }
                break;
            case PHAuthorizationStatusDenied: {
                NSLog(@"访问被拒.");
            }
                break;
            case PHAuthorizationStatusAuthorized: {
//                [self presentViewController:[LSPhotoSelectNavC ls_defaultPhotoSelectNavC] animated:YES completion:nil];
//                dispatch_async(dispatch_get_main_queue(), ^{
                    LSPhotoSelectNavC *nav = [[LSPhotoSelectNavC alloc] initWithAssetType:assetType lineItemCount:itemOfLineCount sectionInset:sectionInset space:itemSpace sortOrder:sortOrder maxSelectedCount:maxSelectedCount];
                    [self presentViewController:nav animated:YES completion:nil];
//                });
            }
                break;
            case PHAuthorizationStatusNotDetermined: {
                NSLog(@"未决定.");
            }
                break;
        }
    }];
}


- (IBAction)handleSwitchOn:(UISwitch *)sender {
}

- (IBAction)handleClickImageButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}

- (IBAction)handleClickVideoButton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _leftTF) {
        [_rightTF becomeFirstResponder];
    }
    if (textField == _rightTF) {
        [_topTF becomeFirstResponder];
    }
    if (textField == _topTF) {
        [_bottomTF becomeFirstResponder];
    }
    if (textField == _bottomTF) {
        [_itemSpaceTF becomeFirstResponder];
    }
    if (_itemSpaceTF == textField) {
        [_itemOfLineCountTF becomeFirstResponder];
    }
    if (_itemOfLineCountTF == textField) {
        [_maxSelectedCountTF becomeFirstResponder];
    }
    if (_maxSelectedCountTF == textField) {
        [self.view endEditing:YES];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
