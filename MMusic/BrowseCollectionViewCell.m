//
//  BrowseCollectionViewCell.m
//  MMusic
//
//  Created by Magician on 2017/11/14.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <SDWebImage/UIImageView+WebCache.h>
#import "BrowseCollectionViewCell.h"
#import "Artwork.h"
#import "Resource.h"
#import "Song.h"

@interface BrowseCollectionViewCell()
@property(nonatomic, weak) UILabel *titleLabel;
@property(nonatomic, weak) UIImageView *imageView;
@end

@implementation BrowseCollectionViewCell

-(void)drawRect:(CGRect)rect{
    [self.contentView setBackgroundColor:[UIColor redColor]];
    //[self.contentView.layer setCornerRadius:8];
    [self.layer setCornerRadius:12];
    [self.layer setMasksToBounds:YES];

    //添加ImageView
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    Song *song = [Song songWithDict:self.resource.attributes];
    NSString *withString = [NSString stringWithFormat:@"460x460"]; //@"%dx%d",(int)rect.size.width,(int)rect.size.width];

    NSString *urlString = [NSString stringWithString:song.artwork.url];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"{w}x{h}" withString:withString];
    NSURL *imageURL = [NSURL URLWithString:urlString];
    [imageView sd_setImageWithURL:imageURL placeholderImage:nil];

    //Label设置
    CGFloat labWidth = rect.size.width/2;
    CGFloat labHeight= 66;
    CGRect labRect = rect;
    labRect.size = CGSizeMake(labWidth, labHeight);

    UILabel *titleLable = [[UILabel alloc] initWithFrame:labRect];
    [titleLable setCenter:self.contentView.center];
    titleLable.alpha = 0.5;
    //文字居中
    [titleLable setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:titleLable];
    self.titleLabel = titleLable;
    [self.titleLabel setText:song.name];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
}

@end
