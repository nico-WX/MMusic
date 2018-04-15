//
//  HeadCell.m
//  MMusic
//
//  Created by Magician on 2018/3/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "HeadCell.h"

@interface HeadCell()
@end

@implementation HeadCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        [self addSubview:self.titleLabel];
        [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:28.0]];
    }
    return self;
}

- (void)layoutSubviews{
    self.titleLabel.frame = ({
        CGRect rect = self.bounds;
        CGRect labelRect = CGRectMake(rect.origin.x+8, rect.origin.y, rect.size.width-8, rect.size.height);
        labelRect;
    });
}
@end
