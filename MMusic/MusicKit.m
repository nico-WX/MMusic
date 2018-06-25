//
//  MusicKit.m
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "MusicKit.h"

@implementation MusicKit
-(instancetype)init{
    if (self = [super init]) {
        _api = [[API alloc] init];
    }
    return self;
}
@end
