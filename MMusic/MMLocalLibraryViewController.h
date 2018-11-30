//
//  MMLocalLibraryViewController.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/30.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MMLocalLibraryData;
@interface MMLocalLibraryViewController : UIViewController
@property(nonatomic, strong, readonly) MMLocalLibraryData *localLibraryData;
- (instancetype)initWithLocalLibraryData:(MMLocalLibraryData*)localData;
@end

NS_ASSUME_NONNULL_END
