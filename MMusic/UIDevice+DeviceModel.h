//
//  UIDevice+DeviceModel.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/16.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


//iPhone
//iPhone 3G
//iPhone 3GS
//iPhone 4
//iPhone 4s
//iPhone 5
//iPhone 5c
//iPhone 5s
//iPhone SE
//iPhone 6 Plus
//iPhone 6s Plus
//iPhone 6s
//iPhone 7 Plus
//iPhone 7
//iPhone 8 Plus
//iPhone 8
//iPhone X
//iPhone XS
//iPhone XS Max
//iPhone XR
typedef NS_ENUM(NSUInteger, MMDeviceName) {
    //iPhone =1
    MMDeviceName_iPhone         ,//= 1 << 0,
    MMDeviceName_iPhone_3G      ,//= 1 << 1,
    MMDeviceName_iPhone_3GS     ,//= 1 << 2,
    MMDeviceName_iPhone_4       ,//= 1 << 3,
    MMDeviceName_iPhone_4s      ,//= 1 << 4,
    MMDeviceName_iPhone_5       ,//= 1 << 5,
    MMDeviceName_iPhone_5c      ,//= 1 << 6,
    MMDeviceName_iPhone_5s      ,//= 1 << 7,
    MMDeviceName_iPhone_SE      ,//= 1 << 8,
    MMDeviceName_iPhone_6       ,//= 1 << 9,
    MMDeviceName_iPhone_6_Plus  ,//= 1 << 10,
    MMDeviceName_iPhone_6s      ,//= 1 << 11,
    MMDeviceName_iPhone_6s_Plus ,//= 1 << 12,
    MMDeviceName_iPhone_7       ,//= 1 << 13,
    MMDeviceName_iPhone_7_Plus  ,//= 1 << 14,
    MMDeviceName_iPhone_8       ,//= 1 << 15,
    MMDeviceName_iPhone_8_Plus  ,//= 1 << 16,
    MMDeviceName_iPhone_X       ,//= 1 << 17,
    MMDeviceName_iPhone_XS      ,//= 1 << 18,
    MMDeviceName_iPhone_XS_Max  ,//= 1 << 19,
    MMDeviceName_iPhone_XR      ,//= 1 << 20,

    //iPad = 2
    //iWatch = 3
};

@interface UIDevice (DeviceModel)

- (BOOL)currentDeviceIs:(MMDeviceName)deviceName;


@end

NS_ASSUME_NONNULL_END
