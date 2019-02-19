//
//  SearchHintsDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "SearchHintsDataSource.h"

@interface SearchHintsDataSource ()<UITableViewDataSource>
@property(nonatomic,weak)UITableView *tableView;
@property(nonatomic,weak)id<SearchHintsDataSourceDelegate> delegate;
@property(nonatomic,copy)NSString *identifier;
@property(nonatomic,strong) NSArray<NSString*> *hints;
@end

@implementation SearchHintsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView identifier:(NSString *)identifier delegate:(id<SearchHintsDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _tableView = tableView;
        _delegate = delegate;
        _identifier = identifier;

        [tableView setDataSource:self];;
    }
    return self;
}

- (void)searchHintsWithTerm:(NSString *)term{
    if (term.length > 0) {
        [MusicKit.new.catalog searchHintsForTerm:term callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
            NSArray<NSString*> *temp = [json valueForKeyPath:@"results.terms"];
            if (temp.count > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.hints = temp;
                    [self.tableView reloadData];
                });
            }
        }];
    }else{
        [self clearData];
    }
}
- (void)clearData{
    mainDispatch(^{
        self.hints = @[];
        [self.tableView reloadData];
    });
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.hints.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier];
    if ([_delegate respondsToSelector:@selector(configureCell:hintsString:)]) {
        [_delegate configureCell:cell  hintsString:[self.hints objectAtIndex:indexPath.row]];
    }
    return cell;
}

@end
