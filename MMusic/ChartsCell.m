//
//  ChartsCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ChartsCell.h"
#import "ResourceCollectionCell.h"
#import "ChartsSubContentDataSource.h"
#import "SongCollectionCell.h"
#import "Resource.h"
#import <Masonry.h>

@interface ChartsCell()<ChartsSubContentDataSourceDelegate>
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) ChartsSubContentDataSource *contentDataSource;
@property(nonatomic, strong) UICollectionViewFlowLayout *layout;
@end

static NSString *const identifier = @"collectionView cell id";
@implementation ChartsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc] init];
        _showAllButton = [[UIButton alloc] init];

        _layout = [[UICollectionViewFlowLayout alloc] init];
        [_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [_layout setMinimumLineSpacing:6];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        [_collectionView registerClass:[ResourceCollectionCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setBackgroundColor:UIColor.whiteColor];
        [_collectionView setContentInset:UIEdgeInsetsMake(0, 8, 0, 8)];

        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_showAllButton];
        [self.contentView addSubview:_collectionView];

        // text set
        [_titleLabel setTextColor:[UIColor darkTextColor]];
        [_titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22.0]];

        [_showAllButton setTitleColor:MainColor forState:UIControlStateNormal];
        [_showAllButton setTitle:@"全部 >" forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets padding = UIEdgeInsetsMake(40, 0, 1, 0); // 顶部40 留给title 与 "全部"按钮
    __weak typeof(self) weakSelf = self;
    UIView *superView = self.contentView;
    [_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView).insets(padding);
    }];

    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        // 顶部空间Y轴居中布置
        CGFloat centerY = CGRectGetMidY(weakSelf.contentView.bounds);
        centerY = (-centerY) + padding.top/2;
        make.centerY.mas_equalTo(centerY);
        make.left.mas_equalTo(weakSelf).inset(8);
    }];
    [_showAllButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(weakSelf);
        make.width.mas_equalTo(100);
        make.bottom.mas_equalTo(weakSelf.collectionView.mas_top);
    }];


    //不同的类型, 设置不同的大小与cell 类型
    Resource *resource = _chart.data.firstObject;
    if ([resource.type isEqualToString:@"songs"]) {
        CGFloat h = CGRectGetHeight(_collectionView.bounds)/4; //每列4行
        CGFloat w = CGRectGetWidth(_collectionView.bounds) -8; //
        [_layout setItemSize:CGSizeMake(w,h)];
        [_layout setMinimumInteritemSpacing:0];
        [_collectionView registerClass:[SongCollectionCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setPagingEnabled:YES];

    }else{
        CGFloat h = CGRectGetHeight(_collectionView.bounds);
        CGFloat w = h-40; // -60
        [_layout setItemSize:CGSizeMake(w, h)];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - setter/getter
- (void)setChart:(Chart *)chart{
    if (_chart != chart) {
        _chart = chart;

        [_titleLabel setText:chart.name];
        BOOL displayButton = chart.next ? NO : YES; //如果没有更多, 隐藏按钮
        [_showAllButton setHidden:displayButton];
        _contentDataSource = [[ChartsSubContentDataSource alloc] initWithChart:chart
                                                                collectionView:_collectionView
                                                               reuseIdentifier:identifier
                                                                      delegate:self];
    }
}

#pragma mark -delegate
- (void)configureCell:(UICollectionViewCell *)cell object:(Resource *)resource{
    if ([cell isKindOfClass:[ResourceCollectionCell class]]) {
        ResourceCollectionCell *subCell = (ResourceCollectionCell*)cell;
        [subCell setResource:resource];
    }
}

@end
