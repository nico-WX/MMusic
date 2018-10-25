//
//  ChartsViewController.m
//  MMusic
//
//  Copyright © 2018年 com.😈. All rights reserved.
//  pod and system
#import <Masonry.h>
#import <MJRefresh.h>

//Controller
#import "ChartsViewController.h"

//view  and cell
#import "ChartCell.h"

//model and tool
#import "MusicKit.h"
#import "Resource.h"

@interface ChartsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) NSArray<Chart*> *rowData;
@property(nonatomic, strong) UICollectionView *rowCollectionView; //每一行cell中包含一个视图控制器,及一个title

@end

static NSString *const reuseID = @"cellReuseIdentifier";
@implementation ChartsViewController

#pragma mark - init

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.rowCollectionView];
    [self requestData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestData{
    __weak typeof(self) weakSelf = self;
    [MusicKit.new.api chartsByType:ChartsAll callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        json = [json valueForKey:@"results"];
        if (json) {
            NSMutableArray<Chart*> *chartArray = [NSMutableArray array];
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {

                //值为数组
                NSArray *tempArray = (NSArray*) obj;
                [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    Chart *chart = [Chart instanceWithDict:(NSDictionary*)obj];
                    [chartArray addObject:chart];
                }];

            }];
            weakSelf.rowData = chartArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.rowCollectionView reloadData];

            });
        }
    }];
}

//内地无MV 排行数据, 请求香港地区
- (void) requestHongKongMVData{
    NSString *path = @"https://api.music.apple.com/v1/catalog/hk/charts?types=music-videos";
    NSURLRequest *request = [self createRequestWithURLString:path setupUserToken:NO];
    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if (json) {

        }
    }];
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.rowData.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ChartCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    cell.chart = [self.rowData objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark <UICollectonViewDelegate>

#pragma mark layz Load
- (UICollectionView *)rowCollectionView{
    if (!_rowCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat w = CGRectGetWidth(self.view.bounds);
        CGFloat h = 300.0;
        [layout setItemSize:CGSizeMake(w, h)];
        [layout setMinimumLineSpacing:20];

        _rowCollectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_rowCollectionView registerClass:[ChartCell class] forCellWithReuseIdentifier:reuseID];
        [_rowCollectionView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0]];

        _rowCollectionView.delegate = self;
        _rowCollectionView.dataSource = self;
    }
    return _rowCollectionView;
}

//#pragma mark - MPSystemMusicPlayerController
///**跳转到Music APP 播放MV*/
//- (void)openToPlayQueueDescriptor:(MPMusicPlayerQueueDescriptor *)queueDescriptor{
//    UIApplication *app = [UIApplication sharedApplication];
//    NSURL *url = [NSURL URLWithString:@"Music:prefs:root=MUSIC"];
//    if ([app canOpenURL:url]) {
//        [app openURL:url options:@{} completionHandler:^(BOOL success) {
//            [[MPMusicPlayerController systemMusicPlayer] setQueueWithDescriptor:queueDescriptor];
//            [[MPMusicPlayerController systemMusicPlayer] play];
//        }];
//    }
//}

@end
