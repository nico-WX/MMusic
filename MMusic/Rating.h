//
//  Rating.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/3.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "Resource.h"

NS_ASSUME_NONNULL_BEGIN

@interface RatingAttributes : MMObject
@property(nonatomic,assign) NSInteger value;
@end

@interface Rating : Resource
@property(nonatomic,strong)RatingAttributes *attributes;
@end

NS_ASSUME_NONNULL_END
