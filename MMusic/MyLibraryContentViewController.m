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
#import "LikeSongCell.h"

#import "MyLikeSongDataSource.h"
#import "LibraryDataSource.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPMusicPlayerController+ResourcePlaying.h"
#import "Song.h"

@interface MyLibraryContentViewController ()<UICollectionViewDelegate,LibraryDataSourceDelegate,MyLikeSongDataSourceDelegate,UITableViewDelegate>
@property(nonatomic,assign) LibraryContentType type;

@property(nonatomic,strong)UITableView *tableView;
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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.


    //数据源
    switch (_type) {
        case LibraryMyLikeSongType:
            _myLikeDataSource = [[MyLikeSongDataSource alloc] initWithTableVoew:self.tableView identifier:identifier delegate:self];
            break;

        case LibraryAlbumType:{
            MPMediaQuery *query = [MPMediaQuery albumsQuery];
            _libraryDataSource = [[LibraryDataSource alloc] initWithCollectionView:self.collectionView identifier:identifier mediaQuery:query delegate:self];
        }
            break;

        case LibrarySongType:{
            MPMediaQuery *query = [MPMediaQuery songsQuery];
            _libraryDataSource = [[LibraryDataSource alloc] initWithTableView:self.tableView identifier:identifier mediaQuery:query delegate:self];

            //MPMusicPlayerMediaItemQueueDescriptor *qd = [[MPMusicPlayerMediaItemQueueDescriptor alloc] initWithQuery:query];
//            [MainPlayer setQueueWithQuery:query];
//            [MainPlayer play];

        }
            break;

        case LibraryPlaylistType:{
            MPMediaQuery *query = [MPMediaQuery playlistsQuery];
            _libraryDataSource = [[LibraryDataSource alloc] initWithCollectionView:self.collectionView identifier:identifier mediaQuery:query delegate:self];
        }
            break;
        case LibraryPodcastsType:{
            MPMediaQuery *query = [MPMediaQuery podcastsQuery];
            [query setGroupingType:MPMediaGroupingPodcastTitle];
            _libraryDataSource = [[LibraryDataSource alloc] initWithCollectionView:self.collectionView identifier:identifier mediaQuery:query delegate:self];
        }
            break;
    }

    switch (_type) {
        case LibraryMyLikeSongType:
        case LibrarySongType:
        case LibraryPodcastsType:
            [self.view addSubview:self.tableView];
            break;

        case LibraryAlbumType:
        case LibraryPlaylistType:
            [self.view addSubview:self.collectionView];
            break;
    }


}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    switch (_type) {
        case LibrarySongType:
        case LibraryMyLikeSongType:
        case LibraryPodcastsType:
            [self.tableView setFrame:self.view.bounds];
            break;

        case LibraryPlaylistType:
        case LibraryAlbumType:
            [self.collectionView setFrame:self.view.bounds];
            break;
    }
}

#pragma mark - getter / setter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat w = CGRectGetWidth(self.view.bounds)/2 - 24;
        CGFloat h = w+40;
        [_layout setItemSize:CGSizeMake(w, h)];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        [_collectionView setBackgroundColor:UIColor.whiteColor];
        [_collectionView registerClass:[ResourceCollectionCell class] forCellWithReuseIdentifier:identifier];
        //[_collectionView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];

        [_collectionView setDelegate:self];
    }
    return _collectionView;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[LikeSongCell class] forCellReuseIdentifier:identifier];
        //[_tableView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        [_tableView setRowHeight:66];
        [_tableView setDelegate:self];
    }
    return _tableView;
}


#pragma mark - LibraryDataSourceDelegate
//-(void)configureCell:(UICollectionViewCell *)cell object:(MPMediaItem *)item{
//    if ([cell isKindOfClass:[ResourceCollectionCell class]]) {
//        [((ResourceCollectionCell*)cell) setMediaItem:item];
//    }
//}
- (void)configureTableViewCell:(UITableViewCell *)cell object:(MPMediaItem *)item{
    if ([cell isKindOfClass:[LikeSongCell class]]) {
        LikeSongCell *likeCell = (LikeSongCell*)cell;
        [likeCell setMediaItem:item];
    }
}

- (void)configureCollectionCell:(nonnull UICollectionViewCell *)cell object:(nonnull MPMediaItem *)item {
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
- (void)configureTableCell:(UITableViewCell *)cell songManageObject:(SongManageObject *)song{
    if ([cell isKindOfClass:[LikeSongCell class]]) {
        LikeSongCell *songCell = (LikeSongCell*)cell;
        [songCell setSongManageObject:song];
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray<SongManageObject*> *array = [self.myLikeDataSource songList];

    NSMutableArray<Song*> *songArray = [NSMutableArray array];
    for (SongManageObject *smo in array) {
        Song *song = [Song instanceWithSongManageObject:smo];
        [songArray addObject:song];
    }
    [MainPlayer playSongs:songArray startIndex:indexPath.row];
}
@end
