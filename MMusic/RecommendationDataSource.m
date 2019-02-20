//
//  RecommendationDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/23.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import <JGProgressHUD.h>
#import <MJRefresh.h>

#import "RecommendationDataSource.h"
#import "ResponseRoot.h"
#import "Resource.h"
#import "Playlist.h"

#import "Recommendation.h"

#import "AuthManager.h"

@interface RecommendationDataSource ()
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,NSArray<Resource*>*>*>* dataArray;
@property(nonatomic, strong) JGProgressHUD *hud;
@end

@implementation RecommendationDataSource

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView identifier:(NSString *)identifier sectionIdentifier:(NSString *)sectionIdentifier delegate:(id<DataSourceDelegate>)delegate{
    if (self = [super initWithCollectionView:collectionView identifier:identifier sectionIdentifier:sectionIdentifier delegate:delegate]) {
        //加载数据
        [self loadDataWithCollectionView:collectionView];
    }
    return self;
}

#pragma mark instance method

- (void)reloadDataSource{
    self.dataArray = @[];
    [self loadDataWithCollectionView:self.collectionView];
}
- (void)clearDataSource{
    self.dataArray = @[];
}
//selected row data
- (Resource *)selectedResourceAtIndexPath:(NSIndexPath *)indexPath{
    return [self dataWithIndexPath:indexPath];
}

- (void)loadDataWithCollectionView:(UICollectionView*)colletionView{
    //加载数据
    [self.hud showInView:colletionView animated:YES];

    [self defaultRecommendataionWithCompletion:^(BOOL success) {
        [colletionView.mj_header endRefreshing];

        if (success) {
            [self.hud dismissAnimated:YES];
            [self.hud removeFromSuperview];
            [colletionView reloadData];
        }else{
            self.hud.indicatorView = nil;
            [self.hud.textLabel setText:@"加载失败,请下拉刷新"];
            //加载失败, 设置刷新控件
            if (!colletionView.mj_header) {
                [colletionView setMj_header:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
                    [self.hud.textLabel setText:@"loading..."];
                    JGProgressHUDIndicatorView *indicator = [JGProgressHUDIndeterminateIndicatorView new];
                    [indicator setUpForHUDStyle:self.hud.style vibrancyEnabled:YES];
                    [self.hud setIndicatorView:indicator];
                    [self loadDataWithCollectionView:colletionView];
                }]];
            }
        }
    }];
}


#pragma mark - collectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [[self dataArray] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSDictionary<NSString*,NSArray<Resource*>*> * temp = [self.dataArray objectAtIndex:section];
    return [[[temp allValues] firstObject] count];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifier forIndexPath:indexPath];
    if ([self.delegate respondsToSelector:@selector(configureCell:item:)]) {
        [self.delegate configureCell:cell item:[self dataWithIndexPath:indexPath]];
    }
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //节头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:self.sectionIdentifier
                                                                                   forIndexPath:indexPath];
        if ([self.delegate conformsToProtocol:@protocol(RecommendationDataSourceDelegate)]) {
            id<RecommendationDataSourceDelegate> currentDelegate = (id<RecommendationDataSourceDelegate>)self.delegate;
            if ([currentDelegate respondsToSelector:@selector(configureSupplementaryElement:object:)]) {
                [currentDelegate configureSupplementaryElement:view object:[self titleWithSection:indexPath.section]];
            }
        }
        return view;
    }
    return nil;
}

#pragma  mark - help method
// section title
- (NSString *)titleWithSection:(NSInteger)section{
    return [[[_dataArray objectAtIndex:section] allKeys] firstObject];
}
//row data
- (Resource *)dataWithIndexPath:(NSIndexPath *)indexPath{
    NSDictionary<NSString*,NSArray<Resource*>*> * temp = [_dataArray objectAtIndex:indexPath.section];
    return [[[temp allValues] firstObject] objectAtIndex:indexPath.row];
}

//加载数据
- (void)defaultRecommendataionWithCompletion:(void (^)(BOOL success))completion{
    [MusicKit.new.library defaultRecommendationsInCallBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        // @{@"data":@[Recommendation*]}
        // ResponseRoot.data<Recommendation*>

        NSMutableArray<NSDictionary<NSString*,NSArray<Resource*>*>*> *array = [NSMutableArray array];
        for (NSDictionary *subJSON in [json objectForKey:@"data"]) {
            //section title
            NSString *title = [subJSON valueForKeyPath:@"attributes.title.stringForDisplay"];
            if (!title) {
                //部分情况下无显示名称, 向下获取歌单维护者名称
                NSArray *list = [subJSON valueForKeyPath:@"relationships.contents.data"];
                title = [list.firstObject valueForKeyPath:@"attributes.curatorName"];
            }

            //每个子JSON 都是一节数据, 在辅助方法中解析,并返回
            NSArray *resources = [self serializationJSON:subJSON];
            [array addObject:@{title:resources}];
        }

        //保存数据
        self.dataArray = array;
        if (completion) {
            mainDispatch(^{
                completion(self.dataArray.count > 0);
            });
        }
    }];
}

/**解析JSON*/
- (NSArray<Resource*>*)serializationJSON:(NSDictionary*)json{

    NSMutableArray<Resource*> *sectionList = [NSMutableArray array];

    json = [json objectForKey:@"relationships"];
    NSDictionary *contents = [json objectForKey:@"contents"];  //如果这里有内容, 则不是组推荐
    if (contents) {
        //非组推荐
        for (NSDictionary *sourceDict in [contents objectForKey:@"data"]) {
            [sectionList addObject:[Resource instanceWithDict:sourceDict]];
        }
    }else{
        //组推荐
        NSDictionary *recommendations = [json objectForKey:@"recommendations"];
        //if (recommendations) {}

        for (NSDictionary *subJSON in [recommendations objectForKey:@"data"]) {
            //递归
            NSArray *temp =[self serializationJSON:subJSON];
            //数据添加
            [sectionList addObjectsFromArray:temp];
        }
    }
    return sectionList;
}

#pragma mark - getter

- (JGProgressHUD *)hud{
    if (!_hud) {
        _hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
        _hud.textLabel.text = @"loading...";
    }
    return _hud;
}
@end
