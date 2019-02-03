//
//  Genre.h
//  MMusic
//
//  Created by Magician on 2017/12/1.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"

@interface GenreAttributes : MMObject
@property(nonatomic,copy) NSString *name;
@end

@interface Genre : Resource
@property(nonatomic,strong)GenreAttributes *attributes;
@end
