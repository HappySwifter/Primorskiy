//
//  MasterViewController.h
//  Приморский
//
//  Created by Artem on 24.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>


@interface MasterViewController : UITableViewController


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end

