//
//  MMLocalLibraryData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/30.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMModelController.h"


NS_ASSUME_NONNULL_BEGIN

@class MPMediaItem;
@interface MMLocalLibraryData : MMModelController
/**
 本地所有数据
 */
@property(nonatomic, strong, readonly) NSArray<NSDictionary<NSString*,NSArray<MPMediaItem*>*>*> *results;

@end

NS_ASSUME_NONNULL_END
