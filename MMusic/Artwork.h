//
//  Artwork.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"

@interface Artwork : MMObject
@property(nonatomic,assign) NSInteger width;
@property(nonatomic,assign) NSInteger height;

@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *bgColor;
@property(nonatomic, copy) NSString *textColor1;
@property(nonatomic, copy) NSString *textColor2;
@property(nonatomic, copy) NSString *textColor3;
@property(nonatomic, copy) NSString *textColor4;

- (NSDictionary*)dictionaryValue;
@end
