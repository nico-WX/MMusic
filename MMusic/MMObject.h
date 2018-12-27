//
//  MMObject.h
//  MMusic
//
//  Created by Magician on 2017/12/2.
//  Copyright © 2017年 com.😈. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MJExtension.h>

@interface MMObject : NSManagedObject //NSObject

-(instancetype) initWithDict:(NSDictionary*) dict;
+(instancetype) instanceWithDict:(NSDictionary*) dict;
@end
