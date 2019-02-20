//
//  SearchResultsDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//


#import "SearchResultsDataSource.h"
#import <UIKit/UIKit.h>

#import "ResponseRoot.h"
#import "SearchHistoryManageObject.h"
#import "CoreDataStack.h"
#import "DataManager.h"

@interface SearchResultsDataSource ()<UITableViewDataSource>

@property(nonatomic, strong)NSArray<NSDictionary<NSString*,ResponseRoot*>*> *searchResults;
@end

@implementation SearchResultsDataSource

#pragma mark - help method

- (void)searchTerm:(NSString *)term{

    [self clearDataSource];
    if ([term length] > 0) {
        [self searchDataForTemr:term completion:^(BOOL success) {
            if (success) {
                [self.tableView reloadData];
            }
        }];
        // 记录搜索j历史
        [[DataManager shareDataManager] addSearchHistory:term];
    }
}

// 搜索结果  json
- (void)searchDataForTemr:(NSString *)term completion:(nonnull void (^)(BOOL success))completion{

    [[MusicKit new].catalog searchForTerm:term callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        json = [json valueForKey:@"results"];
        //检查结果返回空结果字典
        if (json.allKeys.count > 0)  {

            NSMutableArray<NSDictionary<NSString*,ResponseRoot*>*> *resultsList = [NSMutableArray array];
            //解析字典
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                //过滤
                if ([key isEqualToString:@"songs"] || [key isEqualToString:@"music-videos"] || [key isEqualToString:@"albums"] || [key isEqualToString:@"playlists"]) {
                    ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                    [resultsList addObject:@{(NSString*)key:root}];
                }
            }];
            self.searchResults = resultsList;
        }else{

            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *title = [NSString stringWithFormat:@"没有搜索内容: %@",term];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:term preferredStyle:UIAlertControllerStyleAlert];

                UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
                [keyWindow.rootViewController presentViewController:alert animated:YES completion:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [alert dismissViewControllerAnimated:YES completion:nil];
                    });
                }];
            });
        }

        if (completion) {
            mainDispatch(^{
                completion(self.searchResults.count > 0);
            });

        }
    }];
}

- (NSString *)titleAtSection:(NSUInteger)section{
    NSDictionary<NSString*,ResponseRoot*> *dict = [self.searchResults objectAtIndex:section];
    return [dict allKeys].firstObject;
}
- (ResponseRoot *)dataWithSection:(NSUInteger)section{
    NSDictionary<NSString*,ResponseRoot*> *dict = [self.searchResults objectAtIndex:section];
    return [dict allValues].firstObject;
}
- (NSArray<Resource *> *)allResurceAtSection:(NSUInteger)section{
    NSDictionary<NSString*,ResponseRoot*> *dict = [self.searchResults objectAtIndex:section];
    return dict.allValues.firstObject.data;
}
- (void)clearDataSource{
    self.searchResults = @[];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.searchResults count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary<NSString*,ResponseRoot*> *temp = [[self searchResults] objectAtIndex:section];
    return [[[[temp allValues] firstObject] data] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.identifier];
    ResponseRoot *root = [self dataWithSection:indexPath.section];
    Resource *resource = [root.data objectAtIndex:indexPath.row];
    [self configureCell:cell item:resource atIndexPath:indexPath];
    return cell;
}

@end
