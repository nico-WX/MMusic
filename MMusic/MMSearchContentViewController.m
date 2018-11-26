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
#import "ResponseRoot.h"

#import "MMSearchContentCell.h"
#import "MMSearchContentSongCell.h"
#import "MMSearchContentArtistsCell.h"
#import "MMSearchContentMusicVideosCell.h"

#import "Song.h"


@interface MMSearchContentViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSString *type;

@end

static NSString *const cellID = @" cell reuse identifier";
@implementation MMSearchContentViewController

- (instancetype)initWithResponseRoot:(ResponseRoot *)responseRoot{
    if (self = [super init]) {
        _responseRoot = responseRoot;
        _type = responseRoot.data.firstObject.type; //资源类型
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

    //view 大小产生变化
    UIView *superView = self.view;
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 4, 0, 4);
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView).insets(padding);
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.responseRoot.data.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    if ([cell isKindOfClass:MMSearchContentCell.class]) {
        ((MMSearchContentCell*)cell).resource = [self.responseRoot.data objectAtIndex:indexPath.row];
    }
    [cell setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1]];

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
    }
}


- (UICollectionView *)collectionView{
    if (!_collectionView) {

        UIEdgeInsets padding = UIEdgeInsetsMake(0, 4, 0, 4);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layout setMinimumLineSpacing:padding.left];

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
        [_collectionView setContentInset:padding];  //内容左右偏移4, 翻页时看到分界线效果

        // 不同的类型注册不同的cell 及设置不同的大小
        ({
            CGFloat w = CGRectGetWidth(self.view.bounds) - (padding.left+padding.right);
            CGFloat h = 0;

            if ([self.type isEqualToString:@"artists"]) {
                [_collectionView registerClass:[MMSearchContentArtistsCell class] forCellWithReuseIdentifier:cellID];
                h = 60.0;

            }else if ([self.type isEqualToString:@"songs"]) {
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
     NSURLRequest *request = [self createRequestWithHref:self.responseRoot.next];
     [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
         json =[json valueForKeyPath:@"results"];

         [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
             ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
             self.responseRoot.next = root.next;
             self.responseRoot.data = [self.responseRoot.data arrayByAddingObjectsFromArray:root.data];
         }];

         dispatch_async(dispatch_get_main_queue(), ^{
             [self.collectionView.mj_footer endRefreshing];
             [self.collectionView reloadData];
         });
     }];
 }


@end
