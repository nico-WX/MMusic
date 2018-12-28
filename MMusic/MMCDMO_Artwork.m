//
//  MMCDMO_Artwork.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/28.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMCDMO_Artwork.h"
#import "Artwork.h"


@implementation MMCDMO_Artwork

@dynamic bgColor,url,width,height,textColor1,textColor2,textColor3,textColor4;

- (instancetype)initArtwork:(Artwork*)artwork{
    if (self = [super initWithContext:self.mainMoc]) {

        NSArray *propertyes = @[@"bgColor",@"url",@"width",@"height",@"textColor1",@"textColor2",@"textColor3",@"textColor4"];
        for (NSString *key in propertyes) {
            [self setValue:[artwork valueForKey:key] forKey:key];
        }
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder{


    return self;
}

@end
