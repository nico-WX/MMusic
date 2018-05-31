//
//  ArtistsContentViewController.m
//  MMusic
//
//  Created by Magician on 2018/5/24.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "ArtistsContentViewController.h"
#import "ResponseRoot.h"
#import "Resource.h"

@interface ArtistsContentViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIView *artistView;
@end

static NSString *const cellID = @"cellReuseIdentifier";
@implementation ArtistsContentViewController

-(instancetype)initWithResponseRoot:(ResponseRoot *)responseRoot{
    if (self = [super init]) {
        _responseRoot = responseRoot;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    //不同的类型  添加不同的视图
    Resource *resource = self.responseRoot.data.lastObject ;
    if ([resource.type isEqualToString:@"artists"]) {
        [self.view addSubview:self.artistView];
        [self.artistView setBackgroundColor:UIColor.whiteColor];
    }else{
        [self.view addSubview:self.tableView];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    UIView *superview =self.view;
    Resource *resource = self.responseRoot.data.lastObject ;
    if ([resource.type isEqualToString:@"artists"]) {

    }else{
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(superview).insets(UIEdgeInsetsZero) ;
        }];
    }
}


#pragma mark - UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.responseRoot.data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    Resource *resource = [self.responseRoot.data objectAtIndex:indexPath.row];
    cell.textLabel.text = [resource.attributes valueForKey:@"name"];
    return cell;
}
#pragma mark - UITableViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y < 0) {
        //滚动到顶部了,
        [scrollView setScrollEnabled:NO];

        scrollView hitTest:<#(CGPoint)#> withEvent:<#(nullable UIEvent *)#>

       // [scrollView resignFirstResponder];

    }
    Log(@"conten size =%@",NSStringFromCGSize(scrollView.contentSize));
    Log(@"y =%f",scrollView.contentOffset.y);
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    Log(@"end drag");
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    Log(@"begin dra");
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    Log(@"move ");
}


#pragma mark -getter
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;

        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:cellID];

    }
    return _tableView;
}
- (UIView *)artistView{
    if (!_artistView) {
        _artistView = [[UIView alloc] initWithFrame:self.view.frame];
    }
    return _artistView;
}

@end
