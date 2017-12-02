//
//  MMObject.h
//  MMusic
//
//  Created by Magician on 2017/12/2.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

/**抽取初始及 实例化类方法*/
@interface MMObject : NSObject

-(instancetype) initWithDict:(NSDictionary*) dict;
/**实例化类方法*/
+(instancetype) instanceWithDict:(NSDictionary*) dict;

@end
