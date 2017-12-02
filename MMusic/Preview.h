//
//  Preview.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"
@class Artwork;
@interface Preview : MMObject
@property(nonatomic, copy) NSString  *url;
@property(nonatomic, strong) Artwork *artwork;

@end
