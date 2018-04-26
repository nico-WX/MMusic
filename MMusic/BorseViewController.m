//
//  BorseViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>

#import "BorseViewController.h"
#import "SearchViewController.h"

@interface BorseViewController ()
@property(nonatomic, strong) SearchViewController *searchVC;

/**歌单/专辑/语种/风格/场景 等*/
@property(nonatomic, strong) UICollectionView *collectionView;
@end

@implementation BorseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;

    [self addChildViewController:self.searchVC];
    [self.navigationController.navigationBar addSubview:self.searchVC.serachBar];
    [self.view addSubview:self.searchVC.view];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.searchVC.serachBar setHidden:NO];
    UIView *superview = self.navigationController.navigationBar;
    [self.searchVC.serachBar mas_makeConstraints:^(MASConstraintMaker *make) {
        UIEdgeInsets padding = UIEdgeInsetsMake(0, 4, 0, 4);
        make.edges.mas_equalTo(superview).with.insets(padding);
    }];

}

- (SearchViewController *)searchVC{
    if (!_searchVC) {
        _searchVC = SearchViewController.new;
    }
    return _searchVC;
}

@end
