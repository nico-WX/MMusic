//
//  ResultsCell.m
//  MMusic
//
//  Created by Magician on 2018/5/22.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "ResultsCell.h"
#import "Artwork.h"

@implementation ResultsCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _artworkView =  UIImageView.new;
        _nameLabel = UILabel.new;
        _artistLabel = UILabel.new;
        _descLabel = UILabel.new;
        _padding = UIEdgeInsetsMake(4, 4, 4, 4);

        [_artistLabel setFont:[UIFont systemFontOfSize:12]];
        [_artistLabel setTextColor:UIColor.grayColor];

        [_descLabel setFont:[UIFont systemFontOfSize:12]];
        [_descLabel setTextColor:UIColor.grayColor];

        [self.contentView addSubview:_artworkView];
        [self.contentView addSubview:_nameLabel];
        [self.contentView addSubview:_artistLabel];
        [self.contentView addSubview:_descLabel];
    }
    return self;
}

-(void)prepareForReuse{
    [super prepareForReuse];
    self.resource = nil;
    self.artworkView.image = nil;
    self.nameLabel.text = nil;
    self.artistLabel.text = nil;
    self.descLabel.text = nil;
}

-(void)drawRect:(CGRect)rect{
    __weak typeof(self) weakSelf = self;
    UIView *superview = self.contentView;
    UIEdgeInsets padding = self.padding;

    [self.artworkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).offset(padding.top);
        make.left.mas_equalTo(superview.mas_left).offset(padding.left);
        make.bottom.mas_equalTo(superview.mas_bottom).offset(-padding.bottom);

        CGFloat w  = CGRectGetHeight(weakSelf.frame)-(padding.top+padding.bottom);
        make.width.mas_equalTo(w);
    }];

    //封面高度
    CGFloat artworkH = (CGRectGetHeight(rect)-(padding.top+padding.bottom));

    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).offset(padding.top);
        make.left.mas_equalTo(weakSelf.artworkView.mas_right).offset(padding.left);

        CGFloat inset = CGRectGetHeight(rect)+(padding.top+padding.bottom);
        make.right.mas_equalTo(superview.mas_right).offset(-inset);

        CGFloat h = artworkH*0.4;
        make.height.mas_equalTo(h);
    }];


    [self.artistLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.nameLabel.mas_left);
        make.right.mas_equalTo(weakSelf.nameLabel.mas_right);

        CGFloat h = artworkH*0.3;
        make.height.mas_equalTo(h);
    }];

    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.artistLabel.mas_bottom);
        make.left.mas_equalTo(weakSelf.artistLabel.mas_left);
        make.right.mas_equalTo(weakSelf.artistLabel.mas_right);

        CGFloat h = artworkH*0.3;
        make.height.mas_equalTo(h);
    }];
}


-(void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;

     
        _nameLabel.text = [resource.attributes valueForKey:@"name"];
        if ([resource.attributes valueForKey:@"artwork"]) {
            Artwork *art = [Artwork instanceWithDict:[resource.attributes valueForKey:@"artwork"]];
            [self showImageToView:_artworkView withImageURL:art.url cacheToMemory:YES];
        }

        if ([resource.attributes valueForKey:@"artistName"]) {
            _artistLabel.text = [resource.attributes valueForKey:@"artistName"];
        }
        if ([resource.attributes valueForKey:@"albumName"]) {
            _descLabel.text = [resource.attributes valueForKey:@"albumName"];
        }else if ([resource.attributes valueForKey:@"curatorName"]){
            _descLabel.text = [resource.attributes valueForKey:@"curatorName"];
        }
    }
}

@end


