//
//  MyMusicTableCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/27.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "MyMusicTableCell.h"

@implementation MyMusicTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setViewController:(UIViewController *)viewController{
    if(_viewController != viewController){
        _viewController = viewController;
        [self.textLabel setText:viewController.title];
        [self.textLabel setTextColor:MainColor];
    }
}
@end
