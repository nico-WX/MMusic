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

//- (NSInteger)numberOfSection:(NSInteger)section;
//- (NSString*)titleOfSection:(NSInteger)section;

- (void)searchHintForTerm:(NSString*)term complectin:(void(^)(NSArray<NSString*>* hints))completion;
- (void)searchDataForTemr:(NSString*)term completion:(void(^)(MMSearchData*))completion;

@end

NS_ASSUME_NONNULL_END
