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
@property(nonatomic, copy) NSString  *next;
@property(nonatomic, copy) NSString  *href;

@property(nonatomic, strong) NSArray<Resource*> *data;
@property(nonatomic, strong) NSArray *errors;

@property(nonatomic, strong) NSDictionary *results;
@property(nonatomic, strong) NSDictionary *meta;

@end
