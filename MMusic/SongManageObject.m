//
//  MMCDMO_Song.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/26.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "SongManageObject.h"

#import "CoreDataStack.h"
#import "Artwork.h"
#import "Song.h"

@implementation SongManageObject

@dynamic addDate, identifier,name,artistName,artwork,playParams,url,durationInMillis;


+ (instancetype)insertSong:(Song *)song{
    return [[self alloc] initWithSong:song];
}


- (instancetype)initWithSong:(Song *)song{
    if (self = [super initWithContext:self.viewContext]) {

        //只读属性 addDate
        [self setValue:[NSDate date] forKey:@"addDate"];

        self.identifier = song.identifier;
        self.name = song.name;
        self.artistName = song.artistName;
        self.artwork = [song.artwork dictionaryValue];
        self.playParams = song.playParams;
        self.url = song.href;
        self.durationInMillis = song.durationInMillis;
    }
    return self;
}

@end

