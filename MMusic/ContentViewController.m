//
//  ContentViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

// pod/sy
#import <Masonry.h>
#import <MJRefresh.h>
//vc
#import "ContentViewController.h"
#import "DetailViewController.h"

//view
#import "MusicVideosCollectionCell.h"
#import "SongCell.h"

//model
#import "ResponseRoot.h"
#import "Resource.h"
#import "Artwork.h"


@interface ContentViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) UITableView *tableView;
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

    NSString *type = self.resourceDict.allKeys.firstObject;
    if ([type isEqualToString:@"songs"]) {
        [self.view addSubview:self.tableView];
    }else{
        [self.view addSubview:self.collectionView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    NSString *type = self.resourceDict.allKeys.firstObject;
    UIView*superview = self.view;
    if ([type isEqualToString:@"songs"]) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero);
        }];
    }else{
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
             make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero);
        }];
    }
}


#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.resourceDict.allValues.firstObject.data  count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ResourceCollectionViewCell *cell;
    cell = (ResourceCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    Resource *resource = [self.resourceDict.allValues.firstObject.data objectAtIndex:indexPath.row];
    if ([resource.type isEqualToString:@"music-videos"]) {
        MusicVideo *mv = [MusicVideo instanceWithResource:resource];
        cell.nameLabel.text = mv.name;
        cell.artistLabel.text = mv.artistName;
        [self showImageToView:cell.artworkView withImageURL:mv.artwork.url cacheToMemory:YES];
    }else{
        cell.nameLabel.text = [resource.attributes valueForKey:@"name"];
        Artwork *artwork = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
        [self showImageToView:cell.artworkView withImageURL:artwork.url cacheToMemory:YES];
    }
    return cell;
}
#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    Resource *resource = [self.resourceDict.allValues.firstObject.data objectAtIndex:indexPath.row];
    if ([resource.type isEqualToString:@"music-videos"]) {

    }else{
        DetailViewController *detail = [[DetailViewController alloc] initWithResource:resource];
        [self.navigationController pushViewController:detail animated:YES];
    }
}
#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.resourceDict.allValues.firstObject.data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SongCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    Resource *resource = [self.resourceDict.allValues.firstObject.data objectAtIndex:indexPath.row];
    Song *song = [Song instanceWithResource:resource];
    cell.song = song;
    //歌曲序号
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    return cell;
}
#pragma mark - UITableViewDelegate

#pragma mark - loadNextPage
-(void) requestNextPageDataFromHref:(NSString*) href{
    NSURLRequest *request =  [self createRequestWithHref:href];

    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [obj enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *nextRoot = [ResponseRoot instanceWithDict:obj];
                self->_resourceDict.allValues.firstObject.next = nextRoot.next;
                self->_resourceDict.allValues.firstObject.data = [self->_resourceDict.allValues.firstObject.data arrayByAddingObjectsFromArray:nextRoot.data];

                Resource *resource = nextRoot.data.firstObject;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([resource.type isEqualToString:@"songs"]) {
                        [self.tableView.mj_footer endRefreshing];
                        [self.tableView reloadData];
                    }else{
                        [self.collectionView.mj_footer endRefreshing];
                        [self.collectionView reloadData];
                    }
                });
            }];
        }];
    }];
}

#pragma mark - getter
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:SongCell.class forCellReuseIdentifier:cellID];
        [_tableView setRowHeight:44.0f];

        ResponseRoot *root = self.resourceDict.allValues.firstObject;
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            if (root.next) {
                [self requestNextPageDataFromHref:root.next];
            }else{
                [self->_tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }];
    }
    return _tableView;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        layout.minimumInteritemSpacing = miniSpacing;
        layout.minimumLineSpacing = miniSpacing;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;

        //
         ResponseRoot *root = self.resourceDict.allValues.firstObject;
        _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            if (root.next) {
                [self requestNextPageDataFromHref:root.next];
            }else{
                [self->_collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }];

        //注册不同类型的cell 并决定不同大小的Cell
        NSString *type = self.resourceDict.allKeys.firstObject;
        CGFloat h;
        CGFloat w;
        CGRect rect = self.view.frame;

        if([type isEqualToString:@"music-videos"]){
            [_collectionView registerClass:MusicVideosCollectionCell.class forCellWithReuseIdentifier:cellID];
            w = CGRectGetWidth(rect);
            h = w*0.75;
        }else{
            [_collectionView registerClass:ResourceCollectionViewCell.class forCellWithReuseIdentifier:cellID];
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
