//
//  ShowAllSearchResultsDataSource.m
//  MMusic
//
//  Created by 🐙怪兽 on 2019/1/24.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import "ShowAllSearchResultsDataSource.h"
#import "ResponseRoot.h"
#import "NSURLRequest+Extension.h"

@interface ShowAllSearchResultsDataSource ()<UICollectionViewDataSource>
@property(nonatomic,strong)ResponseRoot *root;
@end

@implementation ShowAllSearchResultsDataSource


- (instancetype)initWithView:(UICollectionView *)collectionView identifier:(NSString *)identifier responseRoot:(ResponseRoot *)root delegate:(id<DataSourceDelegate>)delegate{
    if (self = [super initWithCollectionView:collectionView identifier:identifier sectionIdentifier:nil delegate:delegate]) {
        _root = root;

        [self laodAllDataWithResponseRoot:_root completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [collectionView reloadData];
            });
        }];
    }
    return self;
}

- (void)laodAllDataWithResponseRoot:(ResponseRoot*)root completion:(void(^)(void))completion{
    [self loadNextPageWithPath:_root.next completion:completion];
}

- (void)loadNextPageWithPath:(NSString*)next completion:(void(^)(void))completion{
    NSURLRequest *request = [NSURLRequest createRequestWithHref:next];
    [self dataTaskWithRequest:request handler:^(NSDictionary *json, NSHTTPURLResponse *response) {
        //@{@"results":@{@"resourceType":ResponseRoot*};
        json = [json valueForKey:@"results"];
        if (json) {
            __block ResponseRoot *newRoot;
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                newRoot = [ResponseRoot instanceWithDict:obj];
            }];

            self.root.next = newRoot.next;
            [self.root.data addObjectsFromArray:newRoot.data];
            if (self.root.next) {
                [self loadNextPageWithPath:self.root.next completion:completion];
            }else{
                completion();
            }
        }
    }];
}

- (NSArray<Resource *> *)data{
    return self.root.data;
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _root.data.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.identifier forIndexPath:indexPath];
    Resource *resource = [self.root.data objectAtIndex:indexPath.row];
    [self configureCell:cell item:resource atIndexPath:indexPath];
    return cell;
}
@end
