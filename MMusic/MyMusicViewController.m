//
//  MyMusicViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/8.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "MyMusicViewController.h"
#import "MMSearchTopPageCell.h"
#import "MMLibraryData.h"

#import "LibraryPlaylist.h"


@interface MyMusicViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIPageViewControllerDelegate>
@property(nonatomic, strong) UICollectionView *topPageView;
@property(nonatomic, strong)UIPageViewController *pageViewController;
@property(nonatomic, strong)MMLibraryData *librarData;
@end

static NSString *reuseId = @"top cell identifier";
@implementation MyMusicViewController


- (instancetype)init{
    if (self = [super init]) {
        _librarData = [[MMLibraryData alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"我的音乐"];

    [self.view addSubview:self.topPageView];
    [self.view addSubview:self.pageViewController.view];

    [self.librarData requestAllLibraryResource:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [self.topPageView reloadData];

                UIViewController *vc = [self.librarData viewControllerAtIndex:0];
                [self.pageViewController setViewControllers:@[vc,] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                [self.topPageView selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            }
        });
    }];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    __weak typeof(self) weakSelf = self;
    CGFloat topOffset = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    [self.topPageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.navigationController.navigationBar.mas_bottom);
        make.left.right.mas_equalTo(weakSelf.view);
        make.height.mas_equalTo(44.0f);
    }];

    [self.pageViewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topPageView.mas_bottom);
        make.left.bottom.right.mas_equalTo(weakSelf.view);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.librarData.results.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MMSearchTopPageCell *cell = (MMSearchTopPageCell*)[collectionView dequeueReusableCellWithReuseIdentifier:reuseId forIndexPath:indexPath];
    [cell.titleLabel setText:[self.librarData titleWhitIndex:indexPath.row]];
    return cell;
}

- (UICollectionView *)topPageView{
    if (!_topPageView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setItemSize:CGSizeMake(100, 44.0f)];

        _topPageView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_topPageView registerClass:[MMSearchTopPageCell class] forCellWithReuseIdentifier:reuseId];
        [_topPageView setDelegate:self];
        [_topPageView setDataSource:self];
        [_topPageView setBackgroundColor:UIColor.whiteColor];
    }
    return _topPageView;
}

- (UIPageViewController *)pageViewController{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];

        [_pageViewController setDelegate:self];
        [_pageViewController setDataSource:self.librarData];
        [_pageViewController.view setBackgroundColor:UIColor.whiteColor];
    }
    return _pageViewController;
}





-(void)addPlaylists{
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"新建播放列表" message:@"" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertCtr addAction:action];
    

    [alertCtr addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"输入播放列表名称";
    }];
    [self presentViewController:alertCtr animated:YES completion:nil];
}




@end
