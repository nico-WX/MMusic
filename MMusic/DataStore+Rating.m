//
//  DataStore+Rating.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/10.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "DataStore+Rating.h"

@implementation DataStore (Rating)


- (void)addRatingToCatalogWith:(NSString*)identifier type:(RTRatingType)type callBack:(void(^)(BOOL succeed))callBack{
    [MusicKit.new.library addRatingToCatalogWith:identifier type:type responseHandle:^(NSDictionary *json, NSHTTPURLResponse *response) {
        NSInteger code = response.statusCode/100;
        if (callBack) {
            callBack(code==2 ? YES : NO);
        }
    }];
}
- (void)deleteRatingForCatalogWith:(NSString*)identifier type:(RTRatingType)type callBack:(void(^)(BOOL succeed))callBack{
    [MusicKit.new.library deleteRatingForCatalogWith:identifier type:type responseHandle:^(NSDictionary *json, NSHTTPURLResponse *response) {
        NSInteger code = response.statusCode/100;
        if (callBack) {
            callBack(code==2 ? YES : NO);
        }
    }];
}
- (void)requestRatingForCatalogWith:(NSString*)identifier type:(RTRatingType)type callBack:(void(^)(BOOL isRating))callBack{
    [MusicKit.new.library requestRatingForCatalogWith:identifier type:type responseHandle:^(NSDictionary *json, NSHTTPURLResponse *response) {
        NSInteger code = response.statusCode/100;
        if (callBack) {
            callBack(code==2 ? YES : NO);
        }
    }];
}

@end
