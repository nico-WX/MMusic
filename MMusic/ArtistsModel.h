//
//  ArtistsModel.h
//  MMusic
//
//  Created by Magician on 2018/5/27.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBModel.h"

@interface ArtistsModel :DBModel
/**艺人名称*/
@property(nonatomic, copy) NSString *name;
/**艺人catlog identifier*/
@property(nonatomic, copy) NSString *identifier;

/**艺人照片*/
@property(nonatomic, strong) UIImage *image;
@end
