//
//  JSONKey.h
//  MMusic
//
//  Created by Magician on 2018/7/28.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONKey : NSObject
/**Response Root` JSON object*/
@property(nonatomic, strong) NSString* data;
/**Response Root` JSON object*/
@property(nonatomic, strong) NSString* results;

//Resource` JSON object
@property(nonatomic, strong) NSString* identifier;
@property(nonatomic, strong) NSString* attributes;
@property(nonatomic, strong) NSString* type;

//其他key
@property(nonatomic, strong) NSString* songs;
@property(nonatomic, strong) NSString* albums;
@end
