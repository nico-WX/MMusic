//
//  MMLikeSong.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "Song.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMLikeSong : NSManagedObject

/**艺人名称*/
@property(nonatomic, copy) NSString *artistName;

/**内容评级*/
@property(nonatomic, copy) NSString *contentRating;
/**国际标准录音编码*/
@property(nonatomic, copy) NSString *isrc;

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *releaseDate;
@property(nonatomic, copy) NSString *url;


@property(nonatomic, strong) NSDictionary /*Artwork*/ *artwork;

@property(nonatomic, strong) NSDictionary *playParams;

@property(nonatomic, strong) NSNumber *durationInMillis;

@property(nonatomic, strong) NSArray/*<Preview*>*/ *previews;



@property(nonatomic, strong) Song *song;

@end

NS_ASSUME_NONNULL_END
