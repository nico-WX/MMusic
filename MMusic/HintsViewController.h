//
//  HintsViewController.h
//  MMusic
//
//  Created by Magician on 2018/4/21.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ResultsViewController;

@interface HintsViewController : UITableViewController
@property(nonatomic, strong,readonly) NSArray<NSString*> *terms;
-(void)showHintsFromTerms:(NSString*) term;

@end
