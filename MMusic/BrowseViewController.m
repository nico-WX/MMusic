//
//  BrowseViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/22.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "BrowseViewController.h"
#import "MMRecommendationViewController.h"

@interface BrowseViewController ()
@property(nonatomic, strong) MMRecommendationViewController *recommendationCtr;
@end

@implementation BrowseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];

    //添加顶部推荐 视图
    [self setupTodayRecommendations];
}

/**设置推荐集合视图*/
-(void) setupTodayRecommendations{
    //推荐视图 Frame
    CGSize size = self.view.frame.size;
    CGFloat width = size.width;
    CGFloat height= size.height / 4;
    CGFloat x = 0 ;
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.recommendationCtr = [[MMRecommendationViewController alloc] initWithCollectionViewLayout:layout];
    [self.recommendationCtr.collectionView setFrame:CGRectMake(x, y, width,height)];
    [self.view addSubview:self.recommendationCtr.collectionView];
    [self addChildViewController:self.recommendationCtr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
