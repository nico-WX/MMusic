//
//  Catalog+Search.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/11.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "Catalog.h"

NS_ASSUME_NONNULL_BEGIN

@interface Catalog (Search)

/**
 搜索目录资源

 @param term    搜索字段
 @param handle  数据回调
 */
- (void)searchForTerm:(NSString*)term callBack:(RequestCallBack)handle;

/**
 搜索字段提示

 @param term    搜索提示关键字段
 @param handle  数据回调
 */
- (void)searchHintsForTerm:(NSString*)term callBack:(RequestCallBack)handle;
@end

NS_ASSUME_NONNULL_END
