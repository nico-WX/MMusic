//
//  MMCDMO_Song.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMCDMO_Song.h"
#import "MMDataStack.h"
#import "Preview.h"

@implementation MMCDMO_Song

@dynamic name,movementName,composerName,genreNames,artistName,workName,contentRating,artwork,discNumber,durationInMillis,editorialNotes,isrc,movementNumber,movementCount,playParams,previews,releaseDate,trackNumber,url;

- (instancetype)initWithSong:(Song *)song{
    if (self = [super initWithContext:self.mainMoc]) {

        NSLog(@"song name =%@",song.name);

        //映射属性 <artwork另外生成对象> // @"previews"
        NSArray *propertyes = @[@"name",@"movementName",@"composerName",@"genreNames",@"artistName",@"workName",@"contentRating",@"discNumber",@"durationInMillis",@"editorialNotes",@"isrc",@"movementNumber",@"movementCount",@"playParams",@"releaseDate",@"trackNumber",@"url"];
        for (NSString *key in propertyes) {
            [self setValue:[song valueForKey:key] forKey:key];
        }

        NSLog(@"self song name =%@",self.name);


        //另外生成
        MMCDMO_Artwork *artwork = [[MMCDMO_Artwork alloc] initArtwork:song.artwork];
        self.artwork = artwork;
        //[self setValue:artwork forKey:@"artwork"];

        Preview *pre = song.previews.firstObject;
        if (pre) {

            NSLog(@"url =%@",pre.url);
            NSLog(@"art =%@",pre.artwork);

            NSDictionary *preDict = @{@"url":pre.url,@"artwork":@"pre.artwork"};
            self.previews = @[preDict,];
        }else{
            self.previews = @[];
        }

    }
    return self;
}


@end
