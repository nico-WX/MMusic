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
        return;
    }

    SongManageObject *addSong = [[SongManageObject alloc] initWithSong:song];
    NSAssert(addSong, @"生成托管对象失败");
    NSError *saveError = nil;
    BOOL success = [moc save:&saveError];
    if (success) {
        NSLog(@"成功!");
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
    NSArray *fetchObjects = [moc executeFetchRequest:fetch error:&fetchError];

    //匹配播放参数ID, 删除
    for (SongManageObject *sqlSong in fetchObjects) {
        NSString *lID = song.attributes.playParams[@"id"];
        NSString *sqlID = sqlSong.playParams[@"id"];
        if ([lID isEqualToString:sqlID]) {
            [moc deleteObject:sqlSong];
            NSLog(@"删除成功");
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

@end
