//
//  DBTool.h
//  MMusic
//
//  Created by Magician on 2018/5/27.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "DBModel.h"
#import "ArtistsModel.h"



@interface DBTool : NSObject

typedef NS_ENUM(NSUInteger,TableName){
    ArtistsTable,
    TracksTable
};


+(void) insertData:(DBModel*) dbModel;
+(void) deleteData:(DBModel*) dbModel;
+(void) addArtists:(ArtistsModel*) artistsModel;
//+(void) updateData:(DBModel*) dbModel withIdentifier:(NSString*) identifier;
+(NSMutableArray*) selectFromType:(TableName) tableName;



@end
