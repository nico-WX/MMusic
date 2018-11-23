//
//  DataStore+Recommendations.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/11/8.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <objc/runtime.h>
#import "DataStore+Recommendations.h"
#import "Resource.h"

@implementation DataStore (Recommendations)



- (void)requestDefaultRecommendationWithCompletion:(defaultRecommendationBlock)callBack{

    [MusicKit.new.library defaultRecommendationsInCallBack:^(NSDictionary *json, NSHTTPURLResponse *response) {
        //数据临时集合 [{@"section title":[data]},...]
        NSMutableArray<NSDictionary<NSString*,NSArray<Resource*>*>*> *array = [NSMutableArray array];
        for (NSDictionary *subJSON in [json objectForKey:@"data"]) {
            //获取 section title
            NSString *title = [subJSON valueForKeyPath:@"attributes.title.stringForDisplay"];
            if (!title) {
                //部分情况下无显示名称, 向下获取歌单维护者
                NSArray *list = [subJSON valueForKeyPath:@"relationships.contents.data"];
                title = [list.firstObject valueForKeyPath:@"attributes.curatorName"];
            }

            NSArray *resources = [self serializationJSON:subJSON];
            NSDictionary *dict = @{title:resources};
            [array addObject:dict];
        }

        //数据解析完成
        if (callBack) {
            callBack(array);
        }
    }];
}
/**解析JSON 数据的嵌套*/
-(NSArray<Resource*>*) serializationJSON:(NSDictionary*) json{
    NSMutableArray<Resource*> *sectionList = [NSMutableArray array];  //section数据临时集合
    json = [json objectForKey:@"relationships"];
    NSDictionary *contents = [json objectForKey:@"contents"];  //如果这里有内容, 则不是组推荐,递归调用解析即可解析<组推荐json结构>
    if (contents) {
        //非组推荐
        for (NSDictionary *sourceDict in [contents objectForKey:@"data"]) {
            Resource *resouce = [Resource instanceWithDict:sourceDict];
            [sectionList addObject:resouce];
        }
    }else{
        //组推荐
        NSDictionary *recommendations = [json objectForKey:@"recommendations"];
        if (recommendations) {
            for (NSDictionary *subJSON  in [recommendations objectForKey:@"data"]) {
                //递归
                NSArray *temp =[self serializationJSON: subJSON];
                //数据添加
                [sectionList addObjectsFromArray:temp];
            }
        }
    }
    return sectionList;
}

- (void)setCount:(NSUInteger)count{
    NSNumber *value = [NSNumber numberWithUnsignedInteger:count];
    objc_setAssociatedObject(self, @selector(count), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSUInteger)count{
    NSNumber *value = objc_getAssociatedObject(self, @selector(count));
    return value.integerValue;
}
- (void)setSectionCount:(NSUInteger)sectionCount{
    NSNumber *value = [NSNumber numberWithInteger:sectionCount];
    objc_setAssociatedObject(self,@selector(sectionCount) , value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSUInteger)sectionCount{
    NSNumber *value = objc_getAssociatedObject(self, @selector(sectionCount));
    return value.integerValue;
}

@end
