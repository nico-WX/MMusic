//
//  CuratorsAndActivitiesViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/29.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MJRefresh.h>

#import "CuratorsAndActivitiesViewController.h"
#import "DetailViewController.h"
#import "DetailHeaderView.h"
#import "ResourceCollectionViewCell.h"

#import "RequestFactory.h"

#import "Relationship.h"
#import "ResponseRoot.h"
#import "Resource.h"
#import "Playlist.h"
#import "EditorialNotes.h"
#import "Artwork.h"


@interface CuratorsAndActivitiesViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong, readonly) Resource *resource;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) ResponseRoot *root; //relationship
@end
static const CGFloat spacing = 4.0f;
static NSString *const cellID = @"CollectionViewCellReuseID";
@implementation CuratorsAndActivitiesViewController

-(instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
        _resource = resource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view setBackgroundColor:UIColor.whiteColor];

    [self setTitle:[self.resource.attributes valueForKey:@"name"]];

    [self.view addSubview:self.collectionView];
    [self requestData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//布局
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    __weak typeof(self) weakSelf = self;
    UIView *superview = self.view;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat topOffset = CGRectGetMaxY(weakSelf.navigationController.navigationBar.frame);
        make.top.mas_equalTo(superview.mas_top).offset(topOffset);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);

        CGFloat offset = CGRectGetHeight(self.tabBarController.tabBar.frame);
        make.bottom.mas_equalTo(superview).offset(-offset);
    }];

}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.root.data.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ResourceCollectionViewCell *cell;
    cell = (ResourceCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    Resource *resource = [self.root.data objectAtIndex:indexPath.row];
    Playlist *playlist = [Playlist instanceWithResource:resource];
    cell.nameLabel.text =  playlist.name;
    [self showImageToView:cell.artworkView withImageURL:playlist.artwork.url cacheToMemory:YES];
    [cell setBackgroundColor:[UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]];

    return cell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    Resource *res = [self.root.data objectAtIndex:indexPath.row];
    DetailViewController *detail = [[DetailViewController alloc] initWithResource:res];
    [self.navigationController pushViewController:detail animated:YES];
}


#pragma mark helper
/**初次请求数据*/
-(void) requestData{
    NSURLRequest *request = [[RequestFactory new] createRequestWithHref:self.resource.href];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        for (NSDictionary *subJson in [json valueForKey:@"data"]) {
            NSDictionary *rootDict = [subJson valueForKeyPath:@"relationships.playlists"];

            //关系中的内容  不包含具体资源的attributes, 单独请求资源,
            self.root = [ResponseRoot instanceWithDict:rootDict];
            NSMutableArray<Resource*> *temp = [NSMutableArray array];
            for (Resource *resource in self.root.data) {
                [temp addObject:[self requestResourceFormHref:resource.href]];
            }
            self.root.data = temp;
        }
        //刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}

/**请求到的具体资源, 设置到一个空内容的Resource 对象中, 返回*/
-(Resource*) requestResourceFormHref:(NSString*) href{

    Resource *re = [Resource new];
    NSURLRequest *request = [[RequestFactory new] createRequestWithHref:href];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        for (NSDictionary *sub in [json valueForKey:@"data"]) {
            Resource *resource = [Resource instanceWithDict:sub];
            re.identifier   = resource.identifier;
            re.href         = resource.href;
            re.type         = resource.type;
            re.attributes   = resource.attributes;
        }
    }];
    return re;
}

/**加载分页*/
-(void) loadNextPageFromHref:(NSString*)href{
    NSURLRequest *request = [[RequestFactory new] createRequestWithHref:href];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        if (json.allKeys > 0 ) {

            //json  :  @{@"next":@"....",@"data":@[]}
            //替换 next @添加数据到data 中
            self.root.next = [json valueForKey:@"next"];

            NSMutableArray<Resource*> *temp = [NSMutableArray array];
            for (NSDictionary *dict in [json valueForKey:@"data"]) [temp addObject:[Resource instanceWithDict:dict]];

            //添加到 root.data 中
            self.root.data = [self.root.data arrayByAddingObjectsFromArray:temp];
            //刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView.mj_footer endRefreshing];
                [self.collectionView reloadData];
            });
        }else{
            //无数据
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView.mj_footer endRefreshing];
            });
        }
    }];
}

#pragma mark -getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        [layout setMinimumInteritemSpacing:spacing];
        [layout setMinimumInteritemSpacing:spacing];
        CGFloat w = CGRectGetWidth(self.view.frame)/2 - spacing;
        CGFloat h = w+28;
        [layout setItemSize:CGSizeMake(w, h)];

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];

        [_collectionView registerClass:ResourceCollectionViewCell.class forCellWithReuseIdentifier:cellID];
        [_collectionView setBackgroundColor:UIColor.whiteColor];

        __weak typeof(self) weakSelf = self;
        _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            if (weakSelf.root.next) {
                [self loadNextPageFromHref:weakSelf.root.next];
            }else{
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }
    return _collectionView;
}


@end
