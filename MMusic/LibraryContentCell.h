//
//  LibraryContentCell.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/2.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPMediaItem;

NS_ASSUME_NONNULL_BEGIN

@interface LibraryContentCell : UICollectionViewCell
@property(nonatomic)MPMediaItem *item;
@end

NS_ASSUME_NONNULL_END
