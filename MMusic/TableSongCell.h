//
//  TableSongCell.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/12.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Song;
@class SongManageObject;

NS_ASSUME_NONNULL_BEGIN

@interface TableSongCell : UITableViewCell
@property(nonatomic,strong,readonly)UIImageView *artworkView;
@property(nonatomic,strong,readonly)UILabel *nameLabel;
@property(nonatomic,strong,readonly)UILabel *artistLabel;

- (void)configureForSong:(Song*)song;
- (void)configureForSongManageObject:(SongManageObject*)songMO;

@end

NS_ASSUME_NONNULL_END
