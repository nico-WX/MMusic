//
//  MMLibraryData.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/29.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMModelController.h"

NS_ASSUME_NONNULL_BEGIN


@interface MMLibraryData : MMModelController
@property(nonatomic, strong, readonly)NSArray<NSDictionary<NSString*,ResponseRoot*> *> *results;



@end

NS_ASSUME_NONNULL_END
