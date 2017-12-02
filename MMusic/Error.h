//
//  Error.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"


@interface Error : MMObject
@property(nonatomic, copy) NSString *identifier ; //id
@property(nonatomic, copy) NSString *about;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSString *code;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *detail;

@property(nonatomic, strong) NSDictionary *meta;
@property(nonatomic, strong) NSDictionary *source;

@end
