//
//  DataSource.h
//  MMusic
//
//  Created by 🐙怪兽 on 2019/2/7.
//  Copyright © 2019 com.😈. All rights reserved.
//

#import <Foundation/Foundation.h>


//预留的Block, 
typedef void(^configureCellAtIndexPathBlock)(id cell, id item, NSIndexPath *atIndexPath);
typedef void(^configureCellBlock)(id cell, id item);

@protocol DataSourceDelegate <NSObject>

@optional
- (void)configureCell:(id)cell item:(id)item atIndexPath:(NSIndexPath*)indexPath;
- (void)configureCell:(id)cell item:(id)item ;

@end

//默认数据源实现都设置为 0
@interface DataSource : NSObject<UITableViewDataSource,UICollectionViewDataSource>
// init
@property(nonatomic,weak,readonly) UITableView *tableView;
@property(nonatomic,weak,readonly) UICollectionView *collectionView;
@property(nonatomic,weak,readonly) id<DataSourceDelegate> delegate;
@property(nonatomic,copy,readonly) NSString *identifier;
@property(nonatomic,copy,readonly) NSString *sectionIdentifier;

////数据容器
//@property(nonatomic,strong,readonly) NSArray *sectionArray;
//@property(nonatomic,strong,readonly) NSArray *section;


/**刷新数据源数据*/
- (void)reloadDataSource;
/**清除数据*/
- (void)clearDataSource;

/**子类辅助配置代理方法,子类内部配置数据时调用*/
- (void)configureCell:(id)cell item:(id)item atIndexPath:(NSIndexPath*)indexPath;

- (instancetype)initWithTableView:(UITableView*)tableViwe
                       identifier:(NSString*)identifier
                sectionIdentifier:(NSString*)sectionIdentifier
                         delegate:(id<DataSourceDelegate>)delegate;

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView
                            identifier:(NSString*)identifier
                     sectionIdentifier:(NSString*)sectionIdentifier
                              delegate:(id<DataSourceDelegate>)delegate;
@end


