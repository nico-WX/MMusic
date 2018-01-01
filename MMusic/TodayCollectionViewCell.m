//
//  TodayCollectionViewCell.m
//  MMusic
//
//  Created by Magician on 2017/12/26.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "TodayCollectionViewCell.h"
#import "NSObject+Tool.h"

#import "Resource.h"
#import "Artwork.h"

@interface TodayCollectionViewCell()
@property(nonatomic, weak) UIImageView *artworkImageView;
@property(nonatomic, strong) NSArray<Resource*> *data;
@end

@implementation TodayCollectionViewCell

-(void)drawRect:(CGRect)rect{
    [self.contentView setBackgroundColor:[UIColor grayColor]];
    [self.layer setCornerRadius:10];
    [self.layer setMasksToBounds:YES];

    //先处理 内部子资源集合,
    [self dataWithResource:self.resource];
    //增加专辑封面
    [self setupArtwirkImageViewWithRect:rect];

    //
    [self setupTitleLabelWithRect:rect];
}

#pragma mark 增加专辑封面 到Cell中
-(void)setupArtwirkImageViewWithRect:(CGRect) rect{

    UIImageView *artworkView = [[UIImageView alloc] initWithFrame:rect];
    [self.contentView addSubview:artworkView];
    self.artworkImageView = artworkView;

    //URL
    Resource *resource = [[NSSet setWithArray:self.data] anyObject];   //随机一个 设置封面
    Artwork *art = [Artwork instanceWithDict:[resource.attributes objectForKey:@"artwork"]];
    NSString *path = [self stringReplacingOfString:art.url height:rect.size.height width:rect.size.width];
    NSURL  *imageURL = [NSURL URLWithString:path];

    //加载指示器  及加载URL 图片
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:rect];
    [self.contentView addSubview:indicator];
    [indicator setHidesWhenStopped:YES];
    [indicator startAnimating];
    [artworkView sd_setImageWithURL:imageURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [indicator stopAnimating];
    }];
}

#pragma mark 添加Title
-(void)setupTitleLabelWithRect:(CGRect)rect{
    //添加到专家封面上
    CGFloat h = 40;
    CGFloat w = rect.size.width;
    CGFloat x = rect.origin.x;
    CGFloat y = CGRectGetMaxY(rect) - h;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
    [self.contentView addSubview:titleLabel];

    NSDictionary *dict = self.resource.attributes;
    dict = [dict objectForKey:@"title"];
    NSString *title = [dict objectForKey:@"stringForDisplay"];
    if (!title) {
        title = @"Apple 推荐";
    }
    self.title = title;
    [titleLabel setText:title];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setBackgroundColor:[UIColor blackColor]];
    [titleLabel setAlpha:0.7];

}
#pragma mark 解析资源的子集合 到data 数组中
-(void)dataWithResource:(Resource*) resource{
    NSDictionary *temp = resource.relationships;
    if ([temp objectForKey:@"contents"]) {  //非组合推荐
        temp = [temp objectForKey:@"contents"];
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in [temp objectForKey:@"data"]) {
            [array addObject:[Resource instanceWithDict:dict]];
        }
        _data = array;
    }else{  //组合推荐
        temp = [temp objectForKey:@"recommendations"];
        for (NSDictionary *dict in [temp objectForKey:@"data"]) {
            [self dataWithResource:[Resource instanceWithDict:dict]];   //递归
        }
    }
}

@end
