//
//  SearchHintsDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "SearchHintsDataSource.h"

@interface SearchHintsDataSource ()<UITableViewDataSource>
@property(nonatomic,strong) NSArray<NSString*> *hints;
@end

@implementation SearchHintsDataSource

- (void)searchHintsWithTerm:(NSString *)term{
    [self clearDataSource];
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
    }
}
- (void)clearDataSource{
    self.hints = @[];
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.hints.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    [self configureCell:cell item:[self.hints objectAtIndex:indexPath.row] atIndexPath:indexPath];
    return cell;
}

@end
