//
//  MMSearchHistory.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/29.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "SearchHistoryManageObject.h"

@implementation SearchHistoryManageObject
@dynamic date,term;

+ (NSSortDescriptor *)defaultSortDescriptor{
    //日期最新在前面
    return [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
}

+ (instancetype)insertTerm:(NSString *)term{
    return [[self alloc] initWithTerm:term];
}

- (instancetype)initWithTerm:(NSString *)term{
    if (self = [super initWithContext:self.viewContext]) {
        self.date = [NSDate date];
        self.term = term;
    }
    return self;
}

+ (NSString *)entityName{
    return @"SearchHistory";
}


@end
