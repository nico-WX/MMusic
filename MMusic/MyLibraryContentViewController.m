//
//  MyLibraryContentViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "MyLibraryContentViewController.h"

#import "ResourceCollectionCell.h"
#import "SongCollectionCell.h"

#import "MyLikeSongDataSource.h"
#import "LibraryDataSource.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPMusicPlayerController+ResourcePlaying.h"

@interface MyLibraryContentViewController ()<UICollectionViewDelegate,LibraryDataSourceDelegate,MyLikeSongDataSourceDelegate>
@property(nonatomic,assign) LibraryContentType type;

@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;

@property(nonatomic,strong)LibraryDataSource *libraryDataSource;
@property(nonatomic,strong)MyLikeSongDataSource *myLikeDataSource;
@end


static NSString *const identifier = @"reuseIdentifier";
@implementation MyLibraryContentViewController

- (instancetype)initWithType:(LibraryContentType)type{
    if (self = [super init]) {
        _type = type;

        switch (_type) {
            case LibraryLocalSongType:
                self.title = @"本地歌曲";
                break;
            case LibraryMyLikeSongType:
                self.title = @"我喜欢的";
                break;
            case LibraryAlbumType:
                self.title = @"专辑";
                break;
            case LibrarySongType:
                self.title = @"歌曲";
                break;
            case LibraryPlaylistType:
                self.title = @"播放列表";
                break;
            case LibraryPodcastsType:
                self.title = @"广播";
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview:self.collectionView];

    //数据源
    switch (_type) {
        case LibraryLocalSongType:
            break;
        case LibraryMyLikeSongType:
            _myLikeDataSource = [[MyLikeSongDataSource alloc] initWithColleCtionView:_collectionView
                                                                          identifier:identifier
                                                                            delegate:self];
            
            break;
        case LibraryAlbumType:{
            MPMediaQuery *query = [MPMediaQuery albumsQuery];
            _libraryDataSource = [[LibraryDataSource alloc] initWithCollectionView:_collectionView
                                                                        identifier:identifier
                                                                        mediaQuery:query
                                                                          delegate:self];

        }
            break;
        case LibrarySongType:{
            MPMediaQuery *query = [MPMediaQuery songsQuery];
            _libraryDataSource = [[LibraryDataSource alloc] initWithCollectionView:_collectionView
                                                                        identifier:identifier
                                                                        mediaQuery:query
                                                                          delegate:self];
        }

            break;
        case LibraryPlaylistType:{
            MPMediaQuery *query = [MPMediaQuery playlistsQuery];
            _libraryDataSource = [[LibraryDataSource alloc] initWithCollectionView:_collectionView
                                                                        identifier:identifier
                                                                        mediaQuery:query
                                                                          delegate:self];
        }
            break;
        case LibraryPodcastsType:{
            MPMediaQuery *query = [MPMediaQuery podcastsQuery];
            _libraryDataSource = [[LibraryDataSource alloc] initWithCollectionView:_collectionView
                                                                        identifier:identifier
                                                                        mediaQuery:query
                                                                          delegate:self];
        }
            break;
    }

    // cell 样式 和 类型
    switch (_type) {
        case LibrarySongType:
        case LibraryLocalSongType:
        case LibraryPodcastsType:
        case LibraryMyLikeSongType:{
            CGFloat w = CGRectGetWidth(self.view.bounds);
            CGFloat h = 56;

            [_layout setItemSize:CGSizeMake(w, h)];
            [_layout setMinimumLineSpacing:0];
            [_collectionView registerClass:[SongCollectionCell class] forCellWithReuseIdentifier:identifier];
        }
            break;

        case LibraryAlbumType:
        case LibraryPlaylistType:{
            CGFloat w = CGRectGetWidth(self.view.bounds)/2 - 24;
            CGFloat h = w+40;
            [_layout setItemSize:CGSizeMake(w, h)];
            [_collectionView registerClass:[ResourceCollectionCell class] forCellWithReuseIdentifier:identifier];
        }

            break;
    }

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [_collectionView setFrame:self.view.bounds];
}

#pragma mark - getter / setter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        [_layout setItemSize:CGSizeMake(200, 240)];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        [_collectionView setBackgroundColor:UIColor.whiteColor];
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:identifier];

        [_collectionView setDelegate:self];
    }
    return _collectionView;
}

#pragma mark - LibraryDataSourceDelegate
-(void)configureCell:(UICollectionViewCell *)cell object:(MPMediaItem *)item{
    if ([cell isKindOfClass:[ResourceCollectionCell class]]) {
        [((ResourceCollectionCell*)cell) setMediaItem:item];
    }
}
#pragma mark - MyLikeSongDataSourceDelegate
- (void)configureCell:(UICollectionViewCell *)cell songManageObject:(SongManageObject *)song{
    if ([cell isKindOfClass:[ResourceCollectionCell class]]) {
        ((ResourceCollectionCell*)cell).songManageObject = song;
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if (_type == LibraryMyLikeSongType) {
        NSArray<SongManageObject*> *songList = [self.myLikeDataSource songList];
        NSMutableArray<Song*> *songes = [NSMutableArray array];
        for (SongManageObject *songMO in songList) {
            Song *s = [Song instanceWithSongManageObject:songMO];
            [songes addObject:s];
        }
        [MainPlayer playSongs:songes startIndex:indexPath.row];

    }else{

    }

}
@end
