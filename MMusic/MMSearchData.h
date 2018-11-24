//
//  MMSearchData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/24.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ResponseRoot;
@interface MMSearchData : NSObject
@property(nonatomic, assign, readonly) NSInteger sectionCount;
@property(nonatomic, assign, readonly) NSInteger hintsCount;

- (NSString*)hintTextForIndex:(NSInteger)index;
//- (NSInteger)numberOfSection:(NSInteger)section;
//- (NSString*)titleOfSection:(NSInteger)section;

- (void)searchHintForTerm:(NSString*)term complectin:(void(^)(MMSearchData* searchData))completion;
- (void)searchDataForTemr:(NSString*)term completion:(void(^)(MMSearchData* searchData))completion;

@end

NS_ASSUME_NONNULL_END
