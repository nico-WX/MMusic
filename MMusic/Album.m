//
//  Album.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Album.h"

@implementation Album

@synthesize relationships = _relationships;

+(NSDictionary *)mj_objectClassInArray{
    return @{@"genreNames":@"NSString"};
}
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:[dict valueForKey:JSONAttributesKey]];
    }
    return self;
}
@end

