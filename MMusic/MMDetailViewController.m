//
//  MMDetailViewController.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <JGProgressHUD.h>
#import <Masonry.h>
#import <MJRefresh.h>
#import <MediaPlayer/MediaPlayer.h>

#import "MPMusicPlayerController+ResourcePlaying.h"
#import "MMDetailViewController.h"
#import "MMCloseButton.h"
#import "UIButton+BlockButton.h"

#import "MMDetailHeadView.h"
#import "SongCell.h"
#import "MMSongListData.h"
#import "MMDetaiData.h"
#import "Resource.h"
#import "Song.h"

@interface MMDetailViewController ()<UITableViewDelegate, DetailDataSourceDelegate>
@property(nonatomic, strong) MMCloseButton *closeButton;
@property(nonatomic, strong) UITableView *tableView;
//@property(nonatomic, assign) CGFloat topOffset;
@property(nonatomic, strong) MMDetailHeadView *headView;

//data
@property(nonatomic, strong)Resource *resource;
//@property(nonatomic, strong)MMSongListData *resourceData;
@property(nonatomic, strong)MMDetaiData *detailData;
@end

static NSString *const reuseIdentifier = @"tableview cell id";
@implementation MMDetailViewController

- (instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
         _resource = resource;

        //_resourceData   = [[MMSongListData alloc] init];
        _closeButton    = [[MMCloseButton alloc] init];
        //头部视图(image 和 title)
        _headView = [[MMDetailHeadView alloc] initWithFrame:CGRectZero];
        _imageView = _headView.imageView;
        _titleLabel = _headView.label;

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:UIColor.whiteColor];
    [self.view.layer setCornerRadius:6.0f];
    [self.view.layer setMasksToBounds:YES];


    //添加子视图, 注意视图层次
    [self.view addSubview:_headView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.closeButton];


    //关闭视图
    [self.closeButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self delegateDismissViewController];
    }];

    //数据源
    self.detailData = [[MMDetaiData alloc] initWithTableView:_tableView resource:_resource cellIdentifier:reuseIdentifier delegate:self];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    UIView *superView = self.view;

    [self.headView  mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(superView);
        make.height.mas_equalTo(240);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);
    }];

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(8);
        make.right.mas_equalTo(superView).offset(-8);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];

    //布局完成,计算contentInset
    CGFloat offset = CGRectGetMaxY(_headView.frame)+8;
    [self.tableView setContentInset:UIEdgeInsetsMake(offset, 0, 0, 0)];
}

- (void)configureCell:(UITableViewCell *)cell object:(Song *)song withIndex:(NSUInteger)index{
    if ([cell isKindOfClass:[SongCell class]]) {
        [((SongCell*)cell) setSong:song withIndex:index];
    }
}


#pragma mark - <TableView Delegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[MainPlayer playSongs:[self.resourceData songList] startIndex:indexPath.row];
    [MainPlayer playSongs:self.detailData.songList startIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    //[cell setHighlighted:YES animated:YES];
    [cell setSelected:YES animated:YES];
}

#pragma mark - <scroll delegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat y = scrollView.contentOffset.y;
    CGFloat topOffset = scrollView.contentInset.top;
    //往下拉100点, 关闭视图
    if ( y < -(topOffset+100)) {
        //下拉一段距离  关闭VC
        [self delegateDismissViewController];
    }

    //向上滑, 移动头视图;
    if (y >= -(topOffset) && y <= 0) {
        //计算向上偏移多少点
        CGFloat offsetY = -topOffset - y; //(-topOffset) - y; 基于原始偏移与当前滚动点数;
        CGRect frame = self.headView.frame;
        frame.origin.y = offsetY;
        self.headView.frame = frame;
    }
}

#pragma mark - <Dismiss ViewController dlelegate>
- (void)delegateDismissViewController{
    if (self.disMissDelegate && [self.disMissDelegate respondsToSelector:@selector(detailViewControllerDidDismiss:)]) {
        [self.disMissDelegate detailViewControllerDidDismiss:self];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView registerClass:[SongCell class] forCellReuseIdentifier:reuseIdentifier];
        [_tableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]]; //透明白色, 看到后面的视图层
        [_tableView setRowHeight:44.0f];
    }
    return _tableView;
}

@end
