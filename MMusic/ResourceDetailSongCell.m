//
//  ResourceDetailSongCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/22.
//  Copyright © 2019 com.😈. All rights reserved.
//


#import <Masonry.h>
#import "ResourceDetailSongCell.h"
#import "Song.h"
#import "Artwork.h"

@interface ResourceDetailSongCell ()
@end

@implementation ResourceDetailSongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    //替换样式
    if (self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier]) {
        [self.detailTextLabel setTextColor:UIColor.grayColor];
        [self.imageView.layer setCornerRadius:2];
        [self.imageView.layer setMasksToBounds:YES];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    CGFloat h = CGRectGetHeight(self.contentView.bounds)-8;
    CGFloat w = h;
    CGRect frame = self.imageView.frame;
    frame.size = CGSizeMake(w, h);// {w,h};
    [self.imageView setFrame:frame];

//    UIEdgeInsets insets = UIEdgeInsetsMake(2, 2, 2, 2);
//    UIView *superView = self.contentView;
//    __weak typeof(self) weakSelf = self;
//     CGFloat w = CGRectGetHeight(superView.bounds) - (insets.top+insets.bottom);
//    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.bottom.mas_equalTo(superView).insets(insets);
//        make.width.mas_equalTo(w);
//    }];
}

- (void)setSong:(Song *)song{
    if (_song != song) {
        _song = song;
        [self.textLabel setText:song.name];
        [self.detailTextLabel setText:song.artistName];
        [self.imageView setImageWithURLPath:song.artwork.url];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
