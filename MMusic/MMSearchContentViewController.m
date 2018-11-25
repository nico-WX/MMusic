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

#import "MMSearchContentCell.h"
#import "MMSearchContentSongCell.h"
#import "MMSearchContentArtistsCell.h"
#import "MMSearchContentMusicVideosCell.h"

@interface MMSearchContentViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

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

    if ([cell isKindOfClass:MMSearchContentCell.class]) {
        ((MMSearchContentCell*)cell).resource = [self.responseRoot.data objectAtIndex:indexPath.row];
    }


    [cell setBackgroundColor:UIColor.yellowColor];

    return cell;
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setScrollDirection:UICollectionViewScrollDirectionVertical];

        UIEdgeInsets padding = UIEdgeInsetsMake(0, 4, 0, 4);
        CGRect frame = self.view.frame;
        frame.origin.x +=padding.left;
        frame.size.width -= (padding.left+padding.right);
    
        _collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];

        //[_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
        [_collectionView setDelegate:self];
        [_collectionView setDataSource:self];
        [_collectionView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];

        // 不同的类型注册不同的cell 及设置不同的大小
        ({
            CGFloat w = CGRectGetWidth(frame);
            CGFloat h = 0;

            if ([self.title isEqualToString:@"artists"]) {
                [_collectionView registerClass:[MMSearchContentArtistsCell class] forCellWithReuseIdentifier:cellID];
                h = 66.0;

            }else if ([self.title isEqualToString:@"songs"]) {
                [_collectionView registerClass:[MMSearchContentSongCell class] forCellWithReuseIdentifier:cellID];
                h = 60;

            }else if ([self.title isEqualToString:@"music-videos"]) {
                [_collectionView registerClass:[MMSearchContentMusicVideosCell class] forCellWithReuseIdentifier:cellID];
                h = 74;
            }else{
                [_collectionView registerClass:[MMSearchContentCell class] forCellWithReuseIdentifier:cellID];
                h = 74;
            }

            [layout setItemSize:CGSizeMake(w, h)];
        });


    }
    return _collectionView;
}


@end
