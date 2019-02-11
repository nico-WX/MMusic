//
//  ResourceCell+ConfigureForResource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/11.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ResourceCell+ConfigureForResource.h"
#import "UIImageView+Extension.h"

@implementation ResourceCell (ConfigureForResource)

- (void)configureForResource:(Resource *)resource{
    [self.titleLabel setText:resource.attributes[@"name"]];
    NSString *url = [resource.attributes valueForKeyPath:@"attributes.artwork.url"];
    [self.imageView setImageWithURLPath:url];
}
@end
