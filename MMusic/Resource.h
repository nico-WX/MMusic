//
//  Resource.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMObject.h"
#import "Relationship.h"


@interface Attributes : MMObject
@end


@interface Resource : MMObject

@property(nonatomic, copy) NSString *identifier;  // json key = id
@property(nonatomic, copy) NSString *type;
@property(nonatomic, copy) NSString *href;


@property(nonatomic,strong) Attributes *attributes;
//@property(nonatomic, strong) NSDictionary *attributes;
@property(nonatomic, strong) NSDictionary *meta;


@property(nonatomic, strong) Relationship *relationships;

/**该方法只能在Resource 子类初始中调用*/
-(instancetype)initWithResource:(Resource*) resource ;
/**该方法只能在Resource 子类调用*/
+(instancetype)instanceWithResource:(Resource*) resource;
@end
