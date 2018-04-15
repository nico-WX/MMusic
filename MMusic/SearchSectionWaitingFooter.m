//
//  SearchSectionWaitingFooter.m
//  MMusic
//
//  Created by Magician on 2018/4/10.
//  Copyright © 2018年 com.😈. All rights reserved.
//


#import "SearchSectionWaitingFooter.h"
#import <Masonry.h>

@implementation SearchSectionWaitingFooter


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code

    UIEdgeInsets  padding = UIEdgeInsetsMake(0, 50, 0, 50);
    __weak typeof(self) wealSelf = self;
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(wealSelf.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(wealSelf.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(wealSelf.mas_right).with.offset(-padding.right);
        make.bottom.mas_equalTo(wealSelf.mas_bottom).with.offset(padding.bottom);
    }];
    [self.moreButton setTitle:@"more..." forState:UIControlStateNormal];
    [self.moreButton setTitleColor:UIColor.grayColor forState:UIControlStateNormal];

}

-(instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.moreButton = UIButton.new;
        [self.contentView addSubview:self.moreButton];
    }
    return self;
}

@end
