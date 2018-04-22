//
//  ResultsViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/9.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Masonry.h>
#import "ResultsViewController.h"
#import "ResultsSectionHeader.h"
#import "ResultsCell.h"
#import "HeaderView.h"
#import "DetailViewController.h"

#import "NSObject+Tool.h"

#import "Resource.h"
#import "RequestFactory.h"
#import "ResponseRoot.h"
#import "Artist.h"
#import "Activity.h"
#import "Artwork.h"

#import "Album.h"
#import "Playlist.h"


@interface ResultsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) NSString *searchText;

//数据
@property(nonatomic, strong) NSArray<NSDictionary<NSString*,ResponseRoot*> *> *results;
@end

@implementation ResultsViewController

static NSString *const cellIdentifier = @"cellReuseIdentifier";
static NSString *const headerIdentifier = @"headerReuseID";
- (instancetype)initWithSearchText:(NSString *)searchText{
    if (self = [super init]) {
        _searchText = searchText;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self requestDataFromSearchTest:self.searchText];

    self.tableView = ({
        UITableView *view = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        [view registerClass:[ResultsCell class] forCellReuseIdentifier:cellIdentifier];
        [view registerClass:ResultsSectionHeader.class forHeaderFooterViewReuseIdentifier:headerIdentifier];
        view.delegate = self;
        view.dataSource = self;
        [self.view addSubview:view];

        view;
    });

    CGFloat navH = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat tabH = CGRectGetHeight(self.tabBarController.tabBar.frame);
    //layout
    UIEdgeInsets padding = UIEdgeInsetsMake(navH, 0, tabH, 0);
    UIView *superview = self.view;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(superview.mas_top).with.offset(padding.top);
        make.left.mas_equalTo(superview.mas_left);
        make.right.mas_equalTo(superview.mas_right);
        make.bottom.mas_equalTo(superview.mas_bottom).with.offset(-padding.bottom);
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) requestDataFromSearchTest:(NSString *) searchText{
    NSURLRequest *request = [[RequestFactory requestFactory] createSearchWithText:searchText];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error && data) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:error];

            if (json) {
                json = [json objectForKey:@"results"];
                NSMutableArray *resultsList = [NSMutableArray array];
                //枚举数据
                [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                    [resultsList addObject:@{(NSString*)key:root}];
                }];
                self.results = resultsList;
                //刷新
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    }];
}



#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.results.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    ResponseRoot *root = [[self.results objectAtIndex:section] allValues].firstObject;
    return root.data.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ResultsCell *cell = (ResultsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    ResponseRoot *root = [[self.results objectAtIndex:indexPath.section] allValues].firstObject;
    Resource *resource = [root.data objectAtIndex:indexPath.row];

    //具体模型
    Class cls = [self classForResourceType:resource.type];
    id object = [cls instanceWithDict:resource.attributes];

    cell.name.text = [object valueForKey:@"name"];
    //有艺人名称
    if ([object respondsToSelector:@selector(artistName)]) {
        cell.artistName.text = [object valueForKey:@"artistName"];
    }else{
        cell.artistName.text = nil;
    }

    // 有海报
    if ([object respondsToSelector:@selector(artwork)]) {
        NSDictionary *artDict = [resource.attributes valueForKey:@"artwork"];
        Artwork *art = [Artwork instanceWithDict:artDict];
        [self showImageToView:cell.artworkView withImageURL:art.url cacheToMemory:NO];
    }else{
        cell.artworkView.image = nil;
    }
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    ResultsSectionHeader *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];

    [[self.results objectAtIndex:section] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, ResponseRoot * _Nonnull obj, BOOL * _Nonnull stop) {
        header.title.text = (NSString*)key;
        if (![obj valueForKey:@"next"]) {
            //无下一页
            header.more.hidden = YES;
        }else{
            header.more.hidden = NO;

            [header.more handleControlEvent:UIControlEventTouchUpInside withBlock:^{
                //按钮动画交互提示
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [header.more animateToType:buttonUpBasicType];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [header.more animateToType:buttonDownBasicType];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            //加载 下一页
                            [header.more animateToType:buttonMinusType];
                            [self loadNextPageWithHref:[obj valueForKey:@"next"] withSection:section];
                        });
                    });
                });
            }];

        }
    }];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0f;
}

#pragma mark UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ResponseRoot *root = [[self.results objectAtIndex:indexPath.section] allValues].firstObject;
    Resource *resource = [root.data objectAtIndex:indexPath.row];
    DetailViewController *detail = [[DetailViewController alloc] initWithResource:resource];
    [self.navigationController pushViewController:detail animated:YES];
}
//加载某一节 的下一页数据
-(void) loadNextPageWithHref:(NSString*) href withSection:(NSInteger) section{
    NSURLRequest *request = [[RequestFactory requestFactory] createRequestWithHerf:href];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
        if (json) {
            json = [json objectForKey:@"results"];
            //枚举当前的 josn
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                //枚举上一次加载的数据, 查找对应的Key  将返回的数据添加到data 数组中, 并覆盖next 值, 指向下一页
                [self.results enumerateObjectsUsingBlock:^(NSDictionary<NSString *,ResponseRoot *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    //用新的JSON key 在旧的数据中取值, 查找到数据
                    if ([obj valueForKey:key]) {
                        //取出模型, 添加数据,并更新值
                        ResponseRoot * oldRoot = [obj valueForKey:key];;
                        oldRoot.next = root.next;
                        oldRoot.data = [oldRoot.data arrayByAddingObjectsFromArray:root.data];
                        oldRoot.href = root.href;
                        //停止
                        *stop = YES;
                    }
                }];
            }];
        }
        //刷新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationFade];
        });
    }];
}




@end
