//
//  NSObject+Tool.m
//  MMusic
//
//  Created by Magician on 2017/12/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//
#import <MBProgressHUD.h>
#import <UIImageView+WebCache.h>
#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "NSObject+Tool.h"
#import "AuthorizationManager.h"

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

//解析响应体
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
-(void)dataTaskWithRequest:(NSURLRequest*) request completionHandler:(void(^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)) handler{
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        if (handler) handler(data,response,error);
    }] resume];
}

//替换封面URL中的占位字符串,
-(NSString *)stringReplacingOfString:(NSString *)target height:(int)height width:(int)width{
    //像素倍数
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
        [UIApplication sharedApplication] ;
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

    //移除 '%' 防止将%编码成25
    urlString = [urlString stringByRemovingPercentEncoding];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    //Log(@"url=%@",url);
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
    dispatch_async(dispatch_get_main_queue(), ^{
        //cell 重用时,上次没加载完成的hud 未能隐藏, 遍历隐藏
        for (UIView *view in imageView.subviews) {
            if ([view isKindOfClass:UIActivityIndicatorView.class]) {
                UIActivityIndicatorView *hud = (UIActivityIndicatorView*) view;
                [hud stopAnimating];
            }
        }

        //获取视图宽高, 设置请求图片大小
        CGFloat h = CGRectGetHeight(imageView.bounds);
        CGFloat w = CGRectGetWidth(imageView.bounds);
        if (w <= 10 || h <= 10) w=h=40; //拦截高度, 宽度为 0 的情况, 设置默认值,
                                        //image
        NSString *path = IMAGEPATH_FOR_URL(url);
        UIImage *image = [UIImage imageWithContentsOfFile:path];

        //照片太小, 删除
        CGFloat scale = [UIScreen mainScreen].scale;
        if (image.size.width < w*scale || image.size.height < h*scale) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            image = nil;
        }

        if (image) {
            [imageView setImage:image];
            //内存中无图片
        }else{
            UIActivityIndicatorView *hud = [[UIActivityIndicatorView alloc] initWithFrame:imageView.frame];
            [hud setHidesWhenStopped:YES];
            [hud startAnimating];
            hud.color = UIColor.grayColor;

            [imageView performSelectorOnMainThread:@selector(addSubview:) withObject:hud waitUntilDone:NO];

            NSString *urlStr = [self stringReplacingOfString:url height:h width:w];
            NSRange range = [urlStr rangeOfString:@"{c}"];
            if (range.length > 0) {
                urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{c}" withString:@"cc"];
            }

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
                    [hud stopAnimating];
                }
            }];
        }
    });
}


+(UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat) alpha{
    //检查长度
    if (hexString.length < 6 || hexString.length > 8) {
        return UIColor.blackColor;
    }

    //解析前缀
    hexString = [hexString uppercaseString];
    if ([hexString hasPrefix:@"0X"]) {
        hexString = [hexString substringFromIndex:2];
    }
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    if (hexString.length != 6) {
        return UIColor.blackColor;
    }

    NSString *rStr = [hexString substringWithRange:NSMakeRange(0, 2)];
    NSString *gStr = [hexString substringWithRange:NSMakeRange(2, 2)];
    NSString *bStr = [hexString substringWithRange:NSMakeRange(4, 2)];

    unsigned int r, g, b;
    [[NSScanner scannerWithString:rStr] scanHexInt:&r];
    [[NSScanner scannerWithString:gStr] scanHexInt:&g];
    [[NSScanner scannerWithString:bStr] scanHexInt:&b];
    
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:alpha];
}

+(UIColor *)oppositeColorOf:(UIColor *)mainColor{
    if ([mainColor isEqual:[UIColor blackColor]]) {
        mainColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    }
    else if ([mainColor isEqual:[UIColor darkGrayColor]]) {
        mainColor = [UIColor colorWithRed:84.915/255.f green:84.915/255.f blue:84.915/255.f alpha:1];
    }
    else if ([mainColor isEqual:[UIColor lightGrayColor]]) {
        mainColor = [UIColor colorWithRed:170.085/255.f green:170.085/255.f blue:170.085/255.f alpha:1];
    }
    else if ([mainColor isEqual:[UIColor whiteColor]]) {
        mainColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    }
    else if ([mainColor isEqual:[UIColor grayColor]]) {
        mainColor = [UIColor colorWithRed:127.5/255.f green:127.5/255.f blue:127.5/255.f alpha:1];
    }

    const CGFloat *componentColors = CGColorGetComponents(mainColor.CGColor);

    UIColor *convertedColor = [[UIColor alloc] initWithRed:(1.0 - componentColors[0])
                                                     green:(1.0 - componentColors[1])
                                                      blue:(1.0 - componentColors[2])
                                                     alpha:componentColors[3]];
    return convertedColor;
}


- (MPMusicPlayerPlayParametersQueueDescriptor*)playParametersQueueDescriptorFromParams:(NSArray<NSDictionary *> *)playParamses startAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *list = NSMutableArray.new;
    for (NSDictionary * playParams in playParamses ) {
        MPMusicPlayerPlayParameters *parameters = [[MPMusicPlayerPlayParameters alloc] initWithDictionary:playParams];
        [list addObject:parameters];
    }
    MPMusicPlayerPlayParametersQueueDescriptor *queue =[[MPMusicPlayerPlayParametersQueueDescriptor alloc] initWithPlayParametersQueue:list];
    [queue setStartItemPlayParameters:[list objectAtIndex:indexPath.row]];
    return queue;
}


-(void)showHUDToMainWindow{
    UIView *view = [[UIApplication sharedApplication].delegate window];

    CGRect rect = CGRectMake(100, 100, 100, 100);
    UIView *redView = [[UIView alloc] initWithFrame:rect];
    [redView setBackgroundColor:UIColor.redColor];
    [redView setCenter:view.center];
    [view addSubview:redView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [redView removeFromSuperview];
    });
}
- (void)showHUDToMainWindowFromText:(NSString *)text{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[UIApplication sharedApplication].delegate window];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        [hud setRemoveFromSuperViewOnHide:YES];
        [hud.label setText:text];
        [hud setMode:MBProgressHUDModeCustomView];
        [hud hideAnimated:YES afterDelay:4.0f];
    });
}


@end
