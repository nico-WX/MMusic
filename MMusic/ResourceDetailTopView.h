//
//  ResourceDetailTopView.h
//  MMusic
//
//  Created by Magician on 2017/12/31.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Playlist;
@class Album;

@interface ResourceDetailTopView : UIView
@property(nonatomic, strong) Album *album;
@property(nonatomic, strong) Playlist *playlist;
@end
