//
//  Album.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"

@class Artwork;
@class EditorialNotes;

@interface Attributes ()

@end

/**专辑*/
@interface Album : Resource
/**歌手*/
@property(nonatomic, copy) NSString *artistName;
/**内容评级*/
@property(nonatomic, copy) NSString *contentRating;
/**版权信息*/
@property(nonatomic, copy) NSString *copyright;
/**专辑本地名称*/
@property(nonatomic, copy) NSString *name;
/**唱片公司*/
@property(nonatomic, copy) NSString *recordLabel;
/**发布日期*/
@property(nonatomic, copy) NSString *releaseDate;
/**专辑 iTuens Store分享URL*/
@property(nonatomic, copy) NSString *url;

/**海报*/
@property(nonatomic, strong) Artwork        *artwork;
/**评论*/
@property(nonatomic, strong) EditorialNotes *editorialNotes;
/**播放参数*/
@property(nonatomic, strong) NSDictionary   *playParams;
/**流派*/
@property(nonatomic, strong) NSArray<NSString*> *genreNames;
/**内容完整*/
@property(nonatomic) Boolean isComplete;
/**该专辑只有一首歌曲*/
@property(nonatomic) Boolean isSingle;
/**磁道号码*/
@property(nonatomic,assign) NSNumber *trackCount;
@end
