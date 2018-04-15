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
    UIEdgeInsets padding = UIEdgeInsetsMake(5, 5, 5, 5);
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
//    [self.collectionView.mj_header endRefreshingWithCompletionBlock:^{
//        Log(@"完成刷新!");
//    }];
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

        NSMutableArray *tempList = [NSMutableArray array];  //所有数据临时集合
        NSMutableArray *titleList = [NSMutableArray array]; //临时节title 集合

        //遍历出每一节
        for (NSDictionary *sectonDict in [json objectForKey:@"data"]) {
            //section title
            NSString *title = [[[sectonDict objectForKey:@"attributes"] objectForKey:@"title"] objectForKey:@"stringForDisplay"];
            if (!title) title = @"Apple为你推荐";
            [titleList addObject:title];

            //每一节数据解析后, 添加入临时集合
            [tempList addObject:[self serializationJSON:sectonDict]];
        }
        //所有数据解析完成, 设置数据
        self.allDatas = tempList;
        self.titles = titleList;

        //刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityView stopAnimating];
            [self.collectionView reloadData];
        });
    }];
}
/**解析JSON 数据*/
-(NSArray*) serializationJSON:(NSDictionary*) json{

    NSMutableArray *sectionList = [NSMutableArray array];               //节数据临时集合
    NSDictionary *relationships = [json objectForKey:@"relationships"];
    NSDictionary *contents = [relationships objectForKey:@"contents"];  //如果这里有内容, 则不是组推荐, 没有值就是组推荐

    if (contents) {
        //非组推荐
        for (NSDictionary *source in [contents objectForKey:@"data"]) {
            //具体资源类型
            NSString *type = [source objectForKey:@"type"];
            if ([type isEqualToString:@"playlists"]) {
                [sectionList addObject:[Playlist instanceWithDict:[source objectForKey:@"attributes"]]];
            }
            if ([type isEqualToString:@"albums"]) {
                [sectionList addObject:[Album instanceWithDict:[source objectForKey:@"attributes"]]];
            }
        }
    }else{
        //组推荐
        NSDictionary *recommendations = [relationships objectForKey:@"recommendations"];
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

    //识别取出的数据类型
    Album *album ;
    Playlist *playlist;

    if ([resource isKindOfClass:[Album class]]) {
        album = (Album*)resource;
    }
    if ([resource isKindOfClass:[Playlist class]]) {
        playlist = (Playlist*)resource;
    }


    Artwork *artwork = album ? album.artwork : playlist.artwork;
    //封面图片在磁盘中的路径(如果有,url作为md5加密, 加密后的字符作为文件名称: urlMD5String.png)
    NSString *filePath = IMAGEPATH_FOR_URL(artwork.url);
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    if (image) {
        [cell.artworkView setImage:image];
    }
    else{
        //image URL
        CGFloat w = CGRectGetWidth(cell.contentView.bounds);
        CGFloat h = w;
        if (h!=0) {
            NSString *imagePath = [self stringReplacingOfString:artwork.url height:h width:w];
            NSURL *imageURL = [NSURL URLWithString:imagePath];
            [cell.artworkView sd_setImageWithURL:imageURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

                NSFileManager *fm = [NSFileManager defaultManager];
                BOOL isDir = NO;
                BOOL exist = [fm fileExistsAtPath:ARTWORKIMAGEPATH isDirectory:&isDir];
                //目标文件夹不存在就创建
                if (!(isDir && exist)){
                    [fm createDirectoryAtPath:ARTWORKIMAGEPATH withIntermediateDirectories:YES attributes:nil error:nil];
                }
                BOOL sucessed = [fm createFileAtPath:filePath contents:UIImagePNGRepresentation(image) attributes:nil];
                if (!sucessed) [fm removeItemAtPath:filePath error:&error];
           }];
        }
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
        header.backgroundColor = UIColor.whiteColor;
        return header;
    }
    return nil;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [[self.allDatas objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DetailViewController *detailVC ;
    if ([obj isKindOfClass:[Album class]]) {
        detailVC = [[DetailViewController alloc] initWithAlbum:(Album*)obj];
    }
    if([obj isKindOfClass:[Playlist class]]) {
        detailVC = [[DetailViewController alloc] initWithPlaylist:(Playlist*)obj];
    }
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
