//
//  Preview.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Artwork;
@interface Preview : NSObject
@property(nonatomic, copy) NSString  *url;
@property(nonatomic, strong) Artwork *artwork;

-(instancetype)initWithDict:(NSDictionary*) dict;
+(instancetype)previewWithDict:(NSDictionary*) dict;
@end
