//
//  SearchViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/8.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <UIImageView+WebCache.h>
#import <VBFPopFlatButton.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry.h>

#import "HintsViewController.h"

#import "SearchViewController.h"
#import "ResultsViewController.h"
#import "DetailViewController.h"
#import "SearchSectionWaitingHeader.h"
#import "SearchSectionWaitingFooter.h"
#import "WaitingCell.h"
#import "RequestFactory.h"
#import "PlayerViewController.h"

#import "Artwork.h"
#import "Activity.h"
#import "Artist.h"
#import "AppleCurator.h"
#import "Album.h"
#import "Curator.h"
#import "Song.h"
#import "Playlist.h"
#import "MusicVideo.h"
#import "Station.h"

@interface SearchViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UISearchBar *serachBar;

//搜索栏候选数据
@property(nonatomic, strong) NSArray<NSArray*> *allSearchDatas;
@property(nonatomic, strong) NSArray<NSString*> *titles;
@property(nonatomic, strong) UITableView *tableView;
/**搜索暗示*/
@property(nonatomic, strong) NSArray<NSString*> *hints;

@property(nonatomic, assign) CGFloat navigationH;
@property(nonatomic, assign) CGFloat statusH;
@property(nonatomic, assign) CGFloat searchBarH;

@property(nonatomic, strong) PlayerViewController *playerVC;

@property(nonatomic, strong) NSString *previousSearchText;
@end

static NSString *const cellId = @"SearchViewCell";
static NSString *const headerId = @"haderSectionReuseId";
@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"1d3332" alpha:1.0f];

    self.navigationH = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    self.statusH = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame);


    self.serachBar = ({
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
        CGFloat w = CGRectGetWidth(self.view.frame);
        CGFloat h = 44.0f;
        CGRect rect = CGRectMake(x, y, w, h);

        UISearchBar *bar = [[UISearchBar alloc] initWithFrame:rect];
        bar.delegate = self;
        bar.barTintColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];

        [self.view addSubview:bar];
        bar;
    });
    self.searchBarH = CGRectGetHeight(self.serachBar.bounds);

    //搜索候选栏
    //点击搜索栏时, 从搜索栏下部向下拉伸显示
    self.tableView = ({
        CGFloat x = 0;
        CGFloat y = CGRectGetMaxY(self.serachBar.frame);
        CGFloat w = CGRectGetWidth(self.view.frame);
        CGFloat h = 0;
        CGRect rect = CGRectMake(x, y, w, h);

        UITableView *view = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        //注册重用
        [view registerClass:[WaitingCell class] forCellReuseIdentifier:cellId];
        [view registerClass:[SearchSectionWaitingHeader class] forHeaderFooterViewReuseIdentifier:headerId];

        view.dataSource = self;
        view.delegate = self;
        view.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0];;


        [self.view addSubview:view];
        view;
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}


#pragma mark UISearchBarDelegate
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    searchBar.showsCancelButton = YES;

    //监听键盘弹出, 获取键盘高度,修改TableView Frame
    __weak typeof(self) weakSelf = self;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    //键盘Frame改变, 同时更改TableViewFrame
    [center addObserverForName:UIKeyboardWillChangeFrameNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSDictionary *info = note.userInfo;
        NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGFloat keyboardH = CGRectGetHeight(value.CGRectValue);
        CGRect rect = weakSelf.tableView.frame;
        rect.size.height = CGRectGetHeight(weakSelf.view.frame) - CGRectGetMinY(rect) - keyboardH;
        [UIView animateWithDuration:0.7 animations:^{
            weakSelf.tableView.frame = rect;
        }];
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchText:searchText];
    self.previousSearchText = searchText;

}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self searchText:searchBar.text];
    self.previousSearchText = searchBar.text;

    CGFloat tabBarH = CGRectGetHeight(self.tabBarController.tabBar.frame);
    CGRect rect = self.tableView.frame;
    rect.size.height = CGRectGetHeight(self.view.frame) - CGRectGetMinY(rect) - tabBarH;
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.frame = rect;
    }];
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    CGRect rect = self.tableView.frame;
    rect.size.height = 0;
    [UIView animateWithDuration:0.7 animations:^{
        self.tableView.frame = rect;
    }];
}

-(void) requestHints:(NSString*) term{
    NSURLRequest *request = [[RequestFactory requestFactory] createSearchHintsWithTerm:term];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
            self.hints = [json valueForKeyPath:@"results.terms"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

#pragma mark  tool method
- (void) searchText:(NSString*) text{
    if ([text isEqualToString:self.previousSearchText]) {
        return;
    }

    NSURLRequest *request = [[RequestFactory requestFactory] createSearchWithText:text];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
            if (json) {
                [self serializatonJSON:json];
            }
        }
    }];
}

