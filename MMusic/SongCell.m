//
//  SongCell.m
//  MMusic
//
//  Created by Magician on 2018/3/11.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "SongCell.h"

@implementation SongCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.sortLabel = ({
            UILabel *sort = [[UILabel alloc] init];
            [sort setTextAlignment:NSTextAlignmentCenter];
            [sort setFont:[UIFont systemFontOfSize:28]];
            [sort setTextColor:[UIColor grayColor]];
            [self.contentView addSubview:sort];
            sort;
        });

        self.songNameLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [self.contentView addSubview:label];
            label;
        });

        self.artistLabel = ({
            UILabel *label = [[UILabel alloc] init];
            [label setFont:[UIFont systemFontOfSize:12]];
            [label setTextColor:[UIColor grayColor]];
            [self.contentView addSubview:label];
            label;
        });

        self.moreButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setImage:[UIImage imageNamed:@"more-gray"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"more-blue"] forState:UIControlStateHighlighted];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [self.contentView addSubview:button];
            button;
        });
    }
    return self;
}


- (void)layoutSubviews{
    CGFloat spacing = 4.0f;
    CGRect rect = self.contentView.bounds;

    //sort label
    self.sortLabel.frame =({
        CGFloat sortX = CGRectGetMinX(rect)+spacing;
        CGFloat sortY = CGRectGetMinY(rect)+spacing;
        CGFloat sortH = CGRectGetHeight(rect)-spacing*2;
        CGFloat sortW = sortH;
        CGRect sortRect = CGRectMake(sortX, sortY, sortW, sortH);
        sortRect;
    });

    //song name
    self.songNameLabel.frame = ({
        CGFloat x = CGRectGetMaxX(self.sortLabel.frame) + spacing;
        CGFloat y = CGRectGetMinY(self.sortLabel.frame);
        CGFloat h = CGRectGetHeight(rect)/2;
        CGFloat w = CGRectGetWidth(rect)*0.8f; //
        CGRect labelRect = CGRectMake(x,y, w, h);
        labelRect;
    });

    //artist
    self.artistLabel.frame = ({
        CGFloat x = CGRectGetMinX(self.songNameLabel.frame);
        CGFloat y = CGRectGetMaxY(self.songNameLabel.frame);
        CGFloat w = CGRectGetWidth(self.songNameLabel.frame);
        CGFloat h = CGRectGetHeight(rect)/2 - spacing;
        CGRect labelRect = CGRectMake(x, y, w, h);

        labelRect;
    });

    //more button
    self.moreButton.frame = ({
        CGFloat h = CGRectGetHeight(rect) -4;
        CGFloat w = h;
        CGFloat x = CGRectGetMaxX(rect) - w -2;
        CGFloat y = CGRectGetMinY(rect) - 2;
        CGRect buttonRect = CGRectMake(x, y, w, h);
        buttonRect;
    });
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
