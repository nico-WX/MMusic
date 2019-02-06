//
//  MyLikeSongDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/4.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <MJRefresh.h>
#import "MyLikeSongDataSource.h"

#import "DataManager.h"
#import "CoreDataStack.h"

@interface MyLikeSongDataSource ()<UICollectionViewDataSource>
@property(nonatomic,weak)UICollectionView *collectionView;
@property(nonatomic,copy)NSString *identifier;
@property(nonatomic,weak)id<MyLikeSongDataSourceDelegate> delegate;


@end

@implementation MyLikeSongDataSource

- (instancetype)initWithColleCtionView:(UICollectionView *)view identifier:(NSString *)identifier delegate:(id<MyLikeSongDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _collectionView = view;
        _identifier = identifier;
        _delegate = delegate;

        [view setDataSource:self];

        /
        view.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self loadDataWithCompletion:^{
                mainDispatch(^{
                    [view reloadData];
                });
            }];
        }];

        [self loadDataWithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [view reloadData];
            });
        }];

    }
    return self;
}

// 从core Data 加载数据
- (void)loadDataWithCompletion:(void(^)(void))completion{
    // 加载数据
    [[DataManager shareDataManager] fetchAllSong:^(NSArray<SongManageObject *> * _Nonnull songArray) {
        self->_songList = songArray;
        completion();
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.songList.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];

    if ([_delegate respondsToSelector:@selector(configureCell:songManageObject:)]) {
        [_delegate configureCell:cell songManageObject:[self.songList objectAtIndex:indexPath.row]];
    }
    return cell;
}


@end
