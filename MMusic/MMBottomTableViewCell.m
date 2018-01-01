//
//  MMBottomTableViewCell.m
//  MMusic
//
//  Created by Magician on 2017/12/10.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMBottomTableViewCell.h"
#import <UIImageView+WebCache.h>
#import "Artwork.h"
#import "NSObject+Tool.h"
#import "Artist.h"

@interface MMBottomTableViewCell()
@property(nonatomic, strong) UIImageView *artisImageView;
@property(nonatomic, strong) UILabel     *artisLabel;
@property(nonatomic, strong) UILabel     *songLabel;
@property(nonatomic, strong) UIButton    *button;

@end

@implementation MMBottomTableViewCell

- (void)drawRect:(CGRect)rect{

    self.artisLabel.text = self.song.artistName;
    self.songLabel.text  = self.song.name;

    //添加歌手头像
    [self setupArtisImageViewWithRect:rect];

    //添加歌曲title
    [self setupSongLabelWidthRect:rect];
    //添加歌手title
    [self setupArtisLabelWidthRect:rect];
    //添加操作按钮(添加到播放列表等)
    [self setupButtonWithRect:rect];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
- (void)dealloc{
    self.song = nil;
}
- (void)setSong:(Song *)song{
    if (_song != song) {
        _song = song;
        //更新信息
        [self setNeedsDisplay];
    }
}
-(UIImageView *)artisImageView{
    if (!_artisImageView) {
        _artisImageView = [[UIImageView alloc] init];
    }
    return _artisImageView;
}
-(UILabel *)songLabel{
    if (!_songLabel) {
        _songLabel = [[UILabel alloc] init];
    }
    return _songLabel;
}
-(UILabel *)artisLabel{
    if (!_artisLabel) {
        _artisLabel = [[UILabel alloc] init];
    }
    return _artisLabel;
}

#pragma mark 添加歌手头像
- (void)setupArtisImageViewWithRect:(CGRect) rect{
    //frame
    CGFloat iX = rect.origin.x + 2;  //左边增加距离
    CGFloat iY = rect.origin.y;
    CGFloat iH = rect.size.height;
    CGFloat iW = iH;
    CGRect imageRect = CGRectMake(iX, iY, iW, iH);

    //头像View
    self.artisImageView.frame = imageRect;
    [self.artisImageView.layer setCornerRadius:4];
    [self.artisImageView.layer setMasksToBounds:YES];
    [self.contentView addSubview:self.artisImageView];

    //data
    NSString *imageStr = self.song.artwork.url;
    imageStr = [self stringReplacingOfString:imageStr height:iH width:iW];
    NSURL *url = [NSURL URLWithString:imageStr];
    [self.artisImageView sd_setImageWithURL:url];
}

#pragma mark 歌曲Title
- (void)setupSongLabelWidthRect:(CGRect) rect{
    //frame
    CGFloat sX = CGRectGetMaxX(self.artisImageView.frame) + 2;
    CGFloat sY = rect.origin.y;
    CGFloat sH = (rect.size.height/3) *2;
    CGFloat sW = rect.size.width * 0.8;
    CGRect labRect = CGRectMake(sX, sY, sW, sH);

    //songTitle Label
    self.songLabel.frame = labRect;
    [self.contentView addSubview:self.songLabel];

    //data
    self.songLabel.text = self.song.name;
}

#pragma mark 歌手Label
- (void)setupArtisLabelWidthRect:(CGRect) rect{
    //Frame
    CGFloat aX = CGRectGetMaxX(self.artisImageView.frame)+2;
    CGFloat aY = CGRectGetMaxY(self.songLabel.frame)+10;
    CGFloat aW = rect.size.width *0.6;
    CGFloat aH = CGRectGetHeight(self.songLabel.frame) - rect.size.height;
    CGRect aRect = CGRectMake(aX, aY, aW, aH);

    //Label
    self.artisLabel.frame = aRect;
    [self.contentView addSubview:self.artisLabel];

    //Font
    self.artisLabel.font = [UIFont fontWithName:@"Helvetica" size:9.0];
    [self.artisLabel setTextColor:[UIColor lightGrayColor]];
    self.artisLabel.text = self.song.artistName;
}

- (void)setupButtonWithRect:(CGRect) rect{

}

@end
