//
//  SearchHistoryDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/20.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "SearchHistoryDataSource.h"
#import "SearchHistoryManageObject.h"
#import "CoreDataStack.h"

@interface SearchHistoryDataSource ()<UITableViewDataSource>
@property(nonatomic,weak)UITableView *tableView;
@property(nonatomic,weak)id<SearchHistoryDataSourceDelegate> delegate;
@property(nonatomic,copy)NSString *identifier;

@property(nonatomic,strong) NSArray<SearchHistoryManageObject*> *termes;
@property(nonatomic,strong) id observer;

@end

@implementation SearchHistoryDataSource

- (instancetype)initWithTableView:(UITableView *)tableView
                       identifier:(NSString *)identifier
                         delegate:(id<SearchHistoryDataSourceDelegate>)delegate{
    if (self = [super init]) {
        _tableView = tableView;
        _tableView.dataSource = self;
        _delegate = delegate;
        _identifier = identifier;

        [self loadDataWithCompletion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                 [tableView reloadData];
            });
        }];


        //监听上下文改变
       _observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                                     object:nil
                                                                      queue:nil
                                                                 usingBlock:^(NSNotification * _Nonnull note)
        {
            [self loadDataWithCompletion:^{
                 [tableView reloadData];
            }];
        }];

    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
    _observer = nil;
}

- (void)loadDataWithCompletion:(void(^)(void))completion{
    NSManagedObjectContext *moc = [CoreDataStack shareDataStack].context;

    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[SearchHistoryManageObject name]];
    NSSortDescriptor *sortDescriptor = [SearchHistoryManageObject defaultSortDescriptor];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];

    NSError *error = nil;
    _termes = [moc executeFetchRequest:fetchRequest error:&error];
    if (_termes == nil) {
        NSLog(@"fetch obje error =%@",_termes);
    }else{
        completion();
    }
}



#pragma mark - dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  self.termes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_identifier];
    if ([_delegate respondsToSelector:@selector(configureCell:object:)]) {
        NSString *term = [self.termes objectAtIndex:indexPath.row].term;
        [_delegate configureCell:cell object:term];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:{
            SearchHistoryManageObject *delete = [_termes objectAtIndex:indexPath.row];
            NSManagedObjectContext *moc = delete.managedObjectContext;
            [moc deleteObject:delete];
            [moc save:nil];
            //直接刷新数据源
            [self loadDataWithCompletion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableView reloadData];
                });
            }];
        }
            break;

        default:
            break;
    }
}
@end
