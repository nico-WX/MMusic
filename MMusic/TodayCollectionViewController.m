//
//  TodayCollectionViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/26.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "TodayCollectionViewController.h"
#import "TodayCollectionViewCell.h"
#import "RecommendDetailViewController.h"

#import "PersonalizedRequestFactory.h"
#import "NSObject+Tool.h"

#import "Resource.h"

@interface TodayCollectionViewController ()<UICollectionViewDelegateFlowLayout>
@property(nonatomic, copy) NSString *imageURL;
@property(nonatomic, strong) NSArray<Resource*> *resources;
@end

@implementation TodayCollectionViewController

static NSString * const reuseIdentifier = @"TodayCell";
static NSString * const headerReuseId   = @"HeaderReuseIdentifier";

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    // Register cell classes
    [self.collectionView registerClass:[TodayCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    //[self.collectionView registerClass:[TodayHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerReuseId];
    
    // Do any additional setup after loading the view.
    //覆盖布局
    [self resetLayout];

    //请求数据
    [self requestData];
}

#pragma mark 重设布局
-(void)resetLayout{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [self.collectionView setCollectionViewLayout:layout animated:YES];

    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setMinimumLineSpacing:20];

    CGRect rect = self.collectionView.frame;
    CGFloat w = rect.size.width -40;
    CGFloat h = w * 1;
    [layout setItemSize:CGSizeMake(w, h)];
}

#pragma  mark 请求数据
- (void)requestData{
    PersonalizedRequestFactory *fac = [PersonalizedRequestFactory personalizedRequestFactory];
    NSURLRequest *request = [fac createRequestWithType:PersonalizedDefaultRecommendationsType resourceIds:@[]];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [self serializationDataWithResponse:response data:data error:error];
        NSMutableArray *resourArray = [NSMutableArray array];
        for (NSDictionary *temp in [dict objectForKey:@"data"]) {
            Resource *res = [Resource instanceWithDict:temp];
            [resourArray addObject:res];
        }
        self.resources = resourArray;
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.resources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TodayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    Resource *res = [self.resources objectAtIndex:indexPath.row];
    cell.resource = res;
    return cell;
}

#pragma mark <UICollectionViewDelegate>
//-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    TodayHeaderView *view = nil;
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
//        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerReuseId forIndexPath:indexPath];
//    }
//
//    return view;
//}

//选择Cell
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    TodayCollectionViewCell *cell = (TodayCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    RecommendDetailViewController *detail = [[RecommendDetailViewController alloc] initWithCollectionViewLayout:layout];
    detail.data = cell.data;
    [detail setTitle:cell.title];
    [self.navigationController pushViewController:detail animated:YES];

}



@end
