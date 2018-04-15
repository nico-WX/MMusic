//
//  ChartFooterView.m
//  MMusic
//
//  Created by Magician on 2018/4/4.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ChartFooterView.h"

@implementation ChartFooterView

- (void)drawRect:(CGRect)rect{
    
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.button = UIButton.new;
        self.indicator = UIActivityIndicatorView.new;
    }
    return self;
}
@end
