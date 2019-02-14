//
//  SongManageObject.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "ManagedObject.h"

@class Song;
NS_ASSUME_NONNULL_BEGIN

@interface SongManageObject : ManagedObject

//+ (instancetype)insertIntoContext:(NSManagedObjectContext*)context withSong:(Song*)song;
/**内部注册在主托管上下文中*/
+ (instancetype)insertSong:(Song*)song;
- (instancetype)initWithSong:(Song *)song;

@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *artistName;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;

@property(nonatomic, strong) NSNumber *durationInMillis;

@property(nonatomic, strong, readonly) NSDate *addDate;
@property(nonatomic, strong) NSDictionary *artwork;
@property(nonatomic, strong) NSDictionary *playParams;
@end

NS_ASSUME_NONNULL_END
