//
//  Artist.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//


#import "Artist.h"

@implementation Artist

@synthesize relationships = _relationships;

+(NSDictionary *)mj_objectClassInArray{
    return @{@"genreNames":@"NSString"};
}

@end
