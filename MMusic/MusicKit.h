//
//  MusicKit.h
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Catalog.h"

#import "Library.h"
#import "Library+Rating.h"
#import "Library+iCloud.h"

@interface MusicKit : NSObject

/**资源入口*/
@property(nonatomic, readonly) Catalog *catalog;
@property(nonatomic, readonly) Library *library;
@end
