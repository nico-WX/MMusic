//
//  Error.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Source: NSObject
@property(nonatomic, copy)   NSString *parameter;
@property(nonatomic, strong) NSDictionary  *pointer;

- initWithDict:(NSDictionary*) dict;
@end

@interface Error : NSObject
@property(nonatomic, copy) NSString *identifier ; //id
@property(nonatomic, copy) NSString *about;
@property(nonatomic, copy) NSString *status;
@property(nonatomic, copy) NSString *code;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *detail;

@property(nonatomic, strong) id  meta;
@property(nonatomic, strong) Source  *source;


- (instancetype)initWithDict:(NSDictionary*) dict;
+ (instancetype)errorWithDict:(NSDictionary*) dict;

@end
