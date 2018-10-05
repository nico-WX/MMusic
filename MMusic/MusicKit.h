//
//  MusicKit.h
//  MMusic
//
//  Created by Magician on 2018/6/25.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "API.h"

@interface MusicKit : NSObject
/*
 *api            接口为不需要用户Token;
 *api.library    接口需要用户Token;
 */
@property(nonatomic, strong) API *api;
@end
