//
//  MMSearchData.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/24.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMSearchData.h"
#import "ResponseRoot.h"

@interface MMSearchData ()
@property(nonatomic, strong)NSArray<NSDictionary<NSString*,ResponseRoot*>*> *searchResults;
@property(nonatomic, strong)NSArray<NSString*> *hints;
@end

@implementation MMSearchData

-(NSInteger)sectionCount{
    return self.searchResults.count;
}
-(NSInteger)hintsCount{
    return self.hints.count;
}

- (NSString *)hintTextForIndex:(NSInteger)index{
    return [self.hints objectAtIndex:index];
}

- (void)searchDataForTemr:(NSString *)term completion:(void (^)(MMSearchData * _Nonnull))completion{
    [[MusicKit new].catalog searchForTerm:term callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        json = [json valueForKey:@"results"];
        //检查结果返回空结果字典
        if (json.allKeys.count != 0)  {

            NSMutableArray<NSDictionary<NSString*,ResponseRoot*>*> *resultsList = [NSMutableArray array];
            //解析字典
            [json enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ResponseRoot *root = [ResponseRoot instanceWithDict:obj];
                [resultsList addObject:@{(NSString*)key:root}];
            }];
            self.searchResults = resultsList;
        }
        if (completion) {
            completion(self);
        }
    }];
}

- (void)searchHintForTerm:(NSString *)term complectin:(void (^)(MMSearchData * _Nonnulll))completion{
    [MusicKit.new.catalog searchHintsForTerm:term callBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        if ([json valueForKeyPath: @"results.terms"]) {
            self.hints = [json valueForKeyPath:@"results.terms"];
            if (completion) {
                completion(self);
            }
        }
    }];
}


@end
