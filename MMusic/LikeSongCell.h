//
//  LikeSongCell.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/10.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "SongCell.h"

@class SongManageObject;
@class MPMediaItem;
NS_ASSUME_NONNULL_BEGIN

@interface LikeSongCell : UITableViewCell
@property(nonatomic,strong)SongManageObject *songManageObject;
@property(nonatomic,strong)MPMediaItem *mediaItem;
@end

NS_ASSUME_NONNULL_END
