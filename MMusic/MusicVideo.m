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

@implementation MusicVideo

@synthesize relationships = _relationships;

+(NSDictionary *)mj_objectClassInArray{
    return @{@"previews":@"Preview"};
}
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        [self mj_setKeyValues:[dict valueForKey:JSONAttributesKey]];
    }
    return self;
}


+ (instancetype)instanceWithResource:(Resource *)resource{
    return [[self alloc] initWithResource:resource];
}
- (instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
        [self mj_setKeyValues:resource.attributes];
        self.identifier = resource.identifier;
        self.type = resource.type;
        self.attributes = resource.attributes;
        self.href = resource.href;
        self.meta = resource.meta;
    }
    return self;
}
@end
