//
//  RecommendationsCell.m
//  MMusic
//
//  Created by Magician on 2017/11/24.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "NSObject+Serialization.h"
#import "RecommendationsCell.h"
#import "Playlist.h"
#import "Artwork.h"
#import "Album.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RecommendationsCell()

@end

@implementation RecommendationsCell
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}
-(void)drawRect:(CGRect)rect{
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.layer setCornerRadius:5];
    [self.layer setMasksToBounds:YES];

    //添加ImageView
    [self setupImageViewWithRect:rect];
}

//添加Image View 到Cell 上
- (void)setupImageViewWithRect:(CGRect)rect{

    //第一个资源
    Resource *firstResource = _recommendation.relationships.contents.data.firstObject;

    //组类型推荐  包含着另一个推荐子集合, 向内部索取;
    if (!firstResource) {
        firstResource = _recommendation.relationships.recommendations.data.firstObject.relationships.contents.data.firstObject;
    }
    NSDictionary *firstDict = [firstResource.attributes objectForKey:@"artwork"];
    Artwork *artwork = [Artwork instanceWithDict:firstDict];
    NSString *artURL = artwork.url;

    //图片大小设置为5倍的Cell 大小
    int h = (int)rect.size.height;
    int w = (int)rect.size.width;
    artURL = [self stringReplacingOfString:artURL height:h width:w];
    Log(@"URLPATH:%@",artURL);
    NSURL *imageURL = [NSURL URLWithString:artURL];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView sd_setImageWithURL:imageURL];
    [self addSubview:imageView];

    // Title值
    Attributes *arttibutes = _recommendation.attributes;
    NSString *title = [arttibutes.title objectForKey:@"stringForDisplay"];

    //添加标签 显示Title
    CGFloat lW = rect.size.width;
    CGFloat lH = rect.size.height / 4;  // 1/4 Cell 高度
    CGFloat lX = rect.origin.x;
    CGFloat lY = CGRectGetMaxY(rect) - lH; //rect.origin.y +lH*3;
    CGRect labelRect = CGRectMake(lX, lY, lW, lH);
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    label.alpha = 0.7;
    label.text = title;
    if (title) {
        [label setBackgroundColor:[UIColor blackColor]];
    }
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:label];
}

//- (void)setRecommendation:(Recommendation *)recommendation{
//    if (_recommendation != recommendation) {
//        _recommendation = recommendation;
//    }
//    NSDictionary *tempDict;
//    //= [_recommendation.relationships.contents ];
////    if (!tempDict) {
////        tempDict = [_recommendation.relationships objectForKey:@"recommendations"];
////    }
//    NSMutableArray *tempArray = [NSMutableArray array];
//    for (NSDictionary *dict in [tempDict objectForKey:@"data"]) {
//        Resource *resource = [Resource instanceWithDict:dict];
//        [tempArray addObject:resource];
//    }
//    self.resourceArray = tempArray;
//}

@end
