//
//  MMSearchData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/24.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMModelController.h"



NS_ASSUME_NONNULL_BEGIN

@class ResponseRoot;

@interface MMSearchData : MMModelController
@property(nonatomic, strong, readonly)NSArray<NSString*> *searchHinstory;   // 搜索历史
@property(nonatomic, strong, readonly)NSArray<NSDictionary<NSString*,ResponseRoot*>*> *searchResults; //搜索结果数据
@property(nonatomic, strong, readonly)NSArray<NSString*> *searchHints;    //搜索提示数据


/**
 搜索指定文本

 @param term 搜索文本
 @param completion 消息接受者
 */
- (void)searchDataForTemr:(NSString*)term completion:(void(^)(BOOL success))completion;

@end

@interface MMSearchData (Hints)
/**
 获取搜索提示数据

 @param term 关键字
 @param completion 消息接收者
 */
- (void)searchHintForTerm:(NSString*)term complectin:(void(^)(BOOL success))completion;

@end



NS_ASSUME_NONNULL_END
