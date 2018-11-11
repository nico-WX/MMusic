//
//  DataStore+Rating.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/10.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "DataStore.h"

NS_ASSUME_NONNULL_BEGIN


@interface DataStore (Rating)

//catalog &library
- (void)addRatingToCatalogWith:(NSString*)identifier type:(RTRatingType)type callBack:(void(^)(BOOL succeed))callBack;
- (void)deleteRatingForCatalogWith:(NSString*)identifier type:(RTRatingType)type callBack:(void(^)(BOOL succeed))callBack;
- (void)requestRatingForCatalogWith:(NSString*)identifier type:(RTRatingType)type callBack:(void(^)(BOOL isRating))callBack;
@end

NS_ASSUME_NONNULL_END
