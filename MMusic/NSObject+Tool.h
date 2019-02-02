//
//  NSObject+Tool.h
//  MMusic
//
//  Created by Magician on 2017/12/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Album;
@class Artist;
@class Activity;
@class AppleCurator;
@class Curator;
@class Song;
@class Station;
@class Playlist;
@class MusicVideo;
@class Resource;
@class ResponseRoot;
@class MPMusicPlayerPlayParametersQueueDescriptor;

/**数据回调声明*/
typedef void(^RequestCallBack)(NSDictionary* json, NSHTTPURLResponse* response);

//
////状态码映射
//typedef NS_ENUM(NSUInteger, NSInteger) {
//    <#MyEnumValueA#>,
//    <#MyEnumValueB#>,
//    <#MyEnumValueC#>,
//};


@interface NSObject (Tool)

/**
统一处理响应头信息,处理授权Token 解析响应体 并返回字典(如果有返回)
 */
- (NSDictionary*_Nullable)serializationDataWithResponse:(NSURLResponse* _Nullable)response data:(NSData*_Nullable)data error:(NSError*_Nullable)error;

/**
 封装请求操作 通过回调返回json数据
 */
- (void)dataTaskWithRequest:(NSURLRequest*)request handler:(RequestCallBack)handle;

/**
 通过Path 显示图片到ImageView 上, URL(未替换大小参数url)
 */
- (void)showImageToView:(UIImageView*)imageView withImageURL:(NSString*)url cacheToMemory:(BOOL)cache;

/**
 主屏幕显示提示信息

@param text 显示的文本信息
 */
- (void)showHUDToMainWindowFromText:(NSString*)text;

@end


