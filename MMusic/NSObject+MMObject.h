//
//  NSObject+MMObject.h
//  MMusic
//
//  Created by Magician on 2018/4/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MMObject)
-(instancetype) initWithDict:(NSDictionary*) dict;
/**实例化类方法*/
+(instancetype) instanceWithDict:(NSDictionary*) dict;

@end
