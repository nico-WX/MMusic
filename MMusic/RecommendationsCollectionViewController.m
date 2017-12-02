//
//  RecommendationsCollectionViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/23.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <UIImageView+WebCache.h>

#import "RecommendationsCollectionViewController.h"
#import "RecommendationsCell.h"

#import "PersonalizedRequestFactory.h"
#import "NSObject+Serialization.h"
#import "Recommendation.h"
#import "RequestFactory.h"
#import "ResponseRoot.h"
#import "Resource.h"

@interface RecommendationsCollectionViewController ()<UICollectionViewDelegateFlowLayout,MPPlayableContentDelegate>
//
@property(nonatomic,strong) MPMusicPlayerController *player;

//defaultRecommendationResponseRoot
@property(nonatomic, strong) ResponseRoot *root;
//普通请求工厂
@property(nonatomic, strong) RequestFactory *requestFactory;
//个性化请求工厂
@property(nonatomic, strong) PersonalizedRequestFactory *personalizedFactory;

@end

@implementation RecommendationsCollectionViewController

static NSString * const reuseIdentifier = @"recommemdationCell";
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    [self.collectionView registerClass:[RecommendationsCell class] forCellWithReuseIdentifier:reuseIdentifier];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];

    //覆盖布局
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [layout setSectionHeadersPinToVisibleBounds:YES];
    [self.collectionView setCollectionViewLayout:layout animated:YES];

    //请求数据
    NSURLRequest *request = [self.personalizedFactory createRequestWithType:PersonalizedDefaultRecommendationsType resourceIds:@[]];
    Log(@"path:%@",request.URL);

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [self serializationDataWithResponse:response data:data error:error];
        _root = [ResponseRoot responseRootWithDict:dict];
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

    }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.root.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendationsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    [cell.contentView setBackgroundColor:[UIColor redColor]];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    {
    //API return playParams
    NSDictionary *dict = @{@"id":@"203709340",@"kind":@"song"};
    //@{@"playParams":@{@"id":@"157382428",@"kind":@"song"}};
    MPMusicPlayerPlayParameters *p1 = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:dict];
    MPMusicPlayerPlayParametersQueueDescriptor *des = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[p1,]];
    self.player = [MPMusicPlayerController systemMusicPlayer];
    [self.player setQueueWithDescriptor:des];
    [self.player prepareToPlay];
    [self.player play];
    Log(@"in>>>>>%@",self.player.nowPlayingItem.title);
    }
}


#pragma mark <UICollectionViewDelegateFlowLayout>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = collectionView.frame.size;
    return CGSizeMake(size.height-4,size.height-4);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(1, 1, 1,0);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 1;
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
@end
