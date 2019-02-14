//
//  DataManager.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SongManageObject.h"
#import "SearchHistoryManageObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject

+ (instancetype)shareDataManager;

- (void)addItem:(Song*)song;
- (void)deleteItem:(Song*)song;
- (void)fetchAllSong:(void(^)(NSArray<SongManageObject*>* songArray))completion;

- (void)addSearchHistory:(NSString*)term;
- (void)deleteSearchHistory:(SearchHistoryManageObject*)searchHistoryMO;

@end

NS_ASSUME_NONNULL_END
