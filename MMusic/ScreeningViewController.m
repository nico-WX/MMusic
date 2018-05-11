//
//  ScreeningViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>
#import "ScreeningViewController.h"
#import "ScreeningCell.h"
#import "ScreeningSection.h"

@interface ScreeningViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

//分类数据
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,NSArray*>*> *screening;
@end



static const CGFloat row = 4.0f;        //列数
static const CGFloat miniSpacing= 2.0f; //行距

static NSString *const cellID = @"screeningCellIdentifier";
static NSString *const headerID = @"screeningHeaderIdentitier";
@implementation ScreeningViewController

@synthesize collectionView = _collectionView;

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

-(void)viewDidLayoutSubviews{
    UIView *superview = self.view;
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superview);
    }];
}


#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.screening.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.screening objectAtIndex:section].allValues.firstObject.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ScreeningCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NSString *text = [[self.screening objectAtIndex:indexPath.section].allValues.firstObject objectAtIndex:indexPath.row];
    cell.nameLable.text = text;
    cell.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    return cell;
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    ScreeningSection *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                          withReuseIdentifier:headerID
                                                                                 forIndexPath:indexPath];
    if (header) {
        header.titleLabel.text = [self.screening objectAtIndex:indexPath.section].allKeys.firstObject;
        return header;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectedItem) {
        NSString *text = [[self.screening objectAtIndex:indexPath.section].allValues.firstObject objectAtIndex:indexPath.row];
        self.selectedItem(text);
    }
}

#pragma mark - UICollectionViewDeleGateFlowLayout
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat h = 44.0f;
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    w = w -(row+1)*miniSpacing;
    w = w/row;
    return CGSizeMake(w, h);
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat h = 38.0f;
    CGFloat w = CGRectGetWidth(collectionView.bounds);
    return CGSizeMake(w, h);
}

#pragma mark - getter
-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
        [layout setMinimumInteritemSpacing:miniSpacing];
        [layout setMinimumLineSpacing:miniSpacing];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [_collectionView registerClass:ScreeningCell.class forCellWithReuseIdentifier:cellID];
        [_collectionView registerClass:ScreeningSection.class forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
    }
    return _collectionView;
}

-(NSArray<NSDictionary<NSString*,NSArray*>*> *)screening{
    if (!_screening) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"screening" ofType:@"plist"];
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];

        NSMutableArray<NSDictionary<NSString*,NSArray*>*> *rootList = NSMutableArray.new;
        [root enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary *dict = @{key:obj};
            [rootList addObject:dict];
        }];
        _screening = rootList;
    }
    return _screening;
}



@end
