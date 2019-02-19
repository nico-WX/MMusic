//
//  ImageCacheManager.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/19.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCacheManager : NSObject

//缓存加载
- (UIImage*)cachedImageForURL:(NSString*)url;
//异步加载
- (void)fetchImageWithURL:(NSString*)url completion:(void(^)(UIImage *image))completion;
@end

