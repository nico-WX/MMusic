//
//  MMRecommendationDetailViewController.m
//  MMusic
//
//  Created by Magician on 2017/12/6.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "MMRecommendationDetailViewController.h"
#import "MMDetailTopViewController.h"
#import "MMBottomTableViewController.h"

@interface MMRecommendationDetailViewController ()
@property(nonatomic, strong) NSArray *data;
@property(nonatomic, strong) MMDetailTopViewController *top;
@property(nonatomic, strong) MMBottomTableViewController *bottom;
@property(nonatomic, strong) void(^selectedData)(Resource* resource);
@end

@implementation MMRecommendationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];

    //添加顶部展示视图
    [self setupTopView];
    //添加下部展示数据tableView 视图
    [self setupBottom];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//添加顶部视图, 展示所有的专辑或者播放列表
- (void)setupTopView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];

    self.top  = [[MMDetailTopViewController alloc] initWithCollectionViewLayout:layout];
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat topX = frame.origin.x;
    CGFloat topY = CGRectGetMaxY(frame);
    CGFloat topW = frame.size.width;
    CGFloat topH = self.view.frame.size.height /5 ;
    [self.top.view setFrame:CGRectMake(topX, topY, topW, topH)];
    [self.top setRecommendation:self.recommendation];
    [self.view addSubview:self.top.view];

    [self addChildViewController:self.top];
}

//下部数据列表视图
- (void)setupBottom{
    self.bottom = [[MMBottomTableViewController alloc] initWithStyle:UITableViewStylePlain];
    CGFloat bottomX = self.view.frame.origin.x;
    CGFloat bottomY = CGRectGetMaxY(self.top.view.frame);
    CGFloat bottomW = self.view.frame.size.width;
    CGFloat bottomH = self.view.frame.size.height - bottomY;
    [self.bottom.view setFrame:CGRectMake(bottomX, bottomY, bottomW, bottomH)];

    //解除循环引用
    __weak typeof(self) weakSelf = self;
    //获取选择的数据
    self.top.selectedData = ^(Resource *resouurce){
        weakSelf.bottom.resource = resouurce;
    };

    [self.view addSubview:self.bottom.view];
    [self addChildViewController:self.bottom];
}

@end










