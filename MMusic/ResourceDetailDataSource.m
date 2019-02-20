//
//  ResourceDetailDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/22.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ResourceDetailDataSource.h"
#import "Song.h"

@interface ResourceDetailDataSource ()<UITableViewDataSource>
@property(nonatomic,strong) Resource *resource;

@end

@implementation ResourceDetailDataSource


- (instancetype)initWithTableView:(UITableView *)tableView
                       identifier:(NSString *)identifier
                         resource:(Resource *)resource
                         delegate:(id<DataSourceDelegate>)delegate{
    if (self = [super initWithTableView:tableView identifier:identifier sectionIdentifier:nil delegate:delegate]) {
        _resource = resource;


        [self loadDataWithResource:resource completion:^(BOOL success) {
            if (self.songLists.count == 0) {
                // 无内容HUD
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"内容不存在" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                UIAlertController *alertController = [[UIAlertController alloc] init];
                [alertController addAction:action];
                UIViewController *root = [[UIApplication sharedApplication].keyWindow rootViewController];
                [root presentViewController:alertController animated:YES completion:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alertController dismissViewControllerAnimated:YES completion:nil];
                    });
                }];
            }

            [self.tableView reloadData];
        }];
    }
    return self;
}
-(void)clearDataSource{
    _songLists = @[];
    [self.tableView reloadData];
}
- (void)reloadDataSource{
    _songLists = @[];
    [self loadDataWithResource:_resource completion:^(BOOL success) {
        [self.tableView reloadData];
    }];
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
    if (completion) {

    }
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
    if ([_delegate respondsToSelector:@selector(configureCell:object:atIndex:)]) {
        Song *song = [self.songLists objectAtIndex:indexPath.row];
        [_delegate configureCell:cell object:song atIndex:indexPath.row];
    }
    return cell;
}

@end
