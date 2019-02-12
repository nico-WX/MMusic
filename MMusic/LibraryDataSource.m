//
//  LibraryDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "LibraryDataSource.h"
#import <MediaPlayer/MediaPlayer.h>

@interface LibraryDataSource ()<UICollectionViewDataSource,UITableViewDataSource>
@property(nonatomic,weak)UITableView *tableView;
@property(nonatomic,weak)UICollectionView *collectionView;

@property(nonatomic,weak)id<LibraryDataSourceDelegate> delegate;
@property(nonatomic,copy)NSString *identifier;

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

- (instancetype)initWithTableView:(UITableView *)tableView identifier:(NSString *)identifier mediaQuery:(MPMediaQuery *)query delegate:(id<LibraryDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _tableView = tableView;
        [_tableView setDataSource:self];

        _identifier = identifier;
        _query = query;
        _delegate = delegate;
    }
    return self;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _query.items.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    if ([_delegate respondsToSelector:@selector(configureCollectionCell:object:)]) {
        //
        MPMediaItem *item = [_query.items objectAtIndex:indexPath.row];
        [_delegate configureCollectionCell:cell object:item];
    }
    return cell;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _query.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier];
    if ([_delegate respondsToSelector:@selector(configureTableViewCell:object:)]) {
        MPMediaItem *item = [_query.items objectAtIndex:indexPath.row];
        [_delegate configureTableViewCell:cell object:item];
    }
    return cell;
}
@end
