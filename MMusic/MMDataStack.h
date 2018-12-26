//
//  MMDataStack.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMDataStack : NSObject
@property(nonatomic, strong, readonly) NSManagedObjectContext *context;

+ (instancetype)shareDataStack;
@end

NS_ASSUME_NONNULL_END
