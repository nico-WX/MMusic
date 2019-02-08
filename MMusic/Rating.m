//
//  Rating.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/3.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "Rating.h"

@implementation Rating
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:[dict valueForKey:JSONAttributesKey]];
    }
    return self;
}
@end
