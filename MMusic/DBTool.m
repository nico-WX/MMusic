//
//  DBTool.m
//  MMusic
//
//  Created by Magician on 2018/5/27.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <FMDB.h>
#import "DBTool.h"
#import "TracksModel.h"


@implementation DBTool

/**艺人表名*/
#define ARTISTS (@"t_artists")
/**歌曲表名*/
#define TRACKS  (@"t_tracks")

//表字段名称
//artists
static NSString *K_ArtistsName       = @"name";
static NSString *K_ArtistsIdentifier = @"identifier";
static NSString *K_ArtistsImage      = @"image";

//tracks 字段
static NSString *K_TracksIdentifier = @"identifier";
static NSString *K_TracksName       = @"name";


static FMDatabase *_db;

+(void)initialize{
    NSFileManager *fm = [NSFileManager defaultManager];

    //文件夹是否存在
    BOOL isDir ;
    BOOL exist = [fm fileExistsAtPath:DB_PATH isDirectory:&isDir];
    if (!(isDir && exist)) {
        [fm createDirectoryAtPath:DB_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }

    //路径下创建数据文件
    NSString *path = [DB_PATH stringByAppendingPathComponent:@"data.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];

    //删除表
    //    NSString *deleteArtists = [NSString stringWithFormat:@"DROP TABLE %@",ARTISTS];
    //    [_db executeUpdate:deleteArtists];


    //检查表 t_artists 和 t_tracks
    NSString *createArtists = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(\
                               identifier   TEXT PRIMARY KEY NOT NULL ,\
                               name         TEXT NOT NULL ,\
                               image        BLOB NOT NULL);",ARTISTS];

    NSString *createTracks  = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(\
                               identifier   TEXT PRIMARY KEY NOT NULL ,\
                               name         TEXT NOT NULL);",TRACKS];

    //没有表时 自动创建,
    [_db executeUpdate:createArtists];
    [_db executeUpdate:createTracks];
}

+(void)insertData:(DBModel *)dbModel{
    NSString *SQL;
    if ([dbModel isKindOfClass:ArtistsModel.class]) {
        ArtistsModel *artists = (ArtistsModel*) dbModel;
        NSData *data = UIImagePNGRepresentation(artists.image);
        SQL = [NSString stringWithFormat:@"INSERT INTO %@(name,identifier,image) VALUES('%@','%@','%@');",ARTISTS,artists.name,artists.identifier,data];

    }
    if ([dbModel isKindOfClass:TracksModel.class]) {
        TracksModel *track = (TracksModel*)dbModel;
        SQL = [NSString stringWithFormat:@"INSERT INTO %@(identifier,name) VALUES('%@','%@');",TRACKS,track.identifier,track.name];
    }

    if (SQL) {
         [_db executeUpdate:SQL];
    }
}


+(void)addArtists:(ArtistsModel *)artist{
    //先判断是否存在, 存在不再添加
    NSString *SQLString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE identifier=%@ ",ARTISTS,artist.identifier];
    FMResultSet *set = [_db  executeQuery:SQLString];

    if (!set.next) {

        if (artist.identifier && artist.name && artist.image) {
            [self insertData:artist];
            Log(@"插入记录 :%@",artist.name);
        }
    }else{
        //Log(@"有结果");
    }
}


+(void)deleteData:(DBModel *)dbModel{
    NSString *deleteSQL;
    if ([dbModel isKindOfClass:ArtistsModel.class]) {
        ArtistsModel *artist = (ArtistsModel*)dbModel;
        deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE name='%@';",ARTISTS,artist.name];
    }
    if ([dbModel isKindOfClass:TracksModel.class]) {
        TracksModel *track = (TracksModel*)dbModel;
        deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE identifier='%@';",TRACKS,track.identifier];

    }
    if (deleteSQL) {
        [_db executeUpdate:deleteSQL];
    }
}


//+(void)updateData:(DBModel *)dbModel withIdentifier:(NSString *)identifier{
//    NSString *updateSQL;
//    if ([dbModel isKindOfClass:ArtistsModel.class]) {
//        ArtistsModel *artist = (ArtistsModel*)dbModel;
//        NSData *data = UIImagePNGRepresentation(artist.image);
//        updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET name='%@', identifier='%@', image=%@ WHERE identifier='%@'; "\
//                     ,ARTISTS,artist.name,artist.identifier,data,identifier];
//    }
//    if ([dbModel isKindOfClass:TracksModel.class]) {
//        TracksModel *track = (TracksModel*)dbModel;
//        NSData *data = UIImagePNGRepresentation(track.artworkImage);
//        updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET identifier='%@',artists",TRACKS,track.identifier];
//    }
//
//    [_db executeUpdate:updateSQL];
//}


+(NSMutableArray *)selectFromType:(TableName)tableName{
    NSMutableArray *models = [NSMutableArray array];

    switch(tableName){

            //歌曲
        case TracksTable:{
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@;",TRACKS];
            FMResultSet *set = [_db executeQuery:selectSQL];
            while (set.next) {
                TracksModel *track = [TracksModel new];
                track.identifier        = [set stringForColumn:K_TracksIdentifier];
                track.name              = [set stringForColumn:K_TracksName];

                [models addObject:track];
            }
        }
        break;

            //艺人
        case ArtistsTable:{
            NSString *selectSQL = [NSString stringWithFormat:@"SELECT * FROM %@",ARTISTS];
            FMResultSet *set = [_db executeQuery:selectSQL];
            while(set.next){
                ArtistsModel *artist = [ArtistsModel new];
                artist.identifier   = [set stringForColumn:K_ArtistsIdentifier];
                artist.name         = [set stringForColumn:K_ArtistsName];

                NSData *data        = [set dataForColumn:K_ArtistsImage];
                artist.image = [UIImage imageWithData:data];

                [models addObject:artist];
            }
        }
        break;
    }
    return models;
}

@end
