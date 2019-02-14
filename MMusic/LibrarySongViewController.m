//
//  LibrarySongViewController.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/12.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "LibrarySongViewController.h"
#import "LikeSongCell.h"


@interface LibrarySongViewController ()<UITableViewDelegate>
@property(nonatomic,strong)UITableView *tableView;

@end

@implementation LibrarySongViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    [self.tableView setFrame:self.view.bounds];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        //[_tableView registerClass:[LikeSongCell class] forCellReuseIdentifier:identifier];
        [_tableView setRowHeight:66];
        [_tableView setDelegate:self];
    }
    return _tableView;
}
    


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
