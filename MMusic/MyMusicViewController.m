//
//  MyMusicViewController.m
//  MMusic
//
//  Created by Magician on 2017/11/8.
//  Copyright © 2017年 com.😈. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import <StoreKit/StoreKit.h>

#import "MyMusicViewController.h"
#import "LocalMusicViewController.h"


@interface MyMusicViewController ()<SKCloudServiceSetupViewControllerDelegate>
@property(nonatomic, strong) NSArray<MPMediaItem*>  *items;
@end

static NSString *reuseId = @"MyMusicViewControllerCellId";
@implementation MyMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"我的音乐"];

    //读取本地音乐数据
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        if (status == SKCloudServiceAuthorizationStatusAuthorized) {
            self.items = [[MPMediaQuery songsQuery] items];
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }
    }];


    //注册Cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:reuseId];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
     self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
    if (indexPath.row == 0 && indexPath.section == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        NSString *detailStr = [NSString stringWithFormat:@"%ld",self.items.count];
        [cell.detailTextLabel setText:detailStr];
        [cell.textLabel setText:@"本地音乐"];
    }


    
    return cell;
}

#pragma mark - Table View Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0 && indexPath.section == 0) {
        LocalMusicViewController *lmCtr = [[LocalMusicViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:lmCtr animated:YES];
    }

    if (indexPath.row == 1) {
        SKCloudServiceSetupViewController *sVC = [[SKCloudServiceSetupViewController alloc] init];
        sVC.delegate = self;
        NSDictionary *dict = @{SKCloudServiceSetupOptionsMessageIdentifierKey:SKCloudServiceSetupMessageIdentifierJoin,
                               SKCloudServiceSetupOptionsActionKey : SKCloudServiceSetupActionSubscribe
                               };

        [sVC loadWithOptions:dict completionHandler:^(BOOL result, NSError * _Nullable error) {
            if (result) {
                [self.navigationController pushViewController:sVC animated:YES];
            }
        }];
    }
}

-(void)cloudServiceSetupViewControllerDidDismiss:(SKCloudServiceSetupViewController *)cloudServiceSetupViewController{
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[cloudServiceSetupViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
