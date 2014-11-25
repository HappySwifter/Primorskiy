//
//  Utilites.h
//  Приморский
//
//  Created by iosdev on 25.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWFeedItem.h"

@interface Utilites : NSObject

+ (void)addUniqueNewsToDataBase:(NSArray *)downloadedNews;
+ (void)insertNewFeedItem:(MWFeedItem *)feedItem inMOC:(id)moc;
@end
