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
@property(nonatomic,weak) UITableView *tableView;
@property(nonatomic,weak) id<ResourceDetailDataSourceDelegate> delegate;
@property(nonatomic,copy) NSString *identifier;
@property(nonatomic,strong) Resource *resource;

@end

@implementation ResourceDetailDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
                       identifier:(NSString *)identifier
                         resource:(Resource *)resource
                         delegate:(id<ResourceDetailDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _tableView = tableView;
        _delegate = delegate;
        _identifier = identifier;
        _resource = resource;
        [_tableView setDataSource:self];

        [self loadDataWithResource:resource completion:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
    return self;
}


- (void)loadDataWithResource:(Resource *)resource completion:(nonnull void (^)(BOOL success))completion{
    [MusicKit.new.catalog songListWithResource:resource completion:^(NSDictionary *json, NSHTTPURLResponse *response) {
        self->_songLists = [self serializationJSON:json];
        if (completion) {
            completion(self.songLists.count > 0);
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
        NSArray *tracks = [temp valueForKeyPath:@"relationships.tracks.data"];
        for (NSDictionary *songDict in tracks) {
            Song *song = [Song instanceWithDict:songDict];
            [songList addObject:song];
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
