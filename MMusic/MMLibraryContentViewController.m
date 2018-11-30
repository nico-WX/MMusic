//
//  MMLibraryContentViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/30.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <Masonry.h>
#import <AVKit/AVKit.h>

#import "MMLibraryContentViewController.h"


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
        make.edges.mas_equalTo(superView);
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.items.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }

    MPMediaItem *item = [self.items objectAtIndex:indexPath.row];
    [cell.textLabel setText:item.title];
    [cell.detailTextLabel setText:item.artist];

 //   UIImage *image = [item.artwork imageWithSize:cell.bounds.size];
//    if (!image) {
//        NSLog(@"item.artwork =%@",item.artwork);
//        NSLog(@"cor =%@",NSStringFromCGRect(item.artwork.bounds));
//    }

    [cell.imageView setImage:[item.artwork imageWithSize:cell.bounds.size]];

    NSLog(@"title =%@",item.podcastTitle);


    return cell;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        //[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
    }
    return _tableView;
}

@end
