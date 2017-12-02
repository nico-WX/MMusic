//
//  RecommendationsCell.m
//  MMusic
//
//  Created by Magician on 2017/11/24.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "RecommendationsCell.h"

@implementation RecommendationsCell

-(void)drawRect:(CGRect)rect{
    [self.contentView setBackgroundColor:[UIColor brownColor]];
    [self.layer setCornerRadius:10];
    [self.layer setMasksToBounds:YES];
}
@end
