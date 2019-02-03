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

#import <objc/message.h>
#import <UIImageView+WebCache.h>

@implementation MPMediaItemArtwork (Exchange)
//+ (void)load{
//    Method old = class_getInstanceMethod(self, @selector(imageWithSize:));
//    Method new = class_getInstanceMethod(self, @selector(myImageWithSize:));
//    method_exchangeImplementations(old, new);
//}
//- (UIImage*)myImageWithSize:(CGSize)size{
//    UIImage *image = [self myImageWithSize:size];  //调用原来的实现, 如果能返回image  就不用另外请求image
//    if (!image) {
//        //NSString *imageURL  = MainPlayer.nowPlayingSong.artwork.url;   // nowPlayingSong == null;
//        //image = self// [self imageFromURL:imageURL withImageSize:size];
//    }
//    return image;
//}

- (void)loadArtworkImageWithSize:(CGSize)size completion:(void (^)(UIImage * _Nonnull))completion{
    UIImage *image = [self imageWithSize:size];
    if (image) {
        completion(image);
    }else{
        [MainPlayer nowPlayingSong:^(Song * _Nonnull song) {
            NSString *urlStr = song.attributes.artwork.url;
            urlStr = [urlStr stringReplacingImageURLSize:size];
            //NSLog(@"load artwork image url = %@",urlStr);

            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIImageView new] sd_setImageWithURL:[NSURL URLWithString:urlStr]
                                            completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                completion(image);
                                            }];
            });
        }];
    }
}
@end
