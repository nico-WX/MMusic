//
//  SongManageObject.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "ManagedObject.h"
#import "Song.h"


NS_ASSUME_NONNULL_BEGIN

@interface SongManageObject : ManagedObject

//+ (instancetype)insertIntoContext:(NSManagedObjectContext*)context withSong:(Song*)song;
/**内部注册在主托管上下文中*/
- (instancetype)initWithSong:(Song *)song;

@property(nonatomic, strong) NSDate *addDate;

@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *artistName;
@property(nonatomic, copy) NSString *composerName;
@property(nonatomic, copy) NSString *contentRating;
@property(nonatomic, copy) NSString *isrc;  

@property(nonatomic, copy) NSString *movementName;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *releaseDate;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *workName;  

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
