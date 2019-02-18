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

#import "Recommendation.h"

@interface RecommendationDataSource ()<UICollectionViewDataSource>

@property(nonatomic, strong) NSArray<NSDictionary<NSString*,NSArray<Resource*>*>*>* dataArray;

@property(nonatomic, copy) NSString *identifier;
@property(nonatomic, copy) NSString *sectionIdentifier;
@property(nonatomic, weak) UICollectionView *collectionView;
@property(nonatomic, weak) id<RecommendationDataSourceDelegate> delegate;

@property(nonatomic, strong) JGProgressHUD *hud;
@end

@implementation RecommendationDataSource


- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                        cellIdentifier:(nonnull NSString *)identifier
                     sectionIdentifier:(NSString * _Nullable)sectionIdentifier
                              delegate:(nonnull id<RecommendationDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _collectionView = collectionView;
        collectionView.dataSource = self;

        _sectionIdentifier = sectionIdentifier;
        _identifier = identifier;
        _delegate = delegate;

        //加载数据
        [self loadDataWithCollectionView:collectionView];
    }
    return self;
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
- (Resource *)selectedResourceAtIndexPath:(NSIndexPath *)indexPath{
    return [self dataWithIndexPath:indexPath];
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    if (_delegate && [_delegate respondsToSelector:@selector(configureCell:object:)]) {
        [_delegate configureCell:cell object:[self dataWithIndexPath:indexPath]];
    }
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //节头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                            withReuseIdentifier:_sectionIdentifier
                                                                                   forIndexPath:indexPath];
        if (_delegate && [_delegate respondsToSelector:@selector(configureSupplementaryElement:object:)]) {
            [_delegate configureSupplementaryElement:view object:[self titleWithSection:indexPath.section]];
        }
        return view;
    }
    return nil;
}

#pragma  mark - help
// section title
- (NSString *)titleWithSection:(NSInteger)section{
    return [[[_dataArray objectAtIndex:section] allKeys] firstObject];
}
- (Resource *)dataWithIndexPath:(NSIndexPath *)indexPath{
    NSDictionary<NSString*,NSArray<Resource*>*> * temp = [_dataArray objectAtIndex:indexPath.section];
    return [[[temp allValues] firstObject] objectAtIndex:indexPath.row];
}

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

            //分组推荐时, sunJSON 内部还包含多组subJSON, 在方法内部判断, 递归解析;
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
- (JGProgressHUD *)hud{
    if (!_hud) {
        _hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
        _hud.textLabel.text = @"loading...";
    }
    return _hud;
}
@end
