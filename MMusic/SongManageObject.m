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

@implementation SongManageObject

@dynamic name,movementName,composerName,genreNames,artistName,workName,contentRating,artwork,discNumber,durationInMillis,editorialNotes,isrc,movementNumber,movementCount,playParams,releaseDate,trackNumber,url,identifier;

//+(instancetype)insertIntoContext:(NSManagedObjectContext *)context withSong:(Song *)song{    
//    if (self = [[super alloc] initWithContext:context]) {
//    }
//    return self;
//}

- (instancetype)initWithSong:(Song *)song{
    if (self = [super initWithContext:self.mainMoc]) {

        //映射属性 <artwork另外生成对象> // @"previews"
        NSArray *propertyes = @[@"name",@"movementName",@"composerName",@"genreNames",@"artistName",@"workName",@"contentRating",@"discNumber",@"durationInMillis",@"editorialNotes",@"isrc",@"movementNumber",@"movementCount",@"playParams",@"releaseDate",@"trackNumber",@"url"];
        for (NSString *key in propertyes) {
            if ([song.attributes valueForKey:key]) {
                [self setValue:[song.attributes valueForKey:key] forKey:key];
            }
        }

        [self setValue:song.attributes.playParams[@"id"] forKey:@"identifier"];

        Artwork *art = song.attributes.artwork;
        NSDictionary *dict = @{@"url":art.url,@"height":@(art.height),@"width":@(art.width)};
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

@implementation SongManageObject (DefaultManaged)

+ (NSSortDescriptor *)defaultSortDescriptor{
    return [NSSortDescriptor sortDescriptorWithKey:@"artistName" ascending:0];
}
+(NSString *)name{
    return @"Song";
}

@end
