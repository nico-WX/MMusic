//
//  MMDetailViewController.m
//  ScrollPage
//
//  Created by 🐙怪兽 on 2018/11/12.
//  Copyright © 2018 com.😈. All rights reserved.
//


#import "MMDetailViewController.h"

#import <Masonry.h>

#import "Resource.h"

@interface MMDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
// base
@property (strong, nonatomic) UITableView *tableView;

@property(nonatomic, assign) CGFloat topOffset;

//data
@property(nonatomic, strong)Resource *resource;
@end

static NSString *const reuseIdentifier = @"tableview cell id";
@implementation MMDetailViewController

- (instancetype)initWithResource:(Resource *)resource{
    if (self = [super init]) {
        _resource = resource;

        _imageView = [UIImageView new];
        _titleLabel = [UILabel new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //table
    ({
        self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseIdentifier];
        [self.tableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
    });

    //imageView & label

    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];

    [self.view addSubview:self.imageView];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.tableView];
    [self.view setBackgroundColor:UIColor.whiteColor];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    //向下偏移量
    self.topOffset = CGRectGetMaxY(self.titleLabel.frame)+8;
    [self.tableView setContentInset:UIEdgeInsetsMake(self.topOffset, 0, 0, 0)];
    [self.tableView setContentOffset:CGPointMake(0, -self.topOffset)];
}

- (void)viewDidLayoutSubviews{


    UIEdgeInsets padding =UIEdgeInsetsMake(40, 150, 0, 150);
    __weak typeof(self) weakSelf = self;
    UIView *superView = self.view;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superView).offset(padding.top);
        make.left.mas_equalTo(superView).offset(padding.left);
        make.right.mas_equalTo(superView).offset(-padding.right);
        CGFloat h = CGRectGetWidth(superView.frame)-(padding.left+padding.right);
        make.height.mas_equalTo(h);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.imageView.mas_bottom).offset(8);
        make.left.mas_equalTo(superView);
        make.right.mas_equalTo(superView);
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView);
    }];


    [super viewDidLayoutSubviews];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    CGFloat y = scrollView.contentOffset.y;
    if ( y < (self.topOffset-100)) {
        //下拉一段距离  关闭VC
        [self delegateDismissViewController];
    }
}


- (void)delegateDismissViewController{
    if ([self.disMissDelegate respondsToSelector:@selector(detailViewControllerDidDismiss:)]) {
        [self.disMissDelegate detailViewControllerDidDismiss:self];
    }
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

    cell.textLabel.text = [NSString stringWithFormat:@"cell  %ld",indexPath.row+1];

    return cell;
}

@end
