//
//  Album.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//


#import "Album.h"
#import "Artwork.h"
#import "EditorialNotes.h"


@implementation Album

//+(instancetype)instanceWithDict:(NSDictionary *)dict{
//    return [[self alloc] initWithDict:dict];
//}
+(NSDictionary *)mj_objectClassInArray{
    return @{@"genreNames":@"NSString"};
}

//-(instancetype)initWithDict:(NSDictionary *)dict{
//    if(self = [super init]){
//        [self mj_setKeyValues:dict];
//    }
//    return self;
//}

@end
