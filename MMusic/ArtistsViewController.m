//
//  ArtistsViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "ArtistsViewController.h"
#import "RequestFactory.h"
#import "Resource.h"

@interface ArtistsViewController ()

@property(nonatomic, strong)Resource *resource;

@property(nonatomic, strong) UIImageView *artistImageView;
@property(nonatomic, strong) UISegmentedControl *segmentedController;
@end

@implementation ArtistsViewController

-(instancetype)initWithArtistResource:(Resource *)resource{
    if (self = [super init]) {
        _resource = resource;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:UIColor.whiteColor];

    [self.view addSubview:self.artistImageView];
    [self requestFromArtistResource:self.resource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -helper
-(void)requestFromArtistResource:(Resource*) resource{

    NSString *name = [resource.attributes valueForKey:@"name"];
    NSURLRequest *request = [[RequestFactory new] createSearchWithText:name];
    Log(@"url =%@",request.URL.absoluteString);
    [self dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];
        //Log(@"json =%@",json);
    }];

}

#pragma mark getter
-(UIImageView *)artistImageView{
    if (!_artistImageView) {
        _artistImageView = UIImageView.new;
    }
    return _artistImageView;
}


@end
