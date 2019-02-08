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

@interface RecommendationDataSource ()

@property(nonatomic, strong) NSArray<NSDictionary<NSString*,NSArray<Resource*>*>*>* dataArray;

@property(nonatomic, copy) NSString *reuseIdentifier;
@property(nonatomic, copy) NSString *sectionIdentifier;
@property(nonatomic, weak) UICollectionView *collectionView;
@property(nonatomic, weak) id<RecommendationDataSourceDelegate> delegate;
@end

@implementation RecommendationDataSource


- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
                        cellIdentifier:(nonnull NSString *)identifier
                     sectionIdentifier:(nonnull NSString *)sectionIdentifier
                              delegate:(nonnull id<RecommendationDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _collectionView = collectionView;
        collectionView.dataSource = self;

        _sectionIdentifier = sectionIdentifier;
        _reuseIdentifier = identifier;
        _delegate = delegate;

        //加载数据
        [self loadDataWithCollectionView:collectionView];
    }
    return self;
}

- (void)loadDataWithCollectionView:(UICollectionView*)view{

    //加载数据
    JGProgressHUD *hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
    [hud.textLabel setText:@"加载中..."];
    [hud showInView:view animated:YES];

    [self defaultRecommendataionWithCompletion:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                [hud dismissAnimated:YES];
                [hud removeFromSuperview];
                [view reloadData];
                [view.mj_header endRefreshing]; //停止刷新控件
            }else{
                [hud.textLabel setText:@"数据加载失败!"];
                [hud dismissAfterDelay:2 animated:YES];

                //加载失败, 设置刷新控件
                [view setMj_header:[MJRefreshNormalHeader headerWithRefreshingBlock:^{
                    [self loadDataWithCollectionView:view];
                }]];
            }
        });
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_reuseIdentifier forIndexPath:indexPath];
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
            completion(self.dataArray.count > 0);
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
@end
