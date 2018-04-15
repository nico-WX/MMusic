//
//  Artist.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"

@class EditorialNotes;
/**艺人*/
@interface Artist : MMObject
@property(nonatomic, strong) NSArray<NSString*> *genreNames;
@property(nonatomic, strong) EditorialNotes *editorialNotes;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

@end
