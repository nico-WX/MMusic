//
//  MMManagedObject.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/28.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN


@interface MMManagedObject : NSManagedObject
@property(nonatomic, readonly,strong) NSManagedObjectContext *mainMoc;
//@property(nonatomic, readonly,strong) NSManagedObjectContext *backgroupMoc;

@end


@interface MMManagedObject (DefaultManaged)
//+ (NSEntityDescription*)entity;
//+ (NSString*)entityName;

+ (NSPredicate*)defaultPredicate;
+ (NSSortDescriptor*)defaultSortDescriptor;

@end


NS_ASSUME_NONNULL_END
