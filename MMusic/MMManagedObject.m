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


- (NSSortDescriptor *)defaultSortDescriptor{
    return [NSSortDescriptor sortDescriptorWithKey:@"" ascending:0];
}
-(NSPredicate *)defaultPredicate{
    return [NSPredicate predicateWithValue:0];
}
@end

@implementation MMManagedObject (DefaultManaged)


+ (NSPredicate *)defaultPredicate{
    return [NSPredicate predicateWithValue:0];
}
+(NSSortDescriptor *)defaultSortDescriptor{
    return [NSSortDescriptor sortDescriptorWithKey:@"" ascending:0];
}

@end
