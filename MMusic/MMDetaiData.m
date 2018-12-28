//
//  MMDetaiData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMDetaiData.h"
#import "MMSongListData.h"

@interface MMDetaiData ()<UITableViewDataSource>
@property(nonatomic, weak) id<DetailDataSourceDelegate> delegate;
@property(nonatomic, copy) NSString *cellIdentifier;
@property(nonatomic, strong) MMSongListData *listData;
@property(nonatomic, strong) Resource *resource;
@end

@implementation MMDetaiData

- (instancetype)initWithTableView:(UITableView *)tableView resource:(Resource*)resource cellIdentifier:(NSString *)cellIdentifier delegate:(id<DetailDataSourceDelegate>)delegate{
    if (self =[super init]) {
        [tableView setDataSource:self];
        _cellIdentifier = cellIdentifier;
        _delegate = delegate;
        _resource = resource;

        _listData = [[MMSongListData alloc] init];
        [_listData resourceDataWithResource:resource completion:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [tableView reloadData];
                }
            });
        }];
    }
    return self;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listData songCount];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier forIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(configureCell:object:withIndex:)]) {
        [self.delegate configureCell:cell object:[self.listData songWithIndex:indexPath.row] withIndex:indexPath.row];
    }
    return cell;
}

- (NSArray<Song *> *)songList{
    return self.listData.songList;
}

@end
