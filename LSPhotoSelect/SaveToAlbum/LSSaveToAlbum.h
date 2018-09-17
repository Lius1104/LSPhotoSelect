//
//  LSSaveToAlbum.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/9/17.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSSaveToAlbum : NSObject

+ (LSSaveToAlbum *)mainSave;

- (void)configCustomAlbumName:(NSString *)customName;

- (void)saveImage:(UIImage *)image;

- (void)saveImageWithUrl:(NSURL *)imgUrl;

- (void)saveVideoWithUrl:(NSURL *)videoUrl;

@end
