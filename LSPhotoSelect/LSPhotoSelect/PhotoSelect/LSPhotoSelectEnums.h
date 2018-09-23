//
//  LSPhotoSelectEnums.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/9/3.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#ifndef LSPhotoSelectEnums_h
#define LSPhotoSelectEnums_h

typedef enum : NSUInteger {
    LSAssetTypeNone,
    LSAssetTypeImages,
    LSAssetTypeVideos,
    LSAssetTypeAll,
} LSAssetType;

typedef enum : NSUInteger {
    LSSortOrderAscending,
    LSSortOrderDescending,
} LSSortOrder;

#endif /* LSPhotoSelectEnums_h */
