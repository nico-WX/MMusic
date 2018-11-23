//
//  ResourceData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/23.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Resourcel;

/**请求歌曲列表*/
@interface ResourceData : NSObject
@property(nonatomic, assign, readonly) NSInteger count;
@property(nonatomic, strong, readonly) NSArray<Song*> *allSong;

- (Song*)songWithIndex:(NSInteger)index;
- (void)loadNextPageWithComplection:(void(^)(ResourceData*))completion;
- (void)resourceDataWithResource:(Resource*)resource completion:(void(^)(ResourceData* resourceData))completion;
@end

NS_ASSUME_NONNULL_END
