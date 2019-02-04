//
//  MyLikeSongDataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/4.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MyLikeSongDataSourceDelegate <NSObject>

@end

@interface MyLikeSongDataSource : NSObject

- (instancetype)initWithColleCtionView:(UICollectionView*)view
                            identifier:(NSString*)identifier
                              delegate:(id<MyLikeSongDataSourceDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
