//
//  Chart.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//


#import "MMObject.h"
@class Resource;
@interface Chart : MMObject
/**排行榜名称*/
@property(nonatomic, copy) NSString *name;
/**排行榜类型*/
@property(nonatomic, copy) NSString *chart;
/**排行榜URL*/
@property(nonatomic, copy) NSString *href;
/**(Optional) 排行榜下一页URL*/
@property(nonatomic, copy) NSString *next;
/**请求的类型 内容*/
@property(nonatomic, strong) NSArray<Resource*> *data;;

@end
