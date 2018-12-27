//
//  MMDataStack.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMDataStack.h"
#import <CoreData/CoreData.h>

static MMDataStack *_instance;
@implementation MMDataStack

+ (instancetype)shareDataStack{
    return [[self alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
-(instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        [self setupDataStack];
    });
    return _instance;
}

- (void)setupDataStack{
    // 1.数据文件路径(不使用Container)
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"data"];

    //文件创建与检查
    ({
        NSFileManager *fm = [NSFileManager defaultManager];

        //文件夹
        BOOL dir =  NO;
        BOOL exist = [fm fileExistsAtPath:path isDirectory:&dir];
        if (!(exist && dir)) {
            BOOL success = [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
            if (success) {
                NSAssert(path, @"文件夹创建成功");
            }else{
                NSAssert(path, @"文件夹创建失败");
                abort();
            }
        }

        //文件
        path = [path stringByAppendingPathComponent:@"data.sqlite"];
        exist = [fm fileExistsAtPath:path];
        if (!exist) {
            BOOL success = [fm createFileAtPath:path contents:nil attributes:nil];
            if (success) {
                NSAssert(path, @"创建数据库文件成功");
            }else{
                NSAssert(path, @"创建w数据库文件失败");
                abort();
            }
        }
    });

    //2.Core Data Stack

    // (mo -> context) <- (mom -> psc -> ps)
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom, @"初始化托管对象模型失败");

    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSError *error = nil;
    //file URL
    [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:path] options:nil error:&error];
    if (error) {
        NSAssert(error, @"添加存储失败");
    }

    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setPersistentStoreCoordinator:psc];
}

@end
