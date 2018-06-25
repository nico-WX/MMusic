//
//  AlbumsCollectionCell.m
//  MMusic
//
//  Created by Magician on 2018/6/17.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "AlbumsCollectionCell.h"
#import "Album.h"
#import "Artwork.h"

@implementation AlbumsCollectionCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //[self.artworkView setFrame:self.bounds];

        self.artworkView.frame = ({
            CGFloat x = 0;
            CGFloat y = 0;
            CGFloat w = CGRectGetWidth(frame);
            CGFloat h = w;
            CGRectMake(x, y, w, h);
        });

        self.nameLabel.frame = ({
            CGFloat x = 0;
            CGFloat y = CGRectGetMaxY(self.artworkView.frame);
            CGFloat w = CGRectGetWidth(frame);
            CGFloat h = CGRectGetHeight(frame) - y;
            CGRectMake(x, y, w, h);
        });

        [self prepareForReuse];
    }
    return self;
}
-(void)prepareForReuse{
    [super prepareForReuse];
}
//
//-(void)drawRect:(CGRect)rect{
//
//    CGFloat w = CGRectGetWidth(rect);
//    CGFloat h = w;
//
//}
//

@end
