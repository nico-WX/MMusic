//
//  SearchHistoryManageObject.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/29.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ManagedObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchHistoryManageObject : ManagedObject

@property(nonatomic,copy)NSString *term;
@property(nonatomic,strong)NSDate *date;

+ (instancetype)insertTerm:(NSString*)term;
- (instancetype)initWithTerm:(NSString*)term;
@end

NS_ASSUME_NONNULL_END
