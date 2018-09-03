//
//  NSIndexSet+LSAdd.m
//  LSPhotoSelect
//
//  Created by Shuang Lau on 2018/9/3.
//  Copyright © 2018年 Shuang Lau. All rights reserved.
//

#import "NSIndexSet+LSAdd.h"

@implementation NSIndexSet (LSAdd)

+ (NSArray<NSIndexPath *> *)indexPathsFromIndexSet:(NSIndexSet *)indexSet {
    NSMutableArray <NSIndexPath *>* indexPaths = [NSMutableArray arrayWithCapacity:1];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexPaths addObject:indexPath];
    }];
    return [indexPaths copy];
}

@end
