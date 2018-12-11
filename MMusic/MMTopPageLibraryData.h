//
//  MMTopPageLibraryData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/29.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMModelController.h"

NS_ASSUME_NONNULL_BEGIN

// 一级分页 控制
@interface MMTopPageLibraryData : MMModelController
/**mymusic 顶部ICloud 和 Local 分页*/
@property(nonatomic, strong, readonly) NSArray<NSDictionary<NSString*,MMModelController*>*> *controllers;

@end

NS_ASSUME_NONNULL_END
