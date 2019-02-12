//
//  PodcastsViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/12.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "PodcastsViewController.h"
#import "ResourceCell+ConfigureForResource.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PodcastsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) MPMediaQuery *podcastsQuery;
@end

static NSString *const identifier =@"identifier";
@implementation PodcastsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.navigationItem setTitle:@"播客"];
    [self.view addSubview:self.collectionView];
}
- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [self.collectionView setFrame:self.view.bounds];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.podcastsQuery.collections.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ResourceCell *cell = (ResourceCell*)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    MPMediaItemCollection *itemCollection = [self.podcastsQuery.collections objectAtIndex:indexPath.row];
    [cell configureForMPMediaItemCollection:itemCollection];
    return cell;
}

- (MPMediaQuery *)podcastsQuery{
    if (!_podcastsQuery) {
        _podcastsQuery = [MPMediaQuery podcastsQuery];
    }
    return _podcastsQuery;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UIEdgeInsets insets = UIEdgeInsetsMake(0, 8, 0, 8);
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat w = CGRectGetWidth(self.view.bounds) - insets.left*4;
        w = w/2;
        CGFloat h = w +40;
        [layout setItemSize:CGSizeMake(w, h)];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView setBackgroundColor:UIColor.whiteColor];
        [_collectionView setContentInset:insets];
        [_collectionView registerClass:[ResourceCell class] forCellWithReuseIdentifier:identifier];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
    }
    return _collectionView;
}

@end
