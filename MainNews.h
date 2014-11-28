//
//  MainNews.h
//  Приморский
//
//  Created by iosdev on 28.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MainNews : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * websiteLink;
@property (nonatomic, retain) NSString * subtitle;

@end
