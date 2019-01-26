//
//  ResourceDetailHeadView.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/21.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "ResourceDetailHeadView.h"
#import "Resource.h"

@interface ResourceDetailHeadView ()
@property(nonatomic,strong)UIImageView *imageView;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *artistLabel;
@end

@implementation ResourceDetailHeadView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _nameLabel = [[UILabel alloc] init];
        _artistLabel = [[UILabel alloc] init];

        [self addSubview:_imageView];
        [self addSubview:_nameLabel];
        [self addSubview:_artistLabel];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];

    UIEdgeInsets insets = UIEdgeInsetsMake(20, 20, 20, 20);
    __weak typeof(self) weakSelf = self;
    CGFloat h = CGRectGetHeight(self.bounds) - (insets.top+insets.bottom);
    CGSize size = {h,h};

    [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(weakSelf).insets(insets);
        make.size.mas_equalTo(size);
    }];

    [_nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(weakSelf).insets(insets);
        make.left.mas_equalTo(weakSelf.imageView.mas_right).insets(insets);
    }];

    [_artistLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(weakSelf.nameLabel);
        make.top.mas_equalTo(weakSelf.nameLabel.mas_bottom);
        make.right.mas_equalTo(weakSelf).insets(insets);
    }];

}

- (void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;

        [_nameLabel setText:[resource.attributes valueForKey:@"name"]];
        [_artistLabel setText:[resource.attributes valueForKey:@"artistName"]];

        if (!_artistLabel.text || [_artistLabel.text isEqualToString:@""]) {
            [_artistLabel setText:[resource.attributes valueForKey:@"curatorName"]];
        }

        NSString *path = [resource.attributes valueForKeyPath:@"artwork.url"];
        [_imageView setImageWithURLPath:path];
    }
}

@end
