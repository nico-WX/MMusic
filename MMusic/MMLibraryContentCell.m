//
//  MMLibraryContentCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/30.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "MMLibraryContentCell.h"


@implementation MMLibraryContentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[UILabel alloc] init];

    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];

    __weak typeof(self) weakSelf = self;
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        
    }];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
