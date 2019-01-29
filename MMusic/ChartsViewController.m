//
//  ChartsViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/15.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ChartsViewController.h"
#import "ChartsSubContentCell.h"
#import "MMDetailViewController.h"
#import "ChartsCell.h"

#import "ChartsDataSource.h"
#import "ChartsSubContentDataSource.h"

#import "ResourceDetailViewController.h"
#import "Resource.h"
#import "Song.h"

#import "MPMusicPlayerController+ResourcePlaying.h"
#import "ShowAllViewController.h"

@interface ChartsViewController ()<UITableViewDelegate,ChartsDataSourceDelegate,UICollectionViewDelegate>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)ChartsDataSource *dataSource;

@end

static NSString *const identifier = @"cell reuseIdentifier";
@implementation ChartsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];

    _dataSource =[[ChartsDataSource alloc] initWithTableView:_tableView reuseIdentifier:identifier delegate:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_tableView setFrame:self.view.bounds];
}

#pragma mark - getter
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[ChartsCell class] forCellReuseIdentifier:identifier];
        [_tableView setDelegate:self];
    }
    return _tableView;
}

#pragma mark - ChartsDataSourceDelegate
-(void)configureCell:(UITableViewCell *)cell object:(Chart *)chart{
    if ([cell isKindOfClass:[ChartsCell class]]) {
        ChartsCell *chartsCell = (ChartsCell*)cell;
        [chartsCell setChart:chart];
        //tableViewCell 中的集合视图代理设置为self, 获取选中的数据, 入栈新的控制器;
        [chartsCell.collectionView setDelegate:self];
        [chartsCell setSelectionStyle:UITableViewCellSelectionStyleNone];

        __weak typeof(self) weakSelf = self; //UIContr通过联合持有Block
        [chartsCell.showAllButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
            ShowAllViewController *all = [[ShowAllViewController alloc] initWithChart:chart];
            [all setTitle:chart.name];
            [weakSelf.navigationController pushViewController:all animated:YES];
        }];
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ChartsSubContentCell class]]) {
        Resource *resource = [((ChartsSubContentCell*)cell) resource];

        //选中歌曲播放, 其他显示资源详细
        if ([resource.type isEqualToString:@"songs"]) {
            if ([collectionView.dataSource isKindOfClass:[ChartsSubContentDataSource class]]) {
                Chart *chart = ((ChartsSubContentDataSource*)collectionView.dataSource).chart;
                NSMutableArray<Song*> *songs = [NSMutableArray array];
                for (Resource *songRes in chart.data) {
                    [songs addObject:[Song instanceWithResource:songRes]];
                }
                [MainPlayer playSongs:songs startIndex:indexPath.row];
            }
        }else{
            ResourceDetailViewController *detail = [[ResourceDetailViewController alloc] initWithResource:resource];
            [self.navigationController pushViewController:detail animated:YES];
        }
    }
}
@end



