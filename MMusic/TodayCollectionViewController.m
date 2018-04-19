//
//  TodayCollectionViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/26.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <MJRefresh.h>
#import <Masonry.h>

#import "TodayCollectionViewController.h"
#import "TodayCell.h"
#import "HeadCell.h"
#import "DetailViewController.h"

#import "PersonalizedRequestFactory.h"
#import "Resource.h"
#import "Artwork.h"
#import "Playlist.h"
#import "Album.h"

@interface TodayCollectionViewController()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UIActivityIndicatorView *activityView; //加载指示器
@property(nonatomic, strong) NSArray<NSArray*> *allDatas;           //所有数据, 内部每个数组即为每一节的数据
@property(nonatomic, strong) NSArray<NSString*> *titles;            //节title
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation TodayCollectionViewController
//
static NSString *const sectionIdentifier = @"sectionView";
static NSString *const cellIdentifier = @"todayCell";
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    [self requestData];

    self.collectionView = ({
        //collection layout
        CGFloat w = CGRectGetWidth(self.view.bounds) /2-10;
        CGFloat h = w;
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.scrollDirection =  UICollectionViewScrollDirectionVertical;
        //cell size
        layout.itemSize = CGSizeMake(w, h);
        //section size
        layout.headerReferenceSize = CGSizeMake(w, 44.0f);
        layout.sectionHeadersPinToVisibleBounds = YES;

        UICollectionView *view = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        //注册重用
        [view registerClass:[TodayCell class] forCellWithReuseIdentifier:cellIdentifier];
        [view registerClass:[HeadCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:sectionIdentifier];
        view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.9];
        view.dataSource = self;
        view.delegate  = self;

        view;
    });

    //添加 到父视图  并约束
    [self.view addSubview:self.collectionView];

    //布局 集合视图
    UIEdgeInsets padding = UIEdgeInsetsMake(4, 4, 4, 4);
    UIView *superview = self.view;
    __weak typeof(self) weakSelf = self;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        //减去导航栏/状态栏 及tabbar 高度
        CGFloat statusH = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);
        CGFloat navigaH = CGRectGetHeight(weakSelf.navigationController.navigationBar.bounds);
        CGFloat tabBatH = CGRectGetHeight(weakSelf.tabBarController.tabBar.bounds);
        CGFloat y =statusH+navigaH;
        make.top.mas_equalTo(superview.mas_top).with.offset((padding.top+y));
        make.left.mas_equalTo(superview.mas_left).with.offset(padding.left);
        make.right.mas_equalTo(superview.mas_right).with.offset(-padding.right);
        make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-(padding.bottom+tabBatH));
    }];


    //添加加载指示器
    self.activityView = ({
        UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithFrame:self.collectionView.frame];
        [view setHidesWhenStopped:YES];
        [view setColor:[UIColor lightGrayColor]];
        [view setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.96 alpha:0.9]];
        [view startAnimating];
        [self.view addSubview:view];

        view;
    });

    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        Log(@"刷新");
        [self requestData];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark 请求数据
- (void)requestData {
    //个人数据请求
    PersonalizedRequestFactory *fac = [PersonalizedRequestFactory personalizedRequestFactory];
    NSURLRequest *request = [fac createRequestWithType:PersonalizedDefaultRecommendationsType resourceIds:@[]];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary * json= [self serializationDataWithResponse:response data:data error:error];
        if (json) {
            NSMutableArray *tempList = NSMutableArray.new;  //所有数据临时集合
            NSMutableArray *titleList = NSMutableArray.new; //临时节title 集合

            for (NSDictionary *tempDict in [json objectForKey:@"data"]) {
                //title
                NSString *title = [tempDict valueForKeyPath:@"attributes.title.stringForDisplay"];
                if (!title) {
                    NSArray *tempList = [tempDict valueForKeyPath:@"relationships.contents.data"];
                    title = [tempList.firstObject valueForKeyPath:@"attributes.curatorName"];
                }
                [titleList addObject:title];
                [tempList addObject:[self serializationJSON:tempDict]];
            }

            //所有数据解析完成, 设置数据
            self.allDatas = tempList;
            self.titles = titleList;
            //刷新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityView stopAnimating];
                [self.collectionView reloadData];
            });
        }
    }];
}
/**解析JSON 数据*/
-(NSArray*) serializationJSON:(NSDictionary*) json{
    NSMutableArray *sectionList = [NSMutableArray array];  //节数据临时集合
    json = [json objectForKey:@"relationships"];

    NSDictionary *contents = [json objectForKey:@"contents"];  //如果这里有内容, 则不是组推荐, 没有值就是组推荐
    if (contents) {
        //非组推荐
        for (NSDictionary *source in [contents objectForKey:@"data"]) {
            //具体资源类型
            NSString *type = [source objectForKey:@"type"];
            Class cls = [self classForResourceType:type];
            id obj = [cls instanceWithDict:[source objectForKey:@"attributes"]];
            [sectionList addObject:obj];
        }
    }else{
        //组推荐
        NSDictionary *recommendations = [json objectForKey:@"recommendations"];
        if (recommendations) {
            for (NSDictionary *subJSON  in [recommendations objectForKey:@"data"]) {
                //递归
                sectionList = (NSMutableArray*)[self serializationJSON: subJSON];
            }
        }
    }
    return sectionList;
}

#pragma mark <UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.allDatas.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.allDatas objectAtIndex:section].count;
}

//cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TodayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    // Configure the cell
    NSArray *temp = [self.allDatas objectAtIndex:indexPath.section];
    id resource = [temp objectAtIndex:indexPath.row];

    //设置封面
    if ([resource respondsToSelector:@selector(artwork)]) {
        Artwork *artwork = [resource valueForKey:@"artwork"];
        [self showImageToView:cell.artworkView withImageURL:artwork.url cacheToMemory:YES];
    }
    return cell;
}

//头尾
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    //节头
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSString *title = [self.titles objectAtIndex:indexPath.section];
        HeadCell *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                            withReuseIdentifier:sectionIdentifier
                                                                forIndexPath:indexPath];
        [header.titleLabel setText:title];
        header.backgroundColor = collectionView.backgroundColor;
        return header;
    }
    return nil;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [[self.allDatas objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DetailViewController *detailVC = [[DetailViewController alloc] initWithObject:obj];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
