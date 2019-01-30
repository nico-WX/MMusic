//
//  MyLibraryContentViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "MyLibraryContentViewController.h"

@interface MyLibraryContentViewController ()<UICollectionViewDelegate>
@property(nonatomic,assign) LibraryType type;

@property(nonatomic,strong)UICollectionView *collectionView;
@property(nonatomic,strong)UICollectionViewFlowLayout *layout;
@end


static NSString *const identifier = @"reuseIdentifier";
@implementation MyLibraryContentViewController

- (instancetype)initWithType:(LibraryType)type{
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

}


#pragma mark - getter / setter
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _layout = [[UICollectionViewFlowLayout alloc] init];

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
        [_collectionView setDelegate:self];
    }
    return _collectionView;
}
@end
