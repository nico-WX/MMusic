//
//  MusicVideo.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MusicVideo.h"

@implementation MusicVideoRelationships
@end

@implementation MusicVideoAttributes

+(NSDictionary *)mj_objectClassInArray{
    return @{@"previews":@"Preview"};
}

@end

@implementation MusicVideo
@synthesize attributes = _attributes;
@synthesize relationships = _relationships;

@end
