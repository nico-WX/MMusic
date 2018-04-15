//
//  PlayControllerView.m
//  MMusic
//
//  Created by Magician on 2018/4/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "PlayControllerView.h"
#import <Masonry.h>

@implementation PlayControllerView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//
//
//}

-(void)layoutSubviews{
    CGSize size = CGSizeMake(CGRectGetWidth(self.bounds)/3,CGRectGetHeight(self.bounds));
    __weak typeof(self) weakSelf = self;

    [self.previous mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.size.mas_equalTo(size);
    }];

    [self.play mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.previous.mas_right);
        make.size.mas_equalTo(size);
    }];

    [self.next  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.mas_top);
        make.left.mas_equalTo(weakSelf.play.mas_right);
        make.size.mas_equalTo(size);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.brownColor;
        self.previous = UIButton.new;
        self.play = UIButton.new;
        self.next = UIButton.new;

        [self.previous setImage:[UIImage imageNamed:@"skip-previous"] forState:UIControlStateNormal];
        [self.play setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.next setImage:[UIImage imageNamed:@"skip-next"] forState:UIControlStateNormal];

        [self addSubview:self.previous];
        [self addSubview:self.play];
        [self addSubview:self.next];

        self.previous.backgroundColor = UIColor.grayColor;
        self.play.backgroundColor = UIColor.grayColor;
        self.next.backgroundColor = UIColor.grayColor;
    }
    return self;
}


@end
