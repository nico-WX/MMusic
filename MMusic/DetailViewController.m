//
//  MMDetailViewController.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import <Masonry.h>

#import "MPMusicPlayerController+ResourcePlaying.h"

#import "DetailViewController.h"
#import "CloseButton.h"
#import "UIButton+BlockButton.h"

#import "MMDetailHeadView.h"
#import "SongCell.h"

#import "ResourceDetailDataSource.h"
#import "Resource.h"
#import "Song.h"

@interface DetailViewController ()<UITableViewDelegate, ResourceDetailDataSourceDelegate>
@property(nonatomic, strong) CloseButton *closeButton;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) MMDetailHeadView *headView;

//data
@property(nonatomic, strong)Resource *resource;
@property(nonatomic,strong)ResourceDetailDataSource *dataSource;
@end

static CGFloat headHeight = 240;
static NSString *const reuseIdentifier = @"tableview cell id";
@implementation DetailViewController

- (instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
         _resource  = resource;
        _closeButton = [[CloseButton alloc] init];
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
    _dataSource = [[ResourceDetailDataSource alloc] initWithTableView:_tableView
                                                           identifier:reuseIdentifier
                                                             resource:_resource
                                                             delegate:self];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    UIView *superView = self.view;
    [self.headView  mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(superView);
        make.height.mas_equalTo(headHeight);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);
    }];

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(superView).inset(8);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
}

#pragma mark dataSourceDelegate
- (void)configureCell:(SongCell *)cell object:(Song *)song atIndex:(NSUInteger)index{
    [cell setSong:song withIndex:index];
//
//    if ([cell isKindOfClass:[SongCell class]]) {
//        [((SongCell*)cell) setSong:song withIndex:index];
//    }
}


#pragma mark - <TableView Delegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MainPlayer playSongs:self.dataSource.songLists startIndex:indexPath.row];
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - <scroll delegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat yOffset = scrollView.contentOffset.y;
    //往下拉100点, 关闭视图
    if ( yOffset < -(headHeight+100)) {
        [self delegateDismissViewController];
        return;
    }

    //头部视图跟随滚动
    CGRect newFrame = self.headView.frame;
    newFrame.origin.y = -(yOffset+headHeight);
    self.headView.frame = newFrame;
}

#pragma mark - <Dismiss ViewController dlelegate>
- (void)delegateDismissViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
//    if (self.disMissDelegate && [self.disMissDelegate respondsToSelector:@selector(detailViewControllerDidDismiss:)]) {
//        [self.disMissDelegate detailViewControllerDidDismiss:self];
//    }else{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView registerClass:[SongCell class] forCellReuseIdentifier:reuseIdentifier];
        [_tableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]]; //透明白色, 看到后面的视图层
        [_tableView setRowHeight:44.0f];
        [_tableView setContentInset:UIEdgeInsetsMake(headHeight, 0, 0, 0)];
    }
    return _tableView;
}

@end
