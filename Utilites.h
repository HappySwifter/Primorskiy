//
//  Utilites.h
//  Приморский
//
//  Created by iosdev on 25.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "MWFeedItem.h"
#import "Constants.h"
@interface Utilites : NSObject



+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
+ (void)addUniqueCommonNewsToDataBase:(NSArray *)downloadedNews;
+ (void)updateCommonNewsInDataBase:(NSArray *)downloadedNews;
//+ (void)insertNewFeedItem:(MWFeedItem *)feedItem inMOC:(id)moc forEntity:(NSString *)entity;
@end
