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
@class MPMusicPlayerPlayParametersQueueDescriptor;

@interface NSObject (Tool)

/**通过完整的URL路径 生成请求体 并设置请求头*/
-(NSURLRequest*_Nonnull) createRequestWithURLString:(NSString*_Nonnull) urlString setupUserToken:(BOOL) setupUserToken;

/**设置请求体中的 请求头信息*/
-(void)setupAuthorizationWithRequest:(NSMutableURLRequest *_Nonnull)request setupMusicUserToken:(BOOL)needSetupUserToken;

/**统一处理响应头信息,解析响应体 并返回字典(如果有返回)*/
- (NSDictionary*_Nullable) serializationDataWithResponse:(NSURLResponse* _Nullable ) response data:(NSData*_Nullable) data error:(NSError*_Nullable) error;

/**封装了发起任务操作*/
-(void)dataTaskWithRequest:(NSURLRequest*_Nonnull) request completionHandler:(void(^_Nonnull)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler;

/**替换ImageURL 中的Image大小参数 默认屏幕的缩放大小*/
-(NSString*_Nonnull) stringReplacingOfString:(NSString*_Nonnull) target height:(int) height width:(int) width;

/**模型中的类型 映射到具体的模型类*/
-(Class) classForResourceType:(NSString*)type;

/**16进制颜色转换*/
+(UIColor*)colorWithHexString:(NSString*) hexString alpha:(CGFloat) alpha;
/**补色*/
+ (UIColor *)oppositeColorOf:(UIColor *)mainColor;

/**播放参数字典数组 转换为播放描叙队列*/
-(MPMusicPlayerPlayParametersQueueDescriptor*) playParametersQueueDescriptorFromParams:(NSArray<NSDictionary*>*) playParamses startAtIndexPath:(NSIndexPath*) indexPath;

/**通过Path 显示图片到ImageView 上, URL(未替换大小参数url)*/
-(void)showImageToView:(UIImageView*)imageView withImageURL:(NSString*)url cacheToMemory:(BOOL) cache;

-(void)showHUDToMainWindow;
-(void)showHUDToMainWindowFromText:(NSString*) text;












@end
