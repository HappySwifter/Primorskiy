//
//  News.h
//  Приморский
//
//  Created by iosdev on 26.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface News : NSManagedObject

@property (nonatomic, retain) NSNumber * attribute;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * websiteLink;

@end
