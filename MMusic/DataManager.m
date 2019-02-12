//
//  DataManager.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/5.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "DataManager.h"

#import "SongManageObject.h"
#import "Song.h"
#import "CoreDataStack.h"

static DataManager *_instance;
@implementation DataManager

+(instancetype)shareDataManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}


- (void)addItem:(Song *)song{
    NSManagedObjectContext *moc = [CoreDataStack shareDataStack].context;

    //查询, 如果已经添加, 跳过
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"%K == %@",@"identifier",song.identifier];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Song"];
    [fetch setPredicate:idPredicate];
    [fetch setReturnsObjectsAsFaults:NO];

    NSError *error = nil;
    NSArray<SongManageObject*> *results = [moc executeFetchRequest:fetch error:&error];
    if (results.count > 0) {
        //已经添加过, 跳过
        return;
    }

    SongManageObject *addSong = [SongManageObject insertSong:song];
    NSAssert(addSong, @"插入Song到CoreData时,生成托管对象失败");
    NSError *saveError = nil;
    BOOL success = [moc save:&saveError];
    if (success) {
        NSLog(@"name:%@  保存成功!",song.name);
    }else{
        NSLog(@"error =%@",saveError);
    }
}
-(void)deleteItem:(Song *)song{
    NSManagedObjectContext *moc = [CoreDataStack shareDataStack].context;
    NSPredicate *namePre = [NSPredicate predicateWithFormat:@"%K == %@",@"identifier",song.identifier];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] initWithEntityName:@"Song"];  // song 实体
    [fetch setPredicate:namePre];
    [fetch setFetchLimit:5];
    [fetch setReturnsObjectsAsFaults:NO]; //返回填充实例,不使用惰值

    NSError *fetchError = nil;
    NSArray<SongManageObject*> *fetchObjects = [moc executeFetchRequest:fetch error:&fetchError];

    //匹配播放参数ID, 删除
    for (SongManageObject *sqlSong in fetchObjects) {
        if ([song.identifier isEqualToString:sqlSong.identifier]) {
            [moc deleteObject:sqlSong];
            NSLog(@"删除 song : %@",sqlSong.name);
        }
    }
}
- (void)fetchAllSong:(void (^)(NSArray<SongManageObject *> * _Nonnull))completion{

    NSManagedObjectContext *moc = [[CoreDataStack shareDataStack] context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];

    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"addDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];

    NSError *error = nil;
    NSArray<SongManageObject*> *fetchedObjects = [moc executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        
    }else{
        completion(fetchedObjects);
    }
}


- (void)addSearchHistory:(NSString *)term{

    //记录 搜索记录
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[SearchHistoryManageObject entityName]];
    NSSortDescriptor *sort = [SearchHistoryManageObject defaultSortDescriptor];
    [request setSortDescriptors:@[sort,]];
    NSManagedObjectContext *moc = [[CoreDataStack shareDataStack] context];

    NSArray<SearchHistoryManageObject*> *results = [moc executeFetchRequest:request error:nil];
    if (results.count > 0) {
        for (SearchHistoryManageObject *history in results) {
            if ([history.term isEqualToString:term]) {
                // 匹配到, 刷新日期, 不再重复添加
                history.date = [NSDate date];
                [moc save:nil];
                return;
            }
        }
    }
    //只添加5 个; 超过5 个, 用最后一个修改数据保存
    if (results.count >= 5) {
        SearchHistoryManageObject *history = results.lastObject;
        history.term = term;
        history.date = [NSDate date];
        NSManagedObjectContext *moc = history.managedObjectContext;
        [moc save:nil];
        return;
    }

    SearchHistoryManageObject *history = [[SearchHistoryManageObject alloc] initWithTerm:term];
    moc = history.managedObjectContext;
    NSError *error = nil;
    if (![moc save:&error]) {
        NSLog(@"error =%@",error);
    }

}
- (void)deleteSearchHistory:(SearchHistoryManageObject *)searchHistoryMO{

    //NSString *label = @"DataManager隔离队列";
    //dispatch_queue_t isolationQueue = dispatch_queue_create([label UTF8String],DISPATCH_QUEUE_CONCURRENT);
}
@end
