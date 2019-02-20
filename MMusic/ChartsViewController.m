//
//  ChartsViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/15.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ChartsViewController.h"

#import "ResourceCollectionCell.h"
#import "DetailViewController.h"
#import "ChartsCell.h"

#import "ChartsDataSource.h"
#import "ChartsSubContentDataSource.h"

#import "ResourceDetailViewController.h"
#import "Resource.h"
#import "Song.h"

#import "MPMusicPlayerController+ResourcePlaying.h"
#import "ShowAllViewController.h"

@interface ChartsViewController ()<UITableViewDelegate,DataSourceDelegate,UICollectionViewDelegate>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)ChartsDataSource *dataSource;
@end

static NSString *const identifier = @"cell reuseIdentifier";
@implementation ChartsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];

    _dataSource = [[ChartsDataSource alloc] initWithTableView:self.tableView
                                                   identifier:identifier
                                            sectionIdentifier:nil
                                                     delegate:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_tableView setFrame:self.view.bounds];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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
-(void)configureCell:(ChartsCell*)cell item:(Chart*)item{
    [cell setChart:item];
    cell.collectionView.delegate = self;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    __weak typeof(self) weakSelf = self; //UIContr通过联合持有Block
    [cell.showAllButton handleControlEvent:UIControlEventTouchUpInside withBlock:^{
        ShowAllViewController *all = [[ShowAllViewController alloc] initWithChart:item];
        [all setTitle:item.name];
        [weakSelf.navigationController pushViewController:all animated:YES];
    }];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if ([cell isKindOfClass:[ResourceCollectionCell class]]) {
        Resource *resource = [((ResourceCollectionCell*)cell) resource];

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



