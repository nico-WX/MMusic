//
//  ImageCacheManager.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/19.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ImageCacheManager.h"

@interface ImageCacheManager ()
@property(nonatomic,strong)NSCache<NSString*,UIImage*> *imageCache;
@end


@implementation ImageCacheManager

- (void)fetchImageWithURL:(NSString *)urlString completion:(void (^)(UIImage * _Nnull))completion{
    NSURL *url = [NSURL URLWithString:urlString];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"图片下载失败");
            mainDispatch(^{
                completion(nil);
            });
        }else{
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                [self.imageCache setObject:image forKey:urlString];
                mainDispatch(^{
                    completion(image);
                });
            }else{
                mainDispatch(^{
                    completion([UIImage new]);
                });
            }
        }
    }] resume];
}

- (UIImage*)cachedImageForURL:(NSString*)url{
    return [self.imageCache objectForKey:url];
}
-(NSCache *)imageCache{
    if (!_imageCache) {
        _imageCache = [[NSCache alloc] init];
        _imageCache.name = @"image cache manager";
        _imageCache.countLimit = 30;
        _imageCache.totalCostLimit = 20 * 1024 * 1024; //20M
    }
    return _imageCache;
}

@end
