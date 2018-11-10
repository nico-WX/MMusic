//
//  DataStore+Rating.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/10.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "DataStore.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataStore (Rating)

// ->
- (void)ratingForCatalog;
- (void)ratingForLibrary;
@end

NS_ASSUME_NONNULL_END
