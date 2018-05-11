//
//  ContentViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <MJRefresh.h>

#import "ContentViewController.h"
#import "ResponseRoot.h"
#import "Resource.h"
#import "Artwork.h"
#import "RequestFactory.h"

#import "ChartsSongCell.h"
#import "MusicVideoCell.h"
#import "AlbumCell.h"

@interface ContentViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong) UICollectionView *collectionView;
@end

static const CGFloat row = 2;
static const CGFloat miniSpacing = 2;
static NSString * const cellID = @"cellReuseIdentifier";
@implementation ContentViewController

-(instancetype)initWithResourceDict:(NSDictionary<NSString *,ResponseRoot *> *)resourceDict{
    if (self =[super init]) {
        _resourceDict = resourceDict;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColor.whiteColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = self.view.bounds;

    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        ResponseRoot *root = self.resourceDict.allValues.firstObject;
        if (root.next) {
            [self requestNextPageDataFromHref:root.next];
        }else{
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    UIView *superview = self.view;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview).insets(UIEdgeInsetsMake(0, miniSpacing, 0, miniSpacing));
    }];
}


#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.resourceDict.allValues.firstObject.data  count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ChartsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    Resource *resource = [self.resourceDict.allValues.firstObject.data objectAtIndex:indexPath.row];
    cell.titleLabel.text = [resource.attributes valueForKeyPath:@"name"];

    NSString *artistText;
    if ([resource.attributes valueForKeyPath:@"artistName"]) {
        artistText = [resource.attributes valueForKeyPath:@"artistName"];
    }else if ([resource.attributes valueForKeyPath:@"curatorName"]){
        artistText = [resource.attributes valueForKeyPath:@"curatorName"];
    }else{
        artistText = [resource.attributes valueForKeyPath:@"editorialNotes.short"];
    }
    cell.artistLabel.text = artistText;


    Artwork *artwork = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
    [self showImageToView:cell.artworkView withImageURL:artwork.url cacheToMemory:YES];

    cell.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    return cell;
}
#pragma mark - UICollectionViewDelegate


#pragma mark - loadNextPage
-(void) requestNextPageDataFromHref:(NSString*) href{
    NSURLRequest *request =  [[RequestFactory new] createRequestWithHref:href];
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
        //{@"results":{@"playlists":{}...}}
        [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *nextRoot = [ResponseRoot instanceWithDict:obj];
                _resourceDict.allValues.firstObject.next = nextRoot.next;
                _resourceDict.allValues.firstObject.data = [_resourceDict.allValues.firstObject.data arrayByAddingObjectsFromArray:nextRoot.data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView.mj_footer endRefreshing];
                    [self.collectionView reloadData];
                });
            }];
        }];
    }];
}

#pragma mark - getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        layout.minimumInteritemSpacing = miniSpacing;
        layout.minimumLineSpacing = miniSpacing;

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;

        //注册不同类型的cell 并决定不同大小的Cell
        NSString *type = self.resourceDict.allKeys.firstObject;
        CGFloat h;
        CGFloat w;
        CGRect rect = self.view.frame;
        if ([type isEqualToString:@"songs"]) {
            [_collectionView registerClass:ChartsSongCell.class forCellWithReuseIdentifier:cellID];
            w =CGRectGetWidth(rect);
            h = 44.0f;
        }else if([type isEqualToString:@"music-videos"]){
            [_collectionView registerClass:MusicVideoCell.class forCellWithReuseIdentifier:cellID];
            w = CGRectGetWidth(rect);
            h = w*0.75;
        }else{
            [_collectionView registerClass:AlbumCell.class forCellWithReuseIdentifier:cellID];
            w = CGRectGetWidth(rect);
            w = w - (row+1)*miniSpacing;
            w = w/row;
            h = w +28;
        }

        [layout setItemSize:CGSizeMake(w, h)];
    }
    return _collectionView;
}

@end
