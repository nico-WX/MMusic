//
//  TracksModel.h
//  MMusic
//
//  Created by Magician on 2018/5/27.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "DBModel.h"

@interface TracksModel : DBModel
/**歌曲名称*/
@property(nonatomic, copy) NSString *name;
/**歌曲id*/
@property(nonatomic, copy) NSString *identifier;

@end
