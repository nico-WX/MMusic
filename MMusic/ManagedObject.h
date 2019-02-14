//
//  ManagedObject.h
//  MMusic
//
//  Created by 🐙怪兽 on 2018/12/28.
//  Copyright © 2018 com.😈. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN


@interface ManagedObject : NSManagedObject
@property(nonatomic, readonly,strong) NSManagedObjectContext *viewContext;
//@property(nonatomic, readonly,strong) NSManagedObjectContext *backgroupMoc;

+ (NSPredicate*)defaultPredicate;
+ (NSSortDescriptor*)defaultSortDescriptor;
+ (NSString*)entityName;

@end


NS_ASSUME_NONNULL_END
