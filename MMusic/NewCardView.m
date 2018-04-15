//
//  NewCardView.m
//  myMas
//
//  Created by Magician on 2018/4/3.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "NewCardView.h"
#import "Masonry.h"

@interface NewCardView()

@property(nonatomic, strong) UIView *midView;
@end

@implementation NewCardView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];

        //实例 视图
        self.midView = UIView.new;
        self.titleLabel = UILabel.new;
        self.contentView = UIView.new;

        //确定视图间关系
        [self addSubview:self.midView];
        [self addSubview:self.titleLabel];
        [self.midView addSubview:self.contentView];

        self.midView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];

        __weak typeof(self) weakSelf = self;
        //约束

        //顶部标签
        self.titleLabel.backgroundColor = UIColor.greenColor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            //位置
            make.left.equalTo(weakSelf.mas_left).offset(20);
            make.top.equalTo(weakSelf.mas_top);

            //计算标签大小
            CGFloat w = CGRectGetWidth(frame)*0.4;
            CGFloat h = 30;
            CGSize size = CGSizeMake(w, h);
            make.size.mas_equalTo(size);

            //圆角
            self.titleLabel.layer.cornerRadius = h/2;
            self.titleLabel.layer.masksToBounds = YES;
        }];

        //中间层覆盖在底层上, 并在顶部留距离
        self.midView.layer.cornerRadius = 8.0f;
        self.midView.layer.masksToBounds = YES;
        [self.midView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(10, 0, 0, 0));
        }];

        UIEdgeInsets padding = UIEdgeInsetsMake(10, 0, 0, 0);
        //内容容器视图
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(padding.top);
            make.left.equalTo(self.midView.mas_left);

            make.right.equalTo(self.midView.mas_right);
            make.bottom.equalTo(self.midView.mas_bottom);
        }];

        self.contentView.layer.cornerRadius =8.0f;
        self.contentView.layer.masksToBounds = YES;
        //最后再添加一次, 移动到最上层
        [self addSubview:self.titleLabel];
    }
    return self;
}

@end
