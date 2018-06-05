//
//  ArtistsInfoView.m
//  MMusic
//
//  Created by Magician on 2018/6/1.
//  Copyright © 2018年 com.😈. All rights reserved.
//


#import <Masonry.h>
#import "ArtistsInfoView.h"
#import "EditorialNotes.h"

@interface ArtistsInfoView()
@property(nonatomic, strong) UILabel *label;
@property(nonatomic, strong) UITextView *textView;
@end

@implementation ArtistsInfoView

//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    UIEdgeInsets padding = UIEdgeInsetsMake(6, 6, 6, 6);
//
//    CGFloat lX = padding.left;
//    CGFloat lY = padding.top;
//    CGFloat lW = CGRectGetWidth(rect)-padding.left*2;
//    CGFloat lH = 30;
//    self.label.frame = CGRectMake(lX, lY, lW, lH);
//
//    CGFloat tX = padding.left;
//    CGFloat tY = CGRectGetMaxY(self.label.frame)+padding.top;
//    CGFloat tW = lW;
//    CGFloat tH = CGRectGetHeight(rect)-(padding.top*3+lH);
//    self.textView.frame = CGRectMake(tX, tY, tW, tH);
//
//}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {

        UIEdgeInsets padding = UIEdgeInsetsMake(6, 6, 6, 6);

        CGFloat lX = padding.left;
        CGFloat lY = padding.top;
        CGFloat lW = CGRectGetWidth(frame)-padding.left*2;
        CGFloat lH = 30;
        CGRect lFrame = CGRectMake(lX, lY, lW, lH);
        _label = [[UILabel alloc] initWithFrame:lFrame];
        [_label setFont:[UIFont systemFontOfSize:26]];

        CGFloat tX = padding.left;
        CGFloat tY = CGRectGetMaxY(self.label.frame)+padding.top;
        CGFloat tW = lW;
        CGFloat tH = CGRectGetHeight(frame)-(padding.top*3+lH);
        CGRect tFrame = CGRectMake(tX, tY, tW, tH);
        _textView = [[UITextView alloc] initWithFrame:tFrame];
        [_textView setUserInteractionEnabled:NO];

        [self addSubview:_label];
        [self addSubview:_textView];
    }
    return self;
}

-(void)setArtist:(Artist *)artist{
    if (_artist != artist) {
        _artist = artist;

        self.label.text = artist.name;
        self.textView.text = artist.editorialNotes.standard;
    }
}


@end
