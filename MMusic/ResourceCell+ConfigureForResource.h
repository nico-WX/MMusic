//
//  ResourceCell+ConfigureForResource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/11.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ResourceCell.h"
@class MPMediaItem;
@class MPMediaItemCollection;
NS_ASSUME_NONNULL_BEGIN

@interface ResourceCell (ConfigureForResource)
- (void)configureForResource:(Resource*)resource;
- (void)configureForMediaItem:(MPMediaItem*)mediaItem;
- (void)configureForMPMediaItemCollection:(MPMediaItemCollection*)itemCollection;
@end

NS_ASSUME_NONNULL_END
