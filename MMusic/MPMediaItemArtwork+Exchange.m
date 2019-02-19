//
//  MPMediaItemArtwork+Exchange.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/7.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MPMediaItemArtwork+Exchange.h"
#import "MPMusicPlayerController+ResourcePlaying.h"
#import "Song.h"
#import "Artwork.h"

//#import <objc/message.h>

@implementation MPMediaItemArtwork (Exchange)

- (void)loadArtworkImageWithSize:(CGSize)size completion:(void (^)(UIImage * _Nonnull))completion{
    UIImage *image = [self imageWithSize:size];
    if (image) {
        mainDispatch(^{
            completion(image);
        });
    }else{
        //通过identifier 加载Song*  获取路径

        [MainPlayer nowPlayingSong:^(Song * _Nonnull song) {
            NSString *urlStr = song.artwork.url;
            urlStr = [urlStr stringReplacingImageURLSize:size];
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:urlStr] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                mainDispatch(^{
                    completion([UIImage imageWithData:data]);
                });
            }] resume];
        }];
    }
}
@end
