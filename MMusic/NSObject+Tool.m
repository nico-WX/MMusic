//
//  NSObject+Tool.m
//  MMusic
//
//  Created by Magician on 2017/12/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//
#import <MBProgressHUD.h>
#import <UIImageView+WebCache.h>
#import "NSObject+Tool.h"
#import "AuthorizationManager.h"
#import <UIKit/UIKit.h>

#import "Album.h"
#import "Artist.h"
#import "Activity.h"
#import "AppleCurator.h"
#import "Curator.h"
#import "Song.h"
#import "Station.h"
#import "Playlist.h"
#import "MusicVideo.h"


extern NSString *developerTokenExpireNotification;
extern NSString *userTokenIssueNotification;
@implementation NSObject (Tool)

//解析响应  如果有返回, 解析Json 数据到字典
-(NSDictionary *)serializationDataWithResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error{

    if (error) Log(@"Location Error:%@",error);
    NSDictionary *dict;
    NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
    switch (res.statusCode) {
        case 200:
            if (data) {
                dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                if (error) Log(@"Serialization Error:%@",error);
            }
            break;
        case 401:
            //开发者Token 问题
            Log(@"授权过期");
            [[NSNotificationCenter defaultCenter] postNotificationName:developerTokenExpireNotification object:nil];
            break;
        case 403:
            //userToken 问题
            [[NSNotificationCenter defaultCenter] postNotificationName:userTokenIssueNotification object:nil];
            break;

        default:
             //Log(@"response info :%@",res);
            break;
    }
    return dict;
}

//封装发起任务请求操作
-(void)dataTaskWithdRequest:(NSURLRequest*) request completionHandler:(void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler{
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        handler(data,response,error);
    }] resume];
}

//替换海报URL中的占位字符串,
-(NSString *)stringReplacingOfString:(NSString *)target height:(int)height width:(int)width{
    //图片大小倍数
    CGFloat times = [UIScreen mainScreen].scale;
    NSString *w = [NSString stringWithFormat:@"%d",(int)((CGFloat)width * times)];
    NSString *h = [NSString stringWithFormat:@"%d",(int)((CGFloat)height * times)]; //注意占位不能是浮点数, 只能是整数, 不然报CFNetwork 385错误
    target = [target stringByReplacingOccurrencesOfString:@"{h}" withString:h];
    target = [target stringByReplacingOccurrencesOfString:@"{w}" withString:w];
    return target;
}

/**设置请求头*/
-(void)setupAuthorizationWithRequest:(NSMutableURLRequest *)request setupMusicUserToken:(BOOL)needSetupUserToken{

    //设置开发者Token 请求头
    NSString *developerToken = [AuthorizationManager shareAuthorizationManager].developerToken;
    if (developerToken) {
        developerToken = [NSString stringWithFormat:@"Bearer %@",developerToken];
        [request setValue:developerToken forHTTPHeaderField:@"Authorization"];
    }else{
        Log(@"无法获得开发者Token!");
    }

    //个性化请求 设置UserToken 请求头
    if (needSetupUserToken == YES) {
        NSString *userToken = [AuthorizationManager shareAuthorizationManager].userToken;
        if (userToken){
            [request setValue:userToken forHTTPHeaderField:@"Music-User-Token"];
            //Log(@"userToken: %@",userToken);
        }else Log(@"无法获得userToken");
    }
}

/**通过urlString 生成请求体 并设置请求头*/
-(NSURLRequest*) createRequestWithURLString:(NSString*) urlString setupUserToken:(BOOL) setupUserToken{
    //转换URL中文及空格 (有二次转码问题)
    //urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    //转码方法2
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:urlString];
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:set];

    NSURL *url = [NSURL URLWithString:encodedString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //设置请求头
    [self setupAuthorizationWithRequest:request setupMusicUserToken:setupUserToken];
    return request;
}

/**模型中的类型 映射*/
-(Class) classForResourceType:(NSString*)type{
    Class cls;
    if ([type isEqualToString:@"activities"])       cls = Activity.class;
    if ([type isEqualToString:@"artists"])          cls = Artist.class;
    if ([type isEqualToString:@"apple-curators"])   cls = AppleCurator.class;
    if ([type isEqualToString:@"albums"])           cls = Album.class;
    if ([type isEqualToString:@"curators"])         cls = Curator.class;
    if ([type isEqualToString:@"songs"])            cls = Song.class;
    if ([type isEqualToString:@"playlists"])        cls = Playlist.class;
    if ([type isEqualToString:@"music-videos"])     cls = MusicVideo.class;
    if ([type isEqualToString:@"stations"])         cls = Station.class;
    return cls;
}

-(void)showImageToView:(UIImageView *)imageView withImageURL:(NSString *)url cacheToMemory:(BOOL)cache{
    NSString *path = IMAGEPATH_FOR_URL(url);
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (image) {
        [imageView setImage:image];
        //重用(如果是重用)遗留
        for (UIView *view in imageView.subviews) {
            if ([view isKindOfClass:MBProgressHUD.class]) {
                [view removeFromSuperview];
            }
        }
    }else{
        //在块中移除
        [MBProgressHUD showHUDAddedTo:imageView animated:YES];
        CGFloat h = CGRectGetHeight(imageView.bounds);
        CGFloat w = CGRectGetWidth(imageView.bounds);
        NSString *urlStr = [self stringReplacingOfString:url height:h width:w];
        NSURL *url = [NSURL URLWithString:urlStr];
        [imageView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (cache == YES) {

                //判断目标文件夹是否存在
                NSFileManager *fm = [NSFileManager defaultManager];
                BOOL isDir = NO;
                BOOL exist = [fm fileExistsAtPath:ARTWORKIMAGEPATH isDirectory:&isDir];
                //目标文件夹不存在就创建
                if (!(isDir && exist)){
                    [fm createDirectoryAtPath:ARTWORKIMAGEPATH withIntermediateDirectories:YES attributes:nil error:nil];
                }

                //存储文件
                BOOL sucess = [fm createFileAtPath:path contents:UIImagePNGRepresentation(image) attributes:nil];
                if (sucess == NO) [fm removeItemAtPath:path error:nil];
            }
            //删除HUD
            dispatch_async(dispatch_get_main_queue(), ^{
                //多次添加
                for (UIView *view in imageView.subviews) {
                    if ([view isKindOfClass:MBProgressHUD.class]) {
                        [view removeFromSuperview];
                    }
                }
            });
        }];
    }
}


@end
