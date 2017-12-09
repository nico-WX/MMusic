//
//  RecommendationsCollectionViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/23.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <UIImageView+WebCache.h>

#import "MMRecommendationViewController.h"
#import "RecommendationsCell.h"
#import "MMRecommendationDetailViewController.h"

#import "PersonalizedRequestFactory.h"
#import "NSObject+Serialization.h"
#import "Recommendation.h"
#import "RequestFactory.h"
#import "ResponseRoot.h"
#import "Resource.h"

@interface MMRecommendationViewController ()<UICollectionViewDelegateFlowLayout,MPPlayableContentDelegate>
//
@property(nonatomic,strong) MPMusicPlayerController *player;
@property(nonatomic,strong) NSArray<Recommendation*> *recommendationArray;
//原始数据
@property(nonatomic, strong) ResponseRoot *root;
//普通请求工厂
@property(nonatomic, strong) RequestFactory *requestFactory;
//个性化请求工厂
@property(nonatomic, strong) PersonalizedRequestFactory *personalizedFactory;

@end

@implementation MMRecommendationViewController

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

    //请求默认个人推荐数据
    NSURLRequest *request = [self.personalizedFactory createRequestWithType:PersonalizedDefaultRecommendationsType resourceIds:@[]];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [self serializationDataWithResponse:response data:data error:error];
        self.root = [ResponseRoot instanceWithDict:dict];
        NSMutableArray *temp = [NSMutableArray array];
        for (NSDictionary *tempDict in [dict objectForKey:@"data"]) {
            Recommendation *recom = [Recommendation instanceWithDict:tempDict];
            //生成推荐对象
            [temp addObject:recom];
        }
        self.recommendationArray = temp;
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];

}
//封装发起任务请求操作
-(void)dataTaskWithdRequest:(NSURLRequest*) request completionHandler:(void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler{
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        handler(data,response,error);
    }] resume];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark lazy
-(RequestFactory *)requestFactory{
    if (!_requestFactory) {
        _requestFactory = [RequestFactory requestFactory];
    }
    return _requestFactory;
}
-(PersonalizedRequestFactory *)personalizedFactory{
    if (!_personalizedFactory) {
        _personalizedFactory = [PersonalizedRequestFactory personalizedRequestFactory];
    }
    return _personalizedFactory;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommendationArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommendationsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    cell.recommendation = [self.recommendationArray objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

//    {
//    //API return playParams
//    NSDictionary *dict = @{@"id":@"203709340",@"kind":@"song"};
//    //@{@"playParams":@{@"id":@"157382428",@"kind":@"song"}};
//    MPMusicPlayerPlayParameters *p1 = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:dict];
//    MPMusicPlayerPlayParameters *p2 = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:@{@"id":@"157890492",@"kind":@"album"}];
//    MPMusicPlayerPlayParametersQueueDescriptor *des = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[p2,]];
//    self.player = [MPMusicPlayerController systemMusicPlayer];
//    [self.player setQueueWithDescriptor:des];
//    //[self.player prepareToPlay];
//    //[self.player play];
//    Log(@"in>>>>>%@",self.player.nowPlayingItem.title);
//    }

    MMRecommendationDetailViewController *detail = [[MMRecommendationDetailViewController alloc] init];
    //传入数据
    detail.recommendation = [self.recommendationArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detail animated:YES];
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
