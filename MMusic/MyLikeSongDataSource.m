//
//  MyLikeSongDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/4.
//  Copyright © 2019 com.😈. All rights reserved.
//


#import "MyLikeSongDataSource.h"
#import "DataManager.h"
#import "CoreDataStack.h"

@interface MyLikeSongDataSource ()<UITableViewDataSource>
@property(nonatomic,copy)NSString *identifier;
@property(nonatomic,weak)id<MyLikeSongDataSourceDelegate> delegate;
@property(nonatomic,strong)UITableView *tableView;

@end

@implementation MyLikeSongDataSource

- (instancetype)initWithTableVoew:(UITableView *)tableView identifier:(NSString *)identifier delegate:(id<MyLikeSongDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _tableView = tableView;
        [_tableView setDataSource:self];
        _identifier = identifier;
        _delegate = delegate;

        // 监听coreData栈变化, 重新加载
        [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {

            [self loadDataWithCompletion:^{
                mainDispatch(^{
                    [tableView reloadData];
                });
            }];
        }];

        [self loadDataWithCompletion:^{
            mainDispatch(^{
                [tableView reloadData];
            });
        }];
    }
    return self;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// 从core Data 加载数据
- (void)loadDataWithCompletion:(void(^)(void))completion{
    // 加载数据
    [[DataManager shareDataManager] fetchAllSong:^(NSArray<SongManageObject *> * _Nonnull songArray) {
        self->_songList = songArray;
        completion();
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.songList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier];
    if ([_delegate respondsToSelector:@selector(configureTableCell:songManageObject:)]) {
        [_delegate configureTableCell:cell songManageObject:[self.songList objectAtIndex:indexPath.row]];
    }
    return cell;
}

@end
