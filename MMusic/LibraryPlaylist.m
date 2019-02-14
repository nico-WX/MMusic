//
//  LibraryPlaylist.m
//  MMusic
//
//  Created by Magician on 2018/5/14.
//  Copyright © 2018年 com.😈. All rights reserved.
//

#import "LibraryPlaylist.h"
#import "Artwork.h"
#import "EditorialNotes.h"

@implementation LibraryPlaylist
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"desc":@"description"};
}

@end
