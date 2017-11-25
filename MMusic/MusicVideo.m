//
//  MusicVideo.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

//@class Artwork;
//@class EditorialNotes;
//@class PlayParameters;
//@class Preview;

#import "MusicVideo.h"
#import "Artwork.h"
#import "Preview.h"
#import "EditorialNotes.h"
#import "PlayParameters.h"

#import <MJExtension.h>

@implementation MusicVideo
-(instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        [self mj_setKeyValues:dict];
    }
    return self;
}
+(instancetype)musicVideoWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
+(NSDictionary *)mj_objectClassInArray{
    return @{@"previews":@"Preview"};
}
@end
