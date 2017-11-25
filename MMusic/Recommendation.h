//
//  Recommendation.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Resource;

@interface Relationships :NSObject
@property(nonatomic, strong) NSArray<Resource*> *contents;
@property(nonatomic, strong) NSArray<Resource*> *recommendations;

@end

@interface Attributes : NSObject
@property(nonatomic, assign) Boolean isGroupRecommendation;
@property(nonatomic, strong) id title;
@property(nonatomic, strong) id reason;

@property(nonatomic, strong) NSArray<NSString*> *resourceTypes;
@property(nonatomic, copy) NSString *nextUpdateDate;

@end

@interface Recommendation : NSObject
@property(nonatomic, copy) NSString *identifier; //id
@property(nonatomic, copy) NSString *next;
@property(nonatomic, copy) NSString *href;
@property(nonatomic, copy) NSString *type;

@property(nonatomic, strong) Relationships *relationships;

@property(nonatomic, strong) Attributes *attributes;

@end
