//
//  PlayParameters.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayParameters : NSObject
@property(nonatomic, copy) NSString *identifier; //id
@property(nonatomic, copy) NSString *kind;

+(instancetype)playParametersWithDict:(NSDictionary*) dict;
-(instancetype)initWithDict:(NSDictionary*) dict;
@end
