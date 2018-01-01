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
@property(nonatomic, strong) MMDetailTopViewController *top;
@property(nonatomic, strong) MMBottomTableViewController *bottom;
@end

@implementation MMRecommendationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

    //计算Frame
    self.top  = [[MMDetailTopViewController alloc] initWithCollectionViewLayout:layout];
    CGRect frame = self.navigationController.navigationBar.frame;
    CGFloat topX = frame.origin.x;
    CGFloat topY = CGRectGetMaxY(frame);
    CGFloat topW = frame.size.width;
    CGFloat topH = self.view.frame.size.height / 5;
    [self.top.view setFrame:CGRectMake(topX, topY, topW, topH)];

    [self.top setRecommendation:self.recommendation];
    [self.view addSubview:self.top.view];
}

//下部数据列表视图
- (void)setupBottom{
    self.bottom = [[MMBottomTableViewController alloc] initWithStyle:UITableViewStylePlain];

    //Frame
    CGFloat bottomX = self.view.frame.origin.x;
    CGFloat bottomY = CGRectGetMaxY(self.top.view.frame);
    CGFloat bottomW = self.view.frame.size.width;
    CGFloat bottomH = self.view.frame.size.height - bottomY -44;
    [self.bottom.view setFrame:CGRectMake(bottomX, bottomY, bottomW, bottomH)];

    //第一个资源 (内部可能是专辑,或者歌单,播放列表)
    Resource *firstResource = _recommendation.relationships.contents.data.firstObject;
    //取不到数据,是组类型推荐,包含着另一个推荐子集合,转换索取方向,向内部索取;
    if (!firstResource) {
        firstResource = _recommendation.relationships.recommendations.data.firstObject.relationships.contents.data.firstObject;
    }
    //默认显示第一个资源
    self.bottom.resource = firstResource;

    __weak typeof(self) weakSelf = self;             //解除循环引用
    self.top.selectedData = ^(Resource *resouurce){  //传递用户选择的数据到底部tableView 中
        weakSelf.bottom.resource = resouurce;
        [weakSelf.bottom.tableView reloadData];     //及时shua'xin
    };

    [self.view addSubview:self.bottom.view];
}

@end










