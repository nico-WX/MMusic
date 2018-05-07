//
//  ModelController.h
//  MMusic
//
//  Created by Magician on 2018/5/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ResponseRoot;
@class ContentViewController;

@interface ModelController : NSObject

-(instancetype)initWithData:(NSArray<NSDictionary<NSString*,ResponseRoot*>*>*) data;
-(ContentViewController*)viewControllerAtIndex:(NSUInteger)index;
-(NSUInteger)indexOfViewController:(ContentViewController*) viewController;
@end
