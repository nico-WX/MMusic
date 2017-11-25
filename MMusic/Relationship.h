//
//  Relationship.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Relationship : NSObject

@property(nonatomic, copy) NSString *href;
@property(nonatomic, copy) NSString *next;

@property(nonatomic, strong) NSArray *data;
@property(nonatomic, strong) NSDictionary *meta;

+(instancetype)relationshipWithDict:(NSDictionary*) dict;
-(instancetype)initWithDict:(NSDictionary*) dict;
@end
