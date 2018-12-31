//
//  MMCDMO_Song.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMManagedObject.h"
#import "Song.h"


NS_ASSUME_NONNULL_BEGIN

@interface MMCDMO_Song : MMManagedObject

/**内部注册在主托管上下文中*/
- (instancetype)initWithSong:(Song *)song;


/**艺人名称*/
@property(nonatomic, copy) NSString *artistName;
/**作家*/
@property(nonatomic, copy) NSString *composerName;
/**内容评级*/
@property(nonatomic, copy) NSString *contentRating;
/**国际标准录音编码*/
@property(nonatomic, copy) NSString *isrc;  

@property(nonatomic, copy) NSString *movementName; //
@property(nonatomic, copy) NSString *name;  //
@property(nonatomic, copy) NSString *releaseDate;   //
@property(nonatomic, copy) NSString *url;           //
@property(nonatomic, copy) NSString *workName;  //

@property(nonatomic, strong) NSDictionary *artwork;
@property(nonatomic, strong) NSDictionary  /*EditorialNotes*/ *editorialNotes; //
@property(nonatomic, strong) NSDictionary *playParams; //

@property(nonatomic, strong) NSNumber *durationInMillis; //
@property(nonatomic, strong) NSArray<NSString*> *genreNames; //
//@property(nonatomic, strong) NSArray/*<Preview*>*/ *previews;     //

@property(nonatomic, assign) int discNumber;
@property(nonatomic, assign) int movementCount;
@property(nonatomic, assign) int movementNumber;
@property(nonatomic, assign) int trackNumber;

@end

NS_ASSUME_NONNULL_END
