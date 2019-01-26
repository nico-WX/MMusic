//
//  SearchResultsDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "SearchResultsDataSource.h"
#import "ResponseRoot.h"

@interface SearchResultsDataSource ()<UITableViewDataSource>
@property(nonatomic, weak)UITableView *tableView;
@property(nonatomic, weak)id<SearchResultsDataSourceDelegate> delegate;
@property(nonatomic, copy)NSString *cellIdentifier;
@property(nonatomic, copy)NSString *sectionIdentifier;

@property(nonatomic, strong)NSArray<NSDictionary<NSString*,ResponseRoot*>*> *searchResults;
@end

@implementation SearchResultsDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
                   cellIdentifier:(NSString *)cellIdentifier
                sectionIdentifier:(NSString *)sectionIdentifier
                         delegate:(id<SearchResultsDataSourceDelegate>)delegate{

    if (self = [super init]) {
        _tableView = tableView;
        _cellIdentifier = cellIdentifier;
        _sectionIdentifier = sectionIdentifier;
        _delegate = delegate;

        [_tableView setDataSource:self];
    }
    return self;
}

- (void)searchTerm:(NSString *)term{
    [self searchDataForTemr:term completion:^(BOOL success) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }];
}

- (void)searchDataForTemr:(NSString *)term completion:(nonnull void (^)(BOOL))completion{

    [[MusicKit new].catalog searchForTerm:term callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        json = [json valueForKey:@"results"];
        //检查结果返回空结果字典
        if (json.allKeys.count != 0)  {

            NSMutableArray<NSDictionary<NSString*,ResponseRoot*>*> *resultsList = [NSMutableArray array];
            //解析字典
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                //过滤
                if ([key isEqualToString:@"songs"] || [key isEqualToString:@"music-videos"] || [key isEqualToString:@"albums"] || [key isEqualToString:@"playlists"]) {
                    ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                    [resultsList addObject:@{(NSString*)key:root}];
                }
            }];
            [self setSearchResults:resultsList];
        }

        if (completion) {
            completion(self.searchResults.count > 0);
        }
    }];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.searchResults count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary<NSString*,ResponseRoot*> *temp = [[self searchResults] objectAtIndex:section];
    return [[[[temp allValues] firstObject] data] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellIdentifier];
    if ([_delegate respondsToSelector:@selector(configureCell:object:)]) {
        NSDictionary<NSString*,ResponseRoot*> *temp = [[self searchResults] objectAtIndex:indexPath.section];
        Resource *res = [temp.allValues.firstObject.data objectAtIndex:indexPath.row];
        [_delegate configureCell:cell object:res];
    }

    return cell;
}

@end
