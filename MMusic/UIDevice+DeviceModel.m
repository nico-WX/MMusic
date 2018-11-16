//
//  UIDevice+DeviceModel.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/16.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "UIDevice+DeviceModel.h"

@implementation UIDevice (DeviceModel)

- (BOOL)currentDeviceIs:(MMDeviceName)deviceName{
    CGSize size = [[UIScreen mainScreen] bounds].size;

    BOOL sizeEqual = CGSizeEqualToSize(size,[self sizeForDeviceNanme:deviceName | MMDeviceName_iPhone_XR]);


    if (deviceName & MMDeviceName_iPhone && sizeEqual ) {

    }




    return YES;
}

- (CGSize)sizeForDeviceNanme:(MMDeviceName)deviceName {
    switch (deviceName) {
        case MMDeviceName_iPhone:
        case MMDeviceName_iPhone_3G:
        case MMDeviceName_iPhone_3GS:
        case MMDeviceName_iPhone_4:
        case MMDeviceName_iPhone_4s:
            return CGSizeMake(320, 480);
            break;

        case MMDeviceName_iPhone_5:
        case MMDeviceName_iPhone_5c:
        case MMDeviceName_iPhone_5s:
        case MMDeviceName_iPhone_SE:
            return CGSizeMake(320, 568);
            break;

        case MMDeviceName_iPhone_6:
        case MMDeviceName_iPhone_6s:
        case MMDeviceName_iPhone_7:
        case MMDeviceName_iPhone_8:
            return CGSizeMake(375, 667);
            break;

        case MMDeviceName_iPhone_6_Plus:
        case MMDeviceName_iPhone_6s_Plus:
        case MMDeviceName_iPhone_7_Plus:
        case MMDeviceName_iPhone_8_Plus:
            return CGSizeMake(414, 736);
            break;

        case MMDeviceName_iPhone_X:
        case MMDeviceName_iPhone_XS:
            return CGSizeMake(375, 812);
            break;

        case MMDeviceName_iPhone_XR:
        case MMDeviceName_iPhone_XS_Max:
            return CGSizeMake(414, 896);
            break;
    }
}

@end
