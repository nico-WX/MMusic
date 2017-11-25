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
    Log(@">>>>>>>>>");
    [self.contentView setBackgroundColor:[UIColor brownColor]];
    [self.layer setCornerRadius:20];
    [self.layer setMasksToBounds:YES];
}
@end
