//
//  ResourceCollectionViewCell.m
//  MMusic
//
//  Created by Magician on 2018/6/17.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "ResourceCollectionViewCell.h"
#import "Artwork.h"

@implementation ResourceCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        // 绘制时,通过识别不同的资源模型,重新布局子视图
        //init var
        _artworkView    = [[UIImageView alloc] initWithFrame:self.bounds];
        _nameLabel      = [[UILabel alloc] init];
        _artistLabel    = [[UILabel alloc] init];

        //set var
        [_artistLabel setTextAlignment:NSTextAlignmentCenter];
        [_artistLabel setAdjustsFontSizeToFitWidth:YES];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [_nameLabel setAdjustsFontSizeToFitWidth:YES];

        //add subview
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_artworkView];
        [self.contentView addSubview:_nameLabel];

        //self set
        [self setBackgroundColor:UIColor.whiteColor];
        [self.contentView setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];
        [self prepareForReuse];
    }
    return self;
}

-(void)prepareForReuse{
    //置空 旧资源
    self.artworkView.image  = nil;
    self.artistLabel.text   = nil;
    self.nameLabel.text     = nil;

//    self.album          = nil;
//    self.activites      = nil;
//    self.appleCurator   = nil;
//    self.artist         = nil;
//    self.curator        = nil;
//    self.musicVideo     = nil;
//    self.playlist       = nil;
//    self.song           = nil;
//    self.station        = nil;

    [super prepareForReuse];
}

-(void)drawRect:(CGRect)rect{
    CGFloat artworkH = CGRectGetWidth(rect);
    UIView *superview = self.contentView;
    __weak typeof(self) weakSelf = self;
    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        make.height.mas_equalTo(artworkH);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artworkView.mas_bottom);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        make.bottom.mas_equalTo(superview.mas_bottom);
    }];

    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero);
    }];
}

@end
