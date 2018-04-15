//
//  TodayCollectionViewCell.m
//  MMusic
//
//  Created by Magician on 2017/12/26.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "TodayCell.h"
#import "NSObject+Tool.h"

#import "Resource.h"
#import "Artwork.h"

@interface TodayCell()

@end

@implementation TodayCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 8.0f;
        self.layer.masksToBounds = YES;

        //增加专辑封面
        self.artworkView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:self.artworkView];
        [self.contentView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.90 alpha:1.0]];
    }
    return self;
}

@end
