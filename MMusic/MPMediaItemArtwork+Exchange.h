//
//  MPMediaItemArtwork+Exchange.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/7.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPMediaItemArtwork (Exchange)

- (void)loadArtworkImageWithSize:(CGSize)size  completion:(void(^)(UIImage* image))completion;
@end

NS_ASSUME_NONNULL_END
