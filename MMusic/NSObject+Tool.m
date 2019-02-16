//
//  NSObject+Tool.m
//  MMusic
//
//  Created by Magician on 2017/12/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//
#import <MBProgressHUD.h>
#import <UIImageView+WebCache.h>

#import "NSString+Replace.h"
#import "NSObject+Tool.h"
#import "AuthManager.h"



@implementation NSObject (Tool)

//统一解析响应体,处理异常等.
- (NSDictionary *)serializationDataWithResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *)error {
    if (error) Log(@"请求错误  error: %@",error.localizedDescription);

    NSDictionary *json;
    NSHTTPURLResponse *res = (NSHTTPURLResponse*)response;
    NSLog(@"code =%ld",res.statusCode);
    NSLog(@"URL =%@",res.URL);
    NSLog(@"header = %@",res.allHeaderFields);

    switch (res.statusCode) {
        case 200:
            if (data) {
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if (error) Log(@"Serialization Error:%@",error);
            }
            break;
        case 400:
            //[self showHUDToMainWindowFromText:@"400 请刷新"];
            break;
        case 401:
            //开发者Token 问题
            NSLog(@"开发者令牌授权过期");

            break;
        case 403:
            //userToken 问题
            NSLog(@"用户令牌授权过期");
            break;

        default:
            break;
    }
    return json;
}

- (NSURLRequest*)createRequestWithURLString:(NSString *)urlString setupUserToken:(BOOL)setupUserToken {
    //移除'%' 防止将'%' 重复编码成25
    urlString = [urlString stringByRemovingPercentEncoding];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];

    //设置请求头
    NSString *bearerString = [NSString stringWithFormat:@"Bearer %@",[AuthManager shareManager].developerToken];
    [request setValue:bearerString forHTTPHeaderField:@"Authorization"];
    if (setupUserToken) {
        NSString *userToken = [AuthManager  shareManager].userToken;
        [request setValue:userToken forHTTPHeaderField:@"Music-User-Token"];
    }

    NSLog(@"request header =%@",request.allHTTPHeaderFields);
    return request;
}
- (NSURLRequest*)createRequestWithHref:(NSString *)href {
    NSString *path = @"https://api.music.apple.com";
    path = [path stringByAppendingPathComponent:href];
    return [self createRequestWithURLString:path setupUserToken:NO];
}

//封装发起任务请求操作,通过block 回调返回数据.
- (void)dataTaskWithRequest:(NSURLRequest*)request handler:(RequestCallBack)handle {
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //统一处理返回的数据,响应体等,不管是否有回调, 在解析中都处理请求结果.
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        if (handle) {
            handle(json,(NSHTTPURLResponse*)response);
        }
    }] resume];
}


- (void)showImageToView:(UIImageView *)imageView withImageURL:(NSString *)url cacheToMemory:(BOOL)cache {
    dispatch_async(dispatch_get_main_queue(), ^{
        //cell 重用时,上次没加载完成的hud 未能隐藏, 遍历删除
        for (UIView *view in imageView.subviews) {
            if ([view isKindOfClass:UIActivityIndicatorView.class])
                [view removeFromSuperview];
        }

        //获取视图宽高, 设置请求图片大小
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat h = CGRectGetHeight(imageView.bounds)*scale;
        CGFloat w = CGRectGetWidth(imageView.bounds)*scale;
        if (w <= 10 || h <= 10) w=h=40; //拦截高度, 宽度为 0 的情况, 设置默认值,
                                        //image
        NSString *path = IMAGE_PATH_FOR_URL(url);
        UIImage *image = [UIImage imageWithContentsOfFile:path];

        //照片太小, 删除
        if (image.size.width < w || image.size.height < h) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            image = nil;
        }

        if (image) {
            //照片可以设置.
            [imageView setImage:image];
        }else{
            //从网络请求图片
            UIActivityIndicatorView *hud = [[UIActivityIndicatorView alloc] initWithFrame:imageView.frame];
            [hud setHidesWhenStopped:YES];
            [hud startAnimating];
            hud.color = UIColor.grayColor;
            [imageView addSubview:hud];

            //image url
            NSString *urlStr = [url stringReplacingImageURLSize:imageView.bounds.size];

            //部分URL 多出@"{c}" 这个参数,  替换掉
            NSRange range = [urlStr rangeOfString:@"{c}"];
            if (range.length > 0) {
                urlStr = [urlStr stringByReplacingOccurrencesOfString:@"{c}" withString:@"cc"];
            }

            NSURL *url = [NSURL URLWithString:urlStr];
            [imageView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL){
                
                [imageView setNeedsDisplay];
                [hud stopAnimating];
                [hud setHidden:YES];
                if(cache == YES) {
                    //判断目标文件夹是否存在
                    NSFileManager *fm = [NSFileManager defaultManager];
                    BOOL isDir = NO;
                    BOOL exist = [fm fileExistsAtPath:ARTWORK_IMAGE_PATH isDirectory:&isDir];
                    //目标文件夹不存在就创建
                    if (!(isDir && exist)){
                        [fm createDirectoryAtPath:ARTWORK_IMAGE_PATH withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    //存储文件
                    BOOL sucess = [fm createFileAtPath:path contents:UIImagePNGRepresentation(image) attributes:nil];
                    if (sucess == NO) [fm removeItemAtPath:path error:nil];
                }
            }];
        }
    });
}


- (void)showHUDToMainWindowFromText:(NSString *)text {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [[UIApplication sharedApplication].delegate window];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        [hud setRemoveFromSuperViewOnHide:YES];
        [hud.label setText:text];
        [hud setMode:MBProgressHUDModeCustomView];
        [hud hideAnimated:YES afterDelay:1.35f];
        //不接收事件
        [hud setUserInteractionEnabled:NO];
    });
}



@end
