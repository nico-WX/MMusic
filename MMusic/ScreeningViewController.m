//
//  ScreeningViewController.m
//  MMusic
//
//  Created by Magician on 2018/4/26.
//  Copyright © 2018年 com.😈. All rights reserved.
//
#import <Masonry.h>
#import "ScreeningViewController.h"

@interface ScreeningViewController ()

@property(nonatomic, strong) NSArray<NSDictionary<NSString*,id>*> *screening;
@end


static int const row = 4;   //每行 列数
static CGFloat const lineSpacing= 2.0f;     //行距
static CGFloat const rowSpacing = 2.0f;     //列距

@implementation ScreeningViewController

#pragma mark - cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

#pragma mark - getter
-(NSArray<NSDictionary<NSString*,id>*> *)screening{
    if (!_screening) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"screening" ofType:@"plist"];
        NSDictionary *root = [NSDictionary dictionaryWithContentsOfFile:path];

        NSMutableArray<NSDictionary<NSString*,id>*> *rootList = NSMutableArray.new;
        [root enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            NSDictionary *dict = @{key:obj};
            [rootList addObject:dict];
        }];
        _screening = rootList;
    }
    return _screening;
}

@end
