//
//  ArtistsContentViewController.h
//  MMusic
//
//  Created by Magician on 2018/5/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>

/**艺人页面下部视图内容*/
@interface ArtistsContentViewController : UIViewController
@property(nonatomic, strong) ResponseRoot *responseRoot;

/**通过艺人的*/
-(instancetype)initWithResponseRoot:(ResponseRoot*) responseRoot;
@end
