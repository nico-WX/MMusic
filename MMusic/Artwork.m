//
//  Artwork.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Artwork.h"

@implementation Artwork

- (NSDictionary *)dictionaryValue{
    if (!_dictionaryValue) {
        _dictionaryValue = @{@"width":@(self.width),
                            @"height":@(self.height),
                            @"url": self.url,
                            @"bgColor" : self.bgColor,
                            @"textColor1":self.textColor1,
                            @"textColor2":self.textColor2,
                            @"textColor3":self.textColor3,
                            @"textColor4":self.textColor4
                            };
    }
    return _dictionaryValue;
}
@end
