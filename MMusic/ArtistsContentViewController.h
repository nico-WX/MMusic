//
//  ArtistsContentViewController.h
//  MMusic
//
//  Created by Magician on 2018/5/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArtistsContentViewController : UIViewController
@property(nonatomic, strong) ResponseRoot *responseRoot;

-(instancetype)initWithResponseRoot:(ResponseRoot*) responseRoot;
@end
