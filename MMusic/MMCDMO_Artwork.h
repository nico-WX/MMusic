//
//  MMCDMO_Artwork.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/28.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import <CoreData/CoreData.h>
#import "MMManagedObject.h"

@class Artwork;
NS_ASSUME_NONNULL_BEGIN

@interface MMCDMO_Artwork : MMManagedObject <NSCoding>
@property(nonatomic,assign) NSInteger width;
@property(nonatomic,assign) NSInteger height;

@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *bgColor;
@property(nonatomic, copy) NSString *textColor1;
@property(nonatomic, copy) NSString *textColor2;
@property(nonatomic, copy) NSString *textColor3;
@property(nonatomic, copy) NSString *textColor4;

- (instancetype)initArtwork:(Artwork*)artwork;
@end

NS_ASSUME_NONNULL_END
