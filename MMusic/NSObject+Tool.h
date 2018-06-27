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
@class Activities;
@class AppleCurator;
@class Curator;
@class Song;
@class Station;
@class Playlist;
@class MusicVideo;
@class Resource;
@class ResponseRoot;
@class MPMusicPlayerPlayParametersQueueDescriptor;

@interface NSObject (Tool)

/**
 通过子路径创建请求体

 @param href 子路径
 @return 请求体
 */
- (NSURLRequest*)createRequestWithHref:(NSString*) href;

/**
 通过完整的URL路径 生成请求体 并设置请求头

 @param urlString       请求路径
 @param setupUserToken  是否需要设置用户令牌
 @return                请求体
 */
-(NSURLRequest*_Nonnull) createRequestWithURLString:(NSString*_Nonnull) urlString setupUserToken:(BOOL) setupUserToken;


/**
 设置请求体中的 请求头信息

 @param request 请求体
 @param setupUserToken 是否需要设置用户令牌
 */
-(void)setupAuthorizationWithRequest:(NSMutableURLRequest *_Nonnull)request setupUserToken:(BOOL) setupUserToken;



/**
统一处理响应头信息,解析响应体 并返回字典(如果有返回)

 @param response 响应体
 @param data 响应数据
 @param error 错误信息
 @return Json 字典
 */
- (NSDictionary*_Nullable) serializationDataWithResponse:(NSURLResponse* _Nullable ) response data:(NSData*_Nullable) data error:(NSError*_Nullable) error;


/**
 发起任务请求

 @param request 请求对象
 @param handler 返回数据
 */
//-(void)dataTaskWithRequest:(NSURLRequest*_Nonnull) request completionHandler:(void(^_Nonnull)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler;



/**
 请求直接返回 json数据

 @param request 请求体
 @param block 回调
 */
-(void)dataTaskWithRequest:(NSURLRequest*)request handler:(void(^)(NSDictionary*json,NSHTTPURLResponse*response))block;

/**
 替换ImageURL 中的Image大小参数 默认屏幕的缩放大小

 @param target 要替换的路径
 @param height 图片高度
 @param width 图片宽度
 @return 替换后的请求路径
 */
-(NSString*_Nonnull) stringReplacingOfString:(NSString*_Nonnull) target height:(int) height width:(int) width;


/**
16进制颜色转换 RGBA

 @param hexString 16进制颜色字符串
 @param alpha 透明通道
 @return RGB 颜色
 */
+(UIColor*)colorWithHexString:(NSString*) hexString alpha:(CGFloat) alpha;


/**
 补色

 @param mainColor 主要颜色
 @return 补色
 */
+ (UIColor *)oppositeColorOf:(UIColor *)mainColor;


/**
 播放参数字典数组 转换为播放描叙队列

 @param playParamses 播放参数字典数组
 @param indexPath 开始播放位置
 @return 播放队列
 */
-(MPMusicPlayerPlayParametersQueueDescriptor*) playParametersQueueFromParams:(NSArray<NSDictionary*>*) playParamses startAtIndexPath:(NSIndexPath*) indexPath;


/**
 音乐列表生成播放队列

 @param songs song 列表
 @param index 开始播放音乐下标
 @return 播放队列
 */
-(MPMusicPlayerPlayParametersQueueDescriptor*) playParametersQueueFromSongs:(NSArray<Song*>*) songs startPlayIndex:(NSUInteger) index;


/**
 通过Path 显示图片到ImageView 上, URL(未替换大小参数url)

 @param imageView 要显示的图片视图
 @param url 图片路径
 @param cache 是否缓存到沙盒
 */
-(void)showImageToView:(UIImageView*)imageView withImageURL:(NSString*)url cacheToMemory:(BOOL) cache;



/**
 获取Image

 @param url image地址(未转换参数的地址)
 @param imageSize 图片大小
 @return 图片
 */
-(UIImage*)imageFromURL:(NSString*) url withImageSize:(CGSize) imageSize;

/**
 主屏幕显示提示信息

@param text 显示的文本信息
 */
-(void)showHUDToMainWindowFromText:(NSString*) text;



@end



