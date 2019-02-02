//
//  LibraryDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "LibraryDataSource.h"
#import <MediaPlayer/MediaPlayer.h>

@interface LibraryDataSource ()<UICollectionViewDataSource>
@property(nonatomic,weak)UICollectionView *collectionView;
@property(nonatomic,weak)id<LibraryDataSourceDelegate> delegate;
@property(nonatomic,copy)NSString *identifier;

@property(nonatomic,strong)MPMediaQuery *query;

@end

@implementation LibraryDataSource

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView identifier:(NSString *)identifier mediaQuery:(MPMediaQuery *)query delegate:(id<LibraryDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _collectionView = collectionView;
        [collectionView setDataSource:self];

        _delegate = delegate;
        _identifier = identifier;
        _query = query;
    }
    return self;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    if (_query.groupingType == MPMediaGroupingPodcastTitle) {
//        NSLog(@">>>>>");
//        return _query.collections.count;
//    }

    return _query.items.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    if ([_delegate respondsToSelector:@selector(configureCell:object:)]) {
        //

        MPMediaItem *item = [_query.items objectAtIndex:indexPath.row];

        [_delegate configureCell:cell object:item];
    }
    return cell;
}

@end
