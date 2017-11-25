//
//  EditorialNotes.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditorialNotes : NSObject
@property(nonatomic, copy) NSString *standard;
@property(nonatomic, copy) NSString *shortNotes; //short

-(instancetype)initWithDict:(NSDictionary*) dict;
+(instancetype)editorialNotesWithDict:(NSDictionary*) dict;
@end
