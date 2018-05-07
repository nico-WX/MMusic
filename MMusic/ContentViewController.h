//
//  ContentViewController.h
//  MMusic
//
//  Created by Magician on 2018/5/7.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ResponseRoot;

@interface ContentViewController : UIViewController
@property(nonatomic, strong, readonly) NSDictionary<NSString*,ResponseRoot*> *resourceDict;
-(instancetype)initWithResourceDict:(NSDictionary<NSString*,ResponseRoot*>*) resourceDict;
@end
