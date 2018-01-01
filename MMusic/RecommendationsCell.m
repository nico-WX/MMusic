//
//  RecommendationsCell.m
//  MMusic
//
//  Created by Magician on 2017/11/24.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "NSObject+Tool.h"
#import "RecommendationsCell.h"
#import "Playlist.h"
#import "Artwork.h"
#import "Album.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RecommendationsCell()
@end

@implementation RecommendationsCell

-(void)drawRect:(CGRect)rect{
    Log(@">>3");
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.layer setCornerRadius:5];
    [self.layer setMasksToBounds:YES];

    //添加ImageView
    [self setupImageViewWithRect:rect];
}

//添加Image View 到Cell 上
- (void)setupImageViewWithRect:(CGRect)rect{

    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithFrame:rect];
    [self.contentView addSubview:activity];
    [activity startAnimating];
    [activity setColor:[UIColor greenColor]];
    [activity setHidesWhenStopped:YES];

    //第一个资源
    Resource *firstResource = _recommendation.relationships.contents.data.firstObject;
    //组类型推荐  包含着另一个推荐子集合, 向内部索取;
    if (!firstResource) {
        firstResource = _recommendation.relationships.recommendations.data.firstObject.relationships.contents.data.firstObject;
    }
    NSDictionary *firstDict = [firstResource.attributes objectForKey:@"artwork"];
    Artwork *artwork = [Artwork instanceWithDict:firstDict];
    NSString *artURL = artwork.url;

    int h = (int)rect.size.height;
    int w = (int)rect.size.width;
    artURL = [self stringReplacingOfString:artURL height:h width:w];   //替换URL参数 5倍宽高大小
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];

    [imageView sd_setImageWithURL:[NSURL URLWithString:artURL] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [activity stopAnimating];
    }];
    [self.contentView addSubview:imageView];

    // Title值
    Attributes *arttibutes = _recommendation.attributes;
    self.title = [arttibutes.title objectForKey:@"stringForDisplay"];
    if (!self.title) {
        self.title = @"Apple 推荐";
    }

    //添加标签 显示Title
    CGFloat lW = rect.size.width;
    CGFloat lH = rect.size.height / 4;  // 1/4 Cell 高度
    CGFloat lX = rect.origin.x;
    CGFloat lY = CGRectGetMaxY(rect) - lH; //rect.origin.y +lH*3;
    CGRect labelRect = CGRectMake(lX, lY, lW, lH);
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    label.alpha = 0.7;
    label.text = self.title;
    if (self.title) {
        [label setBackgroundColor:[UIColor blackColor]];
    }
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:label];
}

@end
