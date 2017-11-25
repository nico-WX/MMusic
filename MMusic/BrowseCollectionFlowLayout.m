//
//  BrowseCollectionFlowLayout.m
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "BrowseCollectionFlowLayout.h"

@implementation BrowseCollectionFlowLayout
//cell 大小
-(CGSize)itemSize{
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 4) /2;
    CGFloat height= width;
    return CGSizeMake(width, height);
}

//头视图
-(CGSize)headerReferenceSize{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    return CGSizeMake(width, 44);
}
- (CGSize)footerReferenceSize{
    CGFloat width = [[UIScreen mainScreen] bounds].size.width;
    return CGSizeMake(width, 44);
}
-(CGFloat)minimumLineSpacing{
    return 2;
}

-(CGFloat)minimumInteritemSpacing{
    return 0;
}
//边距
-(UIEdgeInsets)sectionInset{
    return UIEdgeInsetsMake(4, 4, 4, 4);
}
//-(UICollectionViewScrollDirection)scrollDirection{
//    return UICollectionViewScrollDirectionVertical;
//}

/*
-(CGSize)collectionViewContentSize{

}
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{

}
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{

}
-(UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{

}
-(UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{

}
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{

}
*/
@end
