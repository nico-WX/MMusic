//
//  ResponseRoot.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"
@class Resource;

@interface ResponseRoot : MMObject
/**分页UR(子路径)L*/
@property(nonatomic, copy) NSString  *next;
/**当前资源地址(子路径)*/
@property(nonatomic, copy) NSString  *href;
/**结果对象*/
@property(nonatomic, strong) NSArray<Resource*> *data;
@property(nonatomic, strong) NSArray *errors;

@property(nonatomic, strong) NSDictionary *results;
@property(nonatomic, strong) NSDictionary *meta;

@end
