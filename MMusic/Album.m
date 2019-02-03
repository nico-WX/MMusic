//
//  Album.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Album.h"

@implementation Album

@synthesize attributes = _attributes;
@synthesize relationships = _relationships;
@end


@implementation AlbumAttributes

+(NSDictionary *)mj_objectClassInArray{
    return @{@"genreNames":@"NSString"};
}
@end
