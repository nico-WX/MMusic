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

#import "SongCell.h"
#import "MMSongListData.h"
#import "Resource.h"
#import "Song.h"

@interface MMDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) MMCloseButton *closeButton;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, assign) CGFloat topOffset;

//data
@property(nonatomic, strong)Resource *resource;
@property(nonatomic, strong)MMSongListData *resourceData;
@end

static NSString *const reuseIdentifier = @"tableview cell id";
@implementation MMDetailViewController

- (instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
         _resource = resource;

        _resourceData   = [[MMSongListData alloc] init];
        _closeButton    = [[MMCloseButton alloc] init];
        _imageView      = [[UIImageView alloc] init];
        _titleLabel     = [[UILabel alloc] init];

        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:MainColor];

        //添加子视图, 注意视图层次 &
        [self.view addSubview:_imageView];
        [self.view addSubview:_titleLabel];
        [self.view addSubview:_tableView];
        [self.view addSubview:_closeButton];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view setBackgroundColor:UIColor.whiteColor];
    [self.view.layer setCornerRadius:6.0f];
    [self.view.layer setMasksToBounds:YES];


    [_titleLabel setText:[self.resource.attributes valueForKey:@"name"]];
    NSString *path = [self.resource.attributes valueForKeyPath:@"artwork.url"];
    [_imageView setImageWithURLPath:path];

    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
    [hud.textLabel setText:@"loading"];
    [hud showInView:self.tableView animated:YES];
    [hud setPosition:JGProgressHUDPositionTopCenter];

    [self.resourceData resourceDataWithResource:self.resource completion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [hud removeFromSuperview];
                [self.tableView reloadData];
            }else{
                [hud.textLabel setText:@"加载超时.."];
                [hud dismissAfterDelay:2 animated:YES];
            }
        });
    }];

    //代理关闭
    [self.closeButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        [self delegateDismissViewController];
    }];
}


- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    UIView *superView = self.view;
    __weak typeof(self) weakSelf = self;

    // 约束
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(8);
        make.centerX.mas_equalTo(superView);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];

    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.imageView.mas_bottom);
        make.left.right.mas_equalTo(superView);
        make.height.mas_equalTo(40);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);
    }];

    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(8);
        make.right.mas_equalTo(superView).offset(-8);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];

    //布局完成,确定 tablView content 向下偏移量
    ({
        self.topOffset = CGRectGetMaxY(self.titleLabel.frame)+8;
        [self.tableView setContentInset:UIEdgeInsetsMake(self.topOffset, 0, 0, 0)];
        [self.tableView setContentOffset:CGPointMake(0, -self.topOffset)];
    });
}


#pragma mark - <TableView dataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.resourceData songCount];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongCell *cell = (SongCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    [cell setSong:[self.resourceData songWithIndex:index] withIndex:index];
    return cell;
}

#pragma mark - <TableView Delegate>
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [MainPlayer playSongs:[self.resourceData songList] startIndex:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [cell setSelected:YES animated:YES];
}

#pragma mark - <scroll delegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat y = scrollView.contentOffset.y;

    if ( y < -(self.topOffset+100)) {
        //下拉一段距离  关闭VC
        [self delegateDismissViewController];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView registerClass:[SongCell class] forCellReuseIdentifier:reuseIdentifier];
        [_tableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
        [_tableView setRowHeight:44.0f];
    }
    return _tableView;
}

@end
