//
//  MMSearchContentViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/25.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMSearchContentViewController.h"
#import "ResponseRoot.h"

@interface MMSearchContentViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *collectionView;
@end

static NSString *const cellID = @" cell reuse identifier";
@implementation MMSearchContentViewController

- (instancetype)initWithResponseRoot:(ResponseRoot *)responseRoot{
    if (self = [super init]) {
        _responseRoot = responseRoot;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view setBackgroundColor:UIColor.redColor];

    [self.view addSubview:self.collectionView];
}
- (void)viewDidLayoutSubviews{

    UIView *superView = self.view;
    UIEdgeInsets padding = UIEdgeInsetsMake(0, 4, 0, 4);
    [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView).insets(padding);
    }];

    [super viewDidLayoutSubviews];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.responseRoot.data.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];

    [cell setBackgroundColor:UIColor.yellowColor];

    return cell;
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {

        CGRect frame = self.view.bounds;
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:[self flowLayout]];

        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setBackgroundColor:UIColor.whiteColor];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout*)flowLayout{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setItemSize:CGSizeMake(414, 60)];

    return layout;
}

@end
