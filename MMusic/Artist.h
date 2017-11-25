//
//  Artist.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EditorialNotes;

@interface Artist : NSObject
@property(nonatomic, strong) NSArray<NSString*> *genreNames;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

-(instancetype)initWithDict:(NSDictionary*) dict;
+(instancetype)artistWithDict:(NSDictionary*) dict;
@end
