//
//  Storefront.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Storefront.h"

@implementation StorefrontAttributes
@end

@implementation Storefront
@synthesize attributes = _attributes;

- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super initWithDict:dict]) {
        _attributes = [StorefrontAttributes instanceWithDict:dict];
    }
    return self;
}

@end
