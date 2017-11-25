//
//  Song.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Song.h"
#import "Artwork.h"
//#import "Artwork.h";
//#import "EditorialNotes.h";
//#import "PlayParameters.h";
//#import "Preview.h";

#import <MJExtension.h>

@implementation Song

-(instancetype)initWithDict:(NSDictionary *)dict{
    if(self = [super init]){
        [self mj_setKeyValues:dict];
    }
    return self;
}

+(instancetype)songWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
+(NSDictionary *)mj_objectClassInArray{
    return @{@"previews":@"Preview"};
}
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{};
}
@end
