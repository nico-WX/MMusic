//
//  AppleCurator.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>


@class Artwork;
@class EditorialNotes;

@interface AppleCurator : NSObject
@property(nonatomic, strong) Artwork *artwork;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

+(instancetype)appleCuratorWithDict:(NSDictionary*) dict;
-(instancetype)initWithDict:(NSDictionary*) dict;
@end
