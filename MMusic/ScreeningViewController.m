//
//  ScreeningViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ScreeningViewController.h"

@interface ScreeningViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSArray<NSArray<NSString*>*> *screening;
@end

static NSString *const cellID = @"cellReuseIdentifier";
@implementation ScreeningViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UICollectionView DataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.screening.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.screening objectAtIndex:section].count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    return cell;
}

#pragma mark - UICollectionView Delegate

#pragma mark - getter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = UICollectionViewFlowLayout.new;

        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}
-(NSArray<NSArray<NSString *> *> *)screening{
    if (!_screening) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"screening" ofType:@"plist"];
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];
        NSMutableArray *rootList = NSMutableArray.new;
        NSMutableArray *sectionList = NSMutableArray.new;
        [root enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [(NSArray*)obj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [sectionList addObject:obj];
            }];
            Log(@"sec=%@",sectionList);
            [rootList addObject:sectionList];
        }];
        _screening = rootList;
    }


    return _screening;
}

@end
