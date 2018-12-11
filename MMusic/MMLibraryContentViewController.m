//
//  MMLibraryContentViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/30.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "MMLibraryContentViewController.h"
#import "MMLibraryContentCell.h"


@interface MMLibraryContentViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@end

static NSString *const cellIdentifier = @"tableView cell reuse identifier";
@implementation MMLibraryContentViewController

- (instancetype)initWithMediaItems:(NSArray<MPMediaItem *> *)mediaItems{
    if (self = [super init]) {
        _items = mediaItems;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    UIView *superView = self.view;
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(superView).insets(UIEdgeInsetsMake(0, 4, 0, 4));
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MMLibraryContentCell *cell = (MMLibraryContentCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setMediaItem:[self.items objectAtIndex:indexPath.row]];
    return cell;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[MMLibraryContentCell class] forCellReuseIdentifier:cellIdentifier];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    return _tableView;
}

@end
