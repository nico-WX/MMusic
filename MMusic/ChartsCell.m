//
//  ChartsCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/16.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ChartsCell.h"
#import "ChartsSubContentCell.h"
#import "ChartsSubContentDataSource.h"
#import "ChartsSongCell.h"
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
        _showMoreButton = [[UIButton alloc] init];

        _layout = [[UICollectionViewFlowLayout alloc] init];
        [_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [_layout setMinimumLineSpacing:1];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        [_collectionView registerClass:[ChartsSubContentCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setBackgroundColor:UIColor.whiteColor];

        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_showMoreButton];
        [self.contentView addSubview:_collectionView];

        // text set
        [_titleLabel setTextColor:[UIColor darkTextColor]];
        UIFont *font = [UIFont systemFontOfSize:[UIFont labelFontSize]];
        [_titleLabel setFont:font];

        [_showMoreButton setTitleColor:MainColor forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets padding = UIEdgeInsetsMake(40, 0, 1, 0);
    __weak typeof(self) weakSelf = self;

    [_collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(weakSelf).insets(padding);
    }];

    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(200);
        // 顶部空间Y轴居中布置
        CGFloat centerY = CGRectGetMidY(self.contentView.bounds);
        centerY = (-centerY) + padding.top/2;
        make.centerY.mas_equalTo(centerY);

        make.left.mas_equalTo(weakSelf).inset(4);
    }];
    [_showMoreButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(weakSelf);
        make.width.mas_equalTo(100);
        make.bottom.mas_equalTo(weakSelf.collectionView.mas_top);
    }];


    //不同的类型, 设置不同的大小与cell 类型
    Resource *resource = _chart.data.firstObject;
    if ([resource.type isEqualToString:@"songs"]) {
        CGFloat h = CGRectGetHeight(_collectionView.bounds)/4;
        [_layout setItemSize:CGSizeMake(400,h)];
        [_layout setMinimumInteritemSpacing:0];
        [_collectionView registerClass:[ChartsSongCell class] forCellWithReuseIdentifier:identifier];
    }else if ([resource.type isEqualToString:@"music-videos"]) {
        CGFloat w = CGRectGetWidth(_collectionView.bounds) * 0.8;
        CGFloat h = CGRectGetHeight(_collectionView.bounds);//w * 0.8;
        [_layout setItemSize:CGSizeMake(w, h)];
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
        [_showMoreButton setTitle:@"Show More" forState:UIControlStateNormal];
        BOOL displayButton = chart.next ? NO : YES; //如果没有更多, 隐藏按钮
        [_showMoreButton setHidden:displayButton];

        _contentDataSource = [[ChartsSubContentDataSource alloc] initWithChart:chart
                                                                collectionView:_collectionView
                                                               reuseIdentifier:identifier
                                                                      delegate:self];
    }
}

#pragma mark -delegate
- (void)configureCell:(UICollectionViewCell *)cell object:(Resource *)resource{
    //[cell.contentView setBackgroundColor:UIColor.grayColor];
    if ([cell isKindOfClass:[ChartsSubContentCell class]]) {
        ChartsSubContentCell *subCell = (ChartsSubContentCell*)cell;
        [subCell setResource:resource];
    }
}


@end