-(void) serializatonJSON:(NSDictionary*) json{
    json = [json objectForKey:@"results"];
    NSMutableArray *tempAll = NSMutableArray.new;   //所有数据
    NSMutableArray *sectionTitle = NSMutableArray.new;  //节title
    NSMutableDictionary *nextPage = [NSMutableDictionary dictionary];   //部分数据有分页, 记录

    //返回的JSON 不确定内容 使用枚举器
    for ( NSEnumerator *rator in [json keyEnumerator]) {
        [sectionTitle addObject:(NSString*)rator];
        NSDictionary *subJSON = [json objectForKey:rator];
        NSMutableArray *tempSection = NSMutableArray.new;
        //记录分页地址
        if ([subJSON objectForKey:@"next"]) [nextPage setObject:[subJSON objectForKey:@"next"] forKey:(NSString*)rator];
        for (NSDictionary *dict in [subJSON objectForKey:@"data"]) {
            //activities, artists, apple-curators, albums, curators, songs, playlists, music-videos,  stations.
            Class cls =  [self classForResourceType:[dict objectForKey:@"type"]];
            [tempSection addObject:[cls instanceWithDict:[dict objectForKey:@"attributes"]]];
        }
        [tempAll addObject:tempSection];
    }

    self.allSearchDatas = tempAll;
    self.titles         = sectionTitle;

    //刷新
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


-(void) loadNextPageFromPagePath:(NSString*) nextPage{
    NSURLRequest *request = [[RequestFactory requestFactory] createRequestWithHerf:nextPage];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
            if (json) {
                [self serializatonJSON:json];
            }
        }
    }];
}

#pragma mark 搜索栏候选表视图 Data Source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.allSearchDatas.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.allSearchDatas objectAtIndex:section].count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WaitingCell *cell = (WaitingCell*)[tableView dequeueReusableCellWithIdentifier:cellId];
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.8];

    id obj = [[self.allSearchDatas objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    cell.name.text = [obj valueForKey:@"name"];

    if ([obj respondsToSelector:@selector(artistName)]) {
        NSString *artist = [obj valueForKey:@"artistName"];
        cell.artistName.text = artist;
    }else{
        cell.artistName.text = nil;
    }

    if ([obj respondsToSelector:@selector(artwork)]) {
        Artwork *artwork = [obj valueForKey:@"artwork"];
        NSString *path = IMAGEPATH_FOR_URL(artwork.url);
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        if (image) {
            cell.artworkView.image = image;
        }else{
            CGFloat h = CGRectGetHeight(cell.contentView.bounds);
            CGFloat w = h;
            NSString *urlPath = [self stringReplacingOfString:artwork.url height:h width:w];
            NSURL *url = [NSURL URLWithString:urlPath];
            [cell.artworkView sd_setImageWithURL:url];
        }
    }
    return cell;
}

#pragma mark 候选列表头脚
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 25.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   return 44.0f;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    SearchSectionWaitingHeader *header = (SearchSectionWaitingHeader*)[tableView dequeueReusableHeaderFooterViewWithIdentifier:headerId];
    NSString *title = [self.titles objectAtIndex:section];
    header.titleLabel.text = title;
    header.contentView.backgroundColor = UIColor.whiteColor;
    return header;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.serachBar resignFirstResponder];
    id obj = [[self.allSearchDatas objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    //activities, -artists, apple-curators, albums, curators, -songs, -playlists, music-videos, and stations.

    //歌曲直接播放
    if ([obj isKindOfClass:Song.class]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Song *song = (Song*)obj;
            MPMusicPlayerPlayParameters *parameters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:song.playParams];
            MPMusicPlayerPlayParametersQueueDescriptor *queue;
            queue = [[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:@[parameters,]];

            self.playerVC = [PlayerViewController sharePlayerViewController];
            [self.playerVC.playerController setQueueWithDescriptor:queue];
            [self.playerVC.playerController play];
            self.playerVC.nowPlaySong = song;
            self.playerVC.songs = [self.allSearchDatas objectAtIndex:indexPath.section];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:self.playerVC animated:YES completion:nil];
            });
        });

    }
    //播放列表/专辑 显细节
    if ([obj isKindOfClass:Album.class] || [obj isKindOfClass:Playlist.class]) {
        DetailViewController *detail = [[DetailViewController alloc] initWithResource:obj];
        [self.navigationController pushViewController:detail animated:YES];
    }

    //选中艺人 弹出结果视图
    if ([obj isKindOfClass:Artist.class]) {
        ResultsViewController *resultsVC = [[ResultsViewController alloc] initWithArtist:(Artist *)obj];
        [self.navigationController pushViewController:resultsVC animated:YES];
    }
}



@end
