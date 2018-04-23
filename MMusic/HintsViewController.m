//
//  HintsViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/21.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "HintsViewController.h"
#import "RequestFactory.h"
#import "ResultsViewController.h"

@interface HintsViewController ()
@end

@implementation HintsViewController

static NSString *const cellID = @"cellReuseIdentifier";
- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:cellID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.terms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.text = [self.terms objectAtIndex:indexPath.row];
    return cell;
}
- (void)showHintsFromTerms:(NSString *)term{
    NSURLRequest *request = [[RequestFactory requestFactory] createSearchHintsWithTerm:term];
    [self dataTaskWithdRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data && !error) {
            NSDictionary *json = [self serializationDataWithResponse:response data:data error:nil];
            if ([json valueForKeyPath: @"results.terms"]) {
                _terms = [json valueForKeyPath:@"results.terms"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
    }];
}


@end
