//
//  MMManagedObject.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/28.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "MMManagedObject.h"
#import "MMDataStack.h"

@implementation MMManagedObject

- (NSManagedObjectContext *)mainMoc{
    return [MMDataStack shareDataStack].context;
}

@end
