//
//  MMManagedObject.m
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/28.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import "ManagedObject.h"
#import "CoreDataStack.h"

@implementation ManagedObject

+ (NSPredicate *)defaultPredicate{
    return [NSPredicate predicateWithValue:0];
}
+(NSSortDescriptor *)defaultSortDescriptor{
    return [NSSortDescriptor sortDescriptorWithKey:@"" ascending:0];
}

+(NSString *)entityName{
    NSLog(@"entityName =%@",[[self entity] name]);
    return [[self entity] name];
}


- (NSManagedObjectContext *)viewContext{
    return [CoreDataStack shareDataStack].context;
}
@end
