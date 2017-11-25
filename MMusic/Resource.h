//
//  Resource.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Relationship;

@interface Resource : NSObject
/**资源id*/
@property(nonatomic, copy) NSString *identifier;  // id
/**资源类型*/
@property(nonatomic, copy) NSString *type;
/**获取的资源的子路径*/
@property(nonatomic, copy) NSString *href;

/**具体的资源*/
@property(nonatomic, strong) NSDictionary *attributes;
/**关于请求或者响应的后台参数*/
@property(nonatomic, strong) NSDictionary *meta;

/**有关系的资源*/
@property(nonatomic, strong) Relationship *relationships;

-(instancetype)initWithDict:(NSDictionary*) dict;
+(instancetype)resourceWithDict:(NSDictionary*) dict;
@end
