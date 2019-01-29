//
//  LibraryDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN



@interface LibraryDataSource : NSObject

- (instancetype)initWithQuery:(MPMediaQuery*)query;

@end

NS_ASSUME_NONNULL_END
