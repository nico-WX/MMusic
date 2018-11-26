//
//  MMSongListData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/23.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMSongListData.h"
#import "Song.h"

@interface MMSongListData()
@property(nonatomic, strong)NSArray<Song*> *songs;
@end

@implementation MMSongListData

- (NSArray<Song*> *)songList{
    return _songs;
}
- (NSInteger)songCount{
    return _songs.count;
}

- (Song *)songWithIndex:(NSInteger)index{
    return [self.songs objectAtIndex:index];
}
- (void)resourceDataWithResource:(Resource *)resource completion:(nonnull void (^)(BOOL))completion{
    [MusicKit.new.catalog songListWithResource:resource completion:^(NSDictionary *json, NSHTTPURLResponse *response) {
        self.songs = [self serializationJSON:json];
        if (completion) {
            completion(self.songs.count > 0);
        }
    }];
}

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
            Song *song = [Song instanceWithDict:[songDict objectForKey:@"attributes"]];
            [songList addObject:song];
        }
    }
    return songList;
}


// -(void) loadNextPageDataWithHref:(NSString*) href{
//     NSURLRequest *request = [self createRequestWithHref:href];
//     [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
//         json =[json valueForKeyPath:@"results.songs"];
//
//         //覆盖next url,  增加song
//         self.responseRoot.next = [json valueForKey:@"next"];
//         for (NSDictionary *dict in [json valueForKey:@"data"]) {
//             Song *song = [Song instanceWithDict:[dict valueForKey:@"attributes"]];
//             self.songs = [self.songs arrayByAddingObject:song];
//         }
//         dispatch_async(dispatch_get_main_queue(), ^{
//             [self.tableView.mj_footer endRefreshing];
//             [self.tableView reloadData];
//         });
//     }];
// }



@end
