//
//  Storefront.h
//  MMusic
//
//  Created by Magician on 2017/11/9.
//  Copyright © 2017年 com.😈. All rights reserved.
//

#import "Resource.h"

@interface Storefront : Resource
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *defaultLanguageTag;

@property(nonatomic, strong) NSArray<NSString*> *supportedLanguageTags;
@property(nonatomic, strong) NSNumber *storefrontId;

@end
