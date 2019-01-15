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

    //2.Core Data Stack
    // (mo -> context) <- (mom -> psc -> ps)
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSAssert(mom, @"初始化托管对象模型失败");

    //使用容器实现
    NSPersistentContainer *container = [NSPersistentContainer persistentContainerWithName:@"Model" managedObjectModel:mom];
    [container loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription * _Nonnull storeDescription, NSError * _Nullable error) {
        self->_context = container.viewContext;
    }];

}

@end
