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

#import "ResourceDetailTopView.h"

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
    ResourceDetailTopView *topView = [[ResourceDetailTopView alloc] initWithFrame:CGRectMake(0, 64, rect.size.width, rect.size.height/6)];
    [self.view addSubview:topView];

    if (_playlist) {
        topView.playlist = self.playlist;
    }else{
        topView.album = self.album;
    }
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
