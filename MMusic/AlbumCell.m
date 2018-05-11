//
//  ChartsCell.m
//  MMusic
//
//  Created by Magician on 2018/4/3.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "AlbumCell.h"

@implementation AlbumCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){

        //设置大小, 因为请求图片大小时, 需要知道专辑封面视图大小
        //图片高度  等于宽度,  形成正方形
        CGFloat artworkW = CGRectGetWidth(frame);
        CGFloat artworkH = artworkW;
        self.artworkView.frame = CGRectMake(0, 0, artworkW, artworkH);

        //title
        CGFloat y = CGRectGetMaxY(self.artworkView.frame);
        CGFloat titleH = CGRectGetHeight(frame)- CGRectGetHeight(self.artworkView.frame);
        CGFloat titleW = CGRectGetWidth(frame);
        self.titleLabel.frame = CGRectMake(0, y, titleW, titleH);
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    CGFloat corner = 6.0f;
    self.layer.cornerRadius = corner;
    self.layer.masksToBounds = YES;

    //设置title
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.layer.cornerRadius = corner;
    self.titleLabel.layer.masksToBounds = YES;

}

//- (void)layoutSubviews{
//    //图片高度  等于宽度,  形成正方形
//    CGFloat artworkH = CGRectGetWidth(self.bounds);
//    //layout
//    UIView *superview = self.contentView;
//    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(superview.mas_top);
//        make.left.equalTo(superview.mas_left);
//        make.right.equalTo(superview.mas_right);
//        make.height.equalTo(@(artworkH));
//    }];
//
//    __weak typeof(self) weakSelf = self;
//    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.artworkView.mas_bottom);
//        make.left.equalTo(superview.mas_left);
//        make.right.equalTo(superview.mas_right);
//        make.bottom.equalTo(superview.mas_bottom);
//    }];
//}

@end
