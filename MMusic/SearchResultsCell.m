//
//  SearchResultsCell.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/23.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "SearchResultsCell.h"
#import "UIImageView+Extension.h"
#import "Resource.h"

@interface SearchResultsCell ()
@property(nonatomic,strong) UIImageView *artworkView;
@property(nonatomic,strong) UILabel *nameLabel;
@property(nonatomic,strong) UILabel *artistLabel;
@property(nonatomic,strong) UILabel *albumLabel;
@end

@implementation SearchResultsCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _artworkView = [[UIImageView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        _artistLabel = [[UILabel alloc] init];
        _albumLabel = [[UILabel alloc] init];

        [self.contentView addSubview:_artworkView];
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_albumLabel];
        [self.contentView addSubview:_nameLabel];

        UIFont *font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
        UIColor *color = UIColor.grayColor;
        [_artistLabel setTextColor:color];
        [_albumLabel setTextColor:color];
        [_artistLabel setFont:font];
        [_albumLabel setFont:font];
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets insets = UIEdgeInsetsMake(4, 4, 4, 4);
    UIView *superView = self.contentView;
    __weak typeof(self) weakSelf = self;

    [_artworkView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.mas_equalTo(superView).insets(insets);
        CGFloat w = CGRectGetHeight(superView.bounds) - (insets.top+insets.bottom);
        make.width.mas_equalTo(w);
    }];

    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).inset(insets.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).inset(insets.left);
        make.right.mas_equalTo(superView).inset(60);
    }];
    [_artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
        make.left.right.mas_equalTo(weakSelf.nameLabel);
    }];
    [_albumLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom);
        make.left.right.mas_equalTo(weakSelf.artistLabel);
    }];
}

- (void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;

        [_nameLabel setText:[resource.attributes valueForKey:@"name"]];
        [_artistLabel setText:[resource.attributes valueForKey:@"artistName"]];
        [_albumLabel setText:[resource.attributes valueForKey:@"albumName"]];

        NSString *path = [resource.attributes valueForKeyPath:@"artwork.url"];
        [_artworkView setImageWithURLPath:path];

        if (!_artistLabel.text) {
            [_artistLabel setText:[resource.attributes valueForKey:@"curatorName"]];
        }
    }
}
@end
