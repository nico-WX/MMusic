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

- (NSManagedObjectContext *)mainMoc{
    return [CoreDataStack shareDataStack].context;
}


- (NSSortDescriptor *)defaultSortDescriptor{
    return [NSSortDescriptor sortDescriptorWithKey:@"" ascending:0];
}
-(NSPredicate *)defaultPredicate{
    return [NSPredicate predicateWithValue:0];
}
@end

@implementation ManagedObject (DefaultManaged)


+ (NSPredicate *)defaultPredicate{
    return [NSPredicate predicateWithValue:0];
}
+(NSSortDescriptor *)defaultSortDescriptor{
    return [NSSortDescriptor sortDescriptorWithKey:@"" ascending:0];
}

+(NSString *)name{
    return NSStringFromClass(self);
}
@end
