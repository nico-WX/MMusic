//
//  ResourceDetailViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/30.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "ResourceDetailViewController.h"
#import <UIImageView+WebCache.h>
#import "Resource.h"
#import "Playlist.h"
#import "Album.h"
#import "Artwork.h"
#import "NSObject+Tool.h"

@interface ResourceDetailViewController ()
@property(nonatomic, strong)Playlist *playlist;
@property(nonatomic, strong)Album *album;
@end

@implementation ResourceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];



    CGRect rect = self.view.frame;
    CGRect artRect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.width);
    UIImageView *artImage = [[UIImageView alloc] initWithFrame:artRect];
    [self.view addSubview:artImage];

    Artwork *art;
    if (self.album) {
        art = self.album.artwork;
    }else if(self.playlist ){
        art = self.playlist.artwork;
    }
    NSString *path = [self stringReplacingOfString:art.url height:rect.size.width width:rect.size.width];
    NSURL *artURL = [NSURL URLWithString:path];
    
    [artImage sd_setImageWithURL:artURL completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {

    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setResource:(Resource *)resource{
    if (_resource != resource) {
        _resource = resource;
        if([_resource.type isEqualToString:@"playlists"]){
            _playlist = [Playlist instanceWithDict:_resource.attributes];
        }else if ([_resource.type isEqualToString:@"albums"]){
            _album = [Album instanceWithDict:_resource.attributes];
        }
    }
}

@end
