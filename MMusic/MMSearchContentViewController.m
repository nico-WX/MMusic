//
//  MMSearchContentViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MJRefresh.h>

#import "MPMusicPlayerController+ResourcePlaying.h"
#import "MMSearchContentViewController.h"

#import "MMDetailViewController.h"
#import "MMDetailPoppingAnimator.h"
#import "MMDetailPresentationController.h"

#import "MMSearchContentCell.h"
#import "MMSearchContentSongCell.h"
#import "MMSearchContentArtistsCell.h"
#import "MMSearchContentMusicVideosCell.h"

#import "NSURLRequest+CreateURLRequest.h"
#import "ResponseRoot.h"
#import "Song.h"
#import "MusicVideo.h"

// 使用分类 分割代码
@interface MMSearchContentViewController (protocal)<UICollectionViewDelegate, UICollectionViewDataSource,MMDetailViewControllerDelegate,UIViewControllerTransitioningDelegate>
@end


@interface MMSearchContentViewController ()

@property(nonatomic, strong) UICollectionView *collectionView;  //内容
@property(nonatomic, strong) NSString *type;    //内容类型: songs,albums,playlists,music-videos

//动画
@property(nonatomic, strong) MMDetailPoppingAnimator *animator;
@property(nonatomic, strong) MMDetailPresentationController *presentationController;
@end

static NSString *const cellID = @" cell reuse identifier";

@implementation MMSearchContentViewController

- (instancetype)initWithResponseRoot:(ResponseRoot *)responseRoot{
    if (self = [super init]) {
        _responseRoot = responseRoot;
        _type = responseRoot.data.firstObject.type; //资源类型
        _animator = [[MMDetailPoppingAnimator alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview:self.collectionView];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    UIView *superView = self.view;
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);//.insets(UIEdgeInsetsMake(0, 0, 8, 0));
    }];

}


- (UICollectionView *)collectionView{
    if (!_collectionView) {

        UIEdgeInsets padding = UIEdgeInsetsMake(8, 4, 0, 4);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layout setMinimumLineSpacing:padding.top];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];
        [_collectionView setContentInset:padding];  //内容左右偏移4, 翻页时看到分界线效果


        // 不同的类型注册不同的cell 及设置不同的大小
        ({
            CGFloat w = CGRectGetWidth(self.view.bounds) - (padding.left+padding.right); // 小于视图宽度
            CGFloat h = 0;

            if ([self.type isEqualToString:@"songs"]) {
                [_collectionView registerClass:[MMSearchContentSongCell class] forCellWithReuseIdentifier:cellID];
                h = 44;

            }else if ([self.type isEqualToString:@"music-videos"]) {
                [_collectionView registerClass:[MMSearchContentMusicVideosCell class] forCellWithReuseIdentifier:cellID];
                h = 80;
            }else{
                [_collectionView registerClass:[MMSearchContentCell class] forCellWithReuseIdentifier:cellID];
                h = 60;
            }

            [layout setItemSize:CGSizeMake(w, h)];
        });

        //底部加载更多
        if (_responseRoot.next) {
            _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                if (self.responseRoot.next) {
                    [self loadNextPageData];
                }else{
                    [self.collectionView.mj_footer endRefreshingWithNoMoreData];
                }
            }];
        }
    }
    return _collectionView;
}

 -(void) loadNextPageData{
     NSURLRequest *request = [NSURLRequest createRequestWithHref:self.responseRoot.next];
     [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {

         if ([json valueForKey:@"results"]) {
             json =[json valueForKeyPath:@"results"];
         }


  
         NSLog(@"json== %@",json);

         if (json) {
             //nextpage 加载 的数据
             __block ResponseRoot *root;
             [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                 root = [ResponseRoot instanceWithDict:obj];
             }];

             dispatch_async(dispatch_get_main_queue(), ^{

                 //添加前的最大下标
                 NSUInteger beforCount = self.responseRoot.data.count-1;
                 self.responseRoot.next = root.next;    //覆盖下一页地址
                 [self.responseRoot.data addObjectsFromArray:root.data];    //追加数据

                 //记录要刷新的cell下标
                 NSMutableArray<NSIndexPath*> *items = [NSMutableArray array];
                 for (int i = 0 ; i<root.data.count; i++) {
                     NSIndexPath *indexPath = [NSIndexPath indexPathForRow:++beforCount inSection:0];
                     [items addObject:indexPath];
                 }

                 [self.collectionView reloadData];                      //刷新数据源,再刷新cell
                 [self.collectionView reloadItemsAtIndexPaths:items];   //刷新最后添加的cell
                 [self.collectionView.mj_footer endRefreshing];
                 //滚动到倒数第二行 , 倒数第一行, 会不断触发加载下一页
                 NSIndexPath *indexPath = [items objectAtIndex:items.count-2];
                 [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
             });
         }else{
             dispatch_async(dispatch_get_main_queue(), ^{
                   [self.collectionView.mj_footer endRefreshingWithNoMoreData];
             });
         }
     }];
 }
@end


#pragma mark - 代理方法实现 分类

@implementation MMSearchContentViewController (protocal)

#pragma mark - <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.responseRoot.data.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    if ([cell isKindOfClass:MMSearchContentCell.class]) {
        ((MMSearchContentCell*)cell).resource = [self.responseRoot.data objectAtIndex:indexPath.row];
    }

    //选中背景
    UIView *view = [[UIView alloc] initWithFrame:cell.contentView.bounds];
    [view setBackgroundColor:UIColor.groupTableViewBackgroundColor];
    [view.layer setCornerRadius:cell.layer.cornerRadius];
    [view.layer setMasksToBounds:cell.layer.masksToBounds];
    [cell setSelectedBackgroundView:view];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if ([self.type isEqualToString:@"songs"]) {
        NSMutableArray<Song*> *songs = [NSMutableArray array];
        for (Resource *res in _responseRoot.data) {
            Song *song = [Song instanceWithResource:res];
            [songs addObject:song];
        }

        [MainPlayer playSongs:songs startIndex:indexPath.row];
    }else if ([self.type isEqualToString:@"music-videos"]) {
        NSMutableArray<MusicVideo*> *mvs = [NSMutableArray array];
        for (Resource *res in _responseRoot.data) {
            [mvs addObject:[MusicVideo instanceWithResource:res]];
        }
        [MainPlayer playMusicVideos:mvs startIndex:indexPath.row];
    }else{

        MMSearchContentCell *cell = (MMSearchContentCell*)[collectionView cellForItemAtIndexPath:indexPath];
        MMDetailViewController *detail = [[MMDetailViewController alloc] initWithResource:cell.resource];

        [detail setDisMissDelegate:self];
        [detail setTransitioningDelegate:self];
        [detail setModalPresentationStyle:UIModalPresentationCustom];

        [self.animator setStartFrame:cell.frame];
        [self presentViewController:detail animated:YES completion:nil];
    }
}

#pragma mark - <DetailViewControllerDelegate>
- (void)detailViewControllerDidDismiss:(MMDetailViewController *)detailVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <UIViewControllerTransitioningDelegate>
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    [self.animator setPresenting:YES];
    return self.animator;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    [self.animator setPresenting:NO];
    return self.animator;
}
-(UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    self.presentationController =[[MMDetailPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return self.presentationController;
}

@end
