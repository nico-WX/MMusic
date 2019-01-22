//
//  AlbumDetailCell.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/22.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlbumDetailCell : UITableViewCell
@property(nonatomic,strong,readonly)Song *song;
- (void)setSong:(Song*)song withIndex:(NSUInteger)index;
@end

NS_ASSUME_NONNULL_END
