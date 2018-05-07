//
//  ContentViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "ContentViewController.h"
#import "ResponseRoot.h"
#import "Resource.h"
#import "Artwork.h"

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

    if ([resource.type isEqualToString:@"statins"]) {

    }

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

    if ([resource.type isEqualToString:@"stations"]) {
        Log(@"art=%@",artwork.url);
    }

    cell.backgroundColor = UIColor.redColor;
    return cell;
}
#pragma mark - UICollectionViewDelegate
#pragma mark - UICollectionViewFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat h;
    CGFloat w;
    NSString *type = self.resourceDict.allKeys.firstObject;
    if ([type isEqualToString:@"music-videos"]) {
        w = CGRectGetWidth(collectionView.bounds);
        h = w*0.75;

    }else if([type isEqualToString:@"songs"]){
        w =CGRectGetWidth(collectionView.bounds);
        h = 44.0f;
    }else{
        w = CGRectGetWidth(collectionView.bounds);
        w = w - (row+3)*miniSpacing;
        w = w/row;
        h = w +28;
    }
    return CGSizeMake(w, h);;
}

#pragma mark - getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;

        //注册不同类型的cell
        NSString *type = self.resourceDict.allKeys.firstObject;
        if ([type isEqualToString:@"songs"]) {
            [_collectionView registerClass:ChartsSongCell.class forCellWithReuseIdentifier:cellID];
        }else if([type isEqualToString:@"music-videos"]){
            [_collectionView registerClass:MusicVideoCell.class forCellWithReuseIdentifier:cellID];
        }else{
            [_collectionView registerClass:AlbumCell.class forCellWithReuseIdentifier:cellID];
        }
    }
    return _collectionView;
}


@end
