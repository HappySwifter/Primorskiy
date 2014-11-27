//
//  MainNews.h
//  Приморский
//
//  Created by Artem on 27.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MainNews : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * websiteURL;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDate *date;

@end
