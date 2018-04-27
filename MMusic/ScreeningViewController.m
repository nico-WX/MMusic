//
//  ScreeningViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>
#import "ScreeningViewController.h"

@interface ScreeningViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property(nonatomic, strong) NSArray<NSDictionary<NSString*,id>*> *screening;
@end
static int const row = 4;
static CGFloat const lineSpacing = 0.2f;
static CGFloat const rowSpacing = 2.0f;
static NSString *const cellID = @"cellReuseIdentifier";
static NSString *const sectionHeadID = @"collectionSectionHeadReuseID";

@implementation ScreeningViewController

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    UIView *superview = self.view;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(0, lineSpacing, 0, lineSpacing);
        make.edges.mas_equalTo(superview).with.insets(padding);
    }];
}
#pragma mark - UICollectionView DataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.screening.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSDictionary *sectionDict = [self.screening objectAtIndex:section];
    NSArray *list = sectionDict.allValues.firstObject;
    CGFloat itemCount = list.count + 1;

    return itemCount;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = UIColor.brownColor;
    return cell;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:sectionHeadID forIndexPath:indexPath];
    if (view) {

        return view;
    }
    return nil;
}
#pragma mark - UICollectionView Delegate

#pragma mark - UICollectionViewDelegateFlowLayout
//cell size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat spacing = rowSpacing*row-1;
    CGFloat cw = CGRectGetWidth(collectionView.bounds)-spacing;
    CGFloat w = cw/row;
    CGFloat h = w;

    if (indexPath.row==0) {
        return CGSizeMake(w, h-0.2);
    }else{
        return CGSizeMake(w, h/2);
    }
}

//节头size
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    CGFloat h = 20.0f;
    return CGSizeMake(w, h);
}

#pragma mark - getter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;
        layout.minimumLineSpacing = lineSpacing;
        layout.minimumInteritemSpacing = rowSpacing;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_collectionView registerClass:UICollectionViewCell.class forCellWithReuseIdentifier:cellID];
        [_collectionView registerClass:UICollectionReusableView.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:sectionHeadID];
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}
-(NSArray<NSDictionary<NSString*,id>*> *)screening{
    if (!_screening) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"screening" ofType:@"plist"];
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];

        NSMutableArray<NSDictionary<NSString*,id>*> *rootList = NSMutableArray.new;
        [root enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary *dict = @{key:obj};
            [rootList addObject:dict];
        }];
        _screening = rootList;
    }
    return _screening;
}

@end
