//
//  ModelController.m
//  MMusic
//
//  Created by Magician on 2018/5/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ModelController.h"
#import "ResponseRoot.h"
#import "ContentViewController.h"

@interface ModelController()
@property(nonatomic, strong, readonly) NSArray<NSDictionary<NSString*, ResponseRoot*>*> *data;

@end

@implementation ModelController
-(instancetype)initWithData:(NSArray<NSDictionary<NSString *,ResponseRoot *> *> *)data{
    if (self = [super init]) {
        _data = data;
    }
    return self;
}

-(ContentViewController *)viewControllerAtIndex:(NSUInteger)index{
    if ((index >= self.data.count) || (self.data.count==0)) {
        return nil;
    }
    return [[ContentViewController alloc] initWithResourceDict:[self.data objectAtIndex:index]];
}
- (NSUInteger)indexOfViewController:(ContentViewController *)viewController{
    return [self.data indexOfObject:viewController.resourceDict];
}


@end
