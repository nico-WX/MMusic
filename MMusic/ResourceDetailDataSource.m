//
//  ResourceDetailDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/22.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <JGProgressHUD.h>
#import "ResourceDetailDataSource.h"
#import "Song.h"

@interface ResourceDetailDataSource ()<UITableViewDataSource>
@property(nonatomic,strong) Resource *resource;
@property(nonatomic,strong) JGProgressHUD *hud;
@end


@implementation ResourceDetailDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
                       identifier:(NSString *)identifier
                         resource:(Resource *)resource
                         delegate:(id<DataSourceDelegate>)delegate{
    if (self = [super initWithTableView:tableView identifier:identifier sectionIdentifier:nil delegate:delegate]) {
        _resource = resource;

        [self loadDataForTableView:tableView withResource:resource completion:^{
            [self.tableView reloadData];
        }];
    }
    return self;
}

#pragma instance method
-(void)clearDataSource{
    _songLists = @[];
    [self.tableView reloadData];
}
- (void)reloadDataSource{
    _songLists = @[];
    [self loadDataForTableView:self.tableView withResource:self.resource completion:^{
        [self.tableView reloadData];
    }];
}

# pragma mark - laod data
- (void)loadDataForTableView:(UITableView*)tableView withResource:(Resource*)resource completion:(void(^)(void))completion{

    [MusicKit.new.catalog songListWithResource:resource completion:^(NSDictionary *json, NSHTTPURLResponse *response) {
        self->_songLists = [self serializationJSON:json];
        mainDispatch(^{
            completion();
            //无数据显示HUD
            if (self->_songLists.count == 0) {
                [self.hud showInView:tableView animated:YES];
                [self.hud dismissAfterDelay:1.35];
            }
        });
    }];
}
- (JGProgressHUD *)hud{
    if (_hud) {
        _hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleExtraLight];
        _hud.textLabel.text = @"资源存在";
        _hud.indicatorView = nil;
    }
    return _hud;
}
- (void)loadDataWithResource:(Resource *)resource completion:(nonnull void (^)(BOOL success))completion{
    [MusicKit.new.catalog songListWithResource:resource completion:^(NSDictionary *json, NSHTTPURLResponse *response) {
        self->_songLists = [self serializationJSON:json];
        if (completion) {
            mainDispatch(^{
                completion(self.songLists.count > 0);
            });
        }
    }];
}
//下一页数据
- (void)loadNextPageWithComplection:(void (^)(BOOL))completion{
}

/**解析返回的JSON 数据*/
- (NSArray<Song*>*) serializationJSON:(NSDictionary*)json{
    NSMutableArray<Song*> *songList = [NSMutableArray array];
    for (NSDictionary *temp in [json objectForKey:@"data"]) {
        NSArray *tracks = [temp valueForKeyPath:@"relationships.tracks.data"]; // 部分歌曲只有identifier,type,href
        for (NSDictionary *songDict in tracks) {
            if (![songDict valueForKey:JSONAttributesKey]) {
                // 没有属性内容, 跳出
                break;
            }else{
                Song *song = [Song instanceWithDict:songDict];
                [songList addObject:song];
            }
        }
    }
    return songList;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.songLists.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    Song *song = [self.songLists objectAtIndex:indexPath.row];
    [self configureCell:cell item:song atIndexPath:indexPath];
    return cell;
}

@end
