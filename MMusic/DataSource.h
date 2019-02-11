//
//  DataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/7.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DataSourceDelegate <NSObject>
@end

typedef void(^configureTableCellBlock)(id cell, id item, NSIndexPath *atIndexPath);
typedef void(^configureCollectionCellBlock)(id cell, id item);

@interface DataSource : NSObject

@end

NS_ASSUME_NONNULL_END
