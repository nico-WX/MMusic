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

@dynamic name,movementName,composerName,genreNames,artistName,workName,contentRating,artwork,discNumber,durationInMillis,editorialNotes,isrc,movementNumber,movementCount,playParams,releaseDate,trackNumber,url;

- (instancetype)initWithSong:(Song *)song{
    if (self = [super initWithContext:self.mainMoc]) {

        //映射属性 <artwork另外生成对象> // @"previews"
        NSArray *propertyes = @[@"name",@"movementName",@"composerName",@"genreNames",@"artistName",@"workName",@"contentRating",@"discNumber",@"durationInMillis",@"editorialNotes",@"isrc",@"movementNumber",@"movementCount",@"playParams",@"releaseDate",@"trackNumber",@"url"];
        for (NSString *key in propertyes) {
            [self setValue:[song valueForKey:key] forKey:key];
        }

        NSDictionary *dict = @{};
        [self setValue:dict forKey:@"artwork"];
    }
    return self;
}

- (NSPredicate *)defaultPredicate{
    return [NSPredicate predicateWithFormat:@" %K == %@",@"name",self.name];
}
- (NSSortDescriptor *)defaultSortDescriptor{
    return [NSSortDescriptor sortDescriptorWithKey:@"artistName" ascending:NO];
}

@end

@implementation MMCDMO_Song (DefaultManaged)

+ (NSSortDescriptor *)defaultSortDescriptor{
    return [NSSortDescriptor sortDescriptorWithKey:@"artistName" ascending:0];
}
//+(NSPredicate *)defaultPredicate{
//
//}

@end
