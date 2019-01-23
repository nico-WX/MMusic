//
//  SearchHistoryDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "SearchHistoryDataSource.h"

@interface SearchHistoryDataSource ()<UITableViewDataSource>
@property(nonatomic,weak)UITableView *tableView;
@property(nonatomic,weak)id<SearchHistoryDataSourceDelegate> delegate;
@property(nonatomic,copy)NSString *identifier;

@property(nonatomic,strong) NSArray<NSString*> *termList;
@end


static NSString *const _historyKey = @"search history key";
@implementation SearchHistoryDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
                       identifier:(NSString *)identifier
                         delegate:(id<SearchHistoryDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _tableView = tableView;
        _delegate = delegate;
        _identifier = identifier;
        tableView.dataSource = self;
        [tableView reloadData];
    }
    return self;
}

- (void)addSearchHistoryTerm:(NSString *)term{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.termList];
    [array addObject:term];

    if (array.count > 5) {
        [array removeObjectAtIndex:0];
    }
    [[NSUserDefaults standardUserDefaults] setValue:array forKey:_historyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    //刷新
    if (self.tableView) {
        self.termList = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.termList count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier];
    if ([_delegate respondsToSelector:@selector(configureCell:object:)]) {
        [_delegate configureCell:cell object:[self.termList objectAtIndex:indexPath.row]];
    }
    return cell;
}

#pragma mark - setter/getter
-(NSArray<NSString *> *)termList{
    if (!_termList) {
         _termList = [[NSUserDefaults standardUserDefaults] valueForKey:_historyKey];
        if (!_termList) {
            _termList = @[@"A",@"B",@"C",@"D",@"E",@"F"];
            //_termList = [NSArray array];
        }
    }

    return _termList;
}

@end
