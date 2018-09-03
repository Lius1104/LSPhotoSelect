//
//  NSIndexSet+LSAdd.h
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/9/3.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (LSAdd)

+ (NSArray<NSIndexPath *> *)indexPathsFromIndexSet:(NSIndexSet *)indexSet;

@end
