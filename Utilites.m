//
//  Utilites.m
//  Приморский
//
//  Created by iosdev on 25.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import "Utilites.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "News.h"

@implementation Utilites




+ (void)addUniqueNewsToDataBase:(NSArray *)downloadedNews {
    
    // LOADING LAST NEWS FROM DATA BASE
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:NewsEntity inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    request.fetchLimit = 1;
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"date" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *lastDBEntry = [moc executeFetchRequest:request error:&error];
    if (lastDBEntry == nil)
    {
        // load all
        // Deal with error...
    } else if ([lastDBEntry count] == 0) {
        // if DB is empty - save all new data to DB
        
        for (MWFeedItem *item in downloadedNews) {
            [Utilites insertNewFeedItem:item inMOC:moc];
        }
        [appDelegate saveContext];
        
    } else {
        if ([lastDBEntry count]) {
            News *news = [lastDBEntry firstObject];
            NSDate *lastDBEntryDate = news.date;
            
            for (MWFeedItem *downloadedNew in downloadedNews) {
                if (news.date && ([lastDBEntryDate compare:downloadedNew.date] == NSOrderedAscending)) {
                    NSLog(@"to DB added new entry with publishing date: %@ /n", downloadedNew.date);
                    [Utilites insertNewFeedItem:downloadedNew inMOC:moc];
                }
            }
            [appDelegate saveContext];
        }
        
    }
}

+ (void)insertNewFeedItem:(MWFeedItem *)feedItem inMOC:(id)moc {
    
    NSManagedObjectContext *manCont = moc;
    News *news = [NSEntityDescription insertNewObjectForEntityForName:NewsEntity inManagedObjectContext:manCont];
    
    if (feedItem.title) {
        news.title = feedItem.title;
    }
    if (feedItem.date) {
        news.date = feedItem.date;
    }
    if (feedItem.summary) {
        news.subtitle = feedItem.summary;
    }
    if ([feedItem.enclosures count]) {
        if ([feedItem.enclosures firstObject][@"url"]) {
            news.imageURL = [feedItem.enclosures firstObject][@"url"];
        }
    }
    
    
}



//func measure(title: String!, call: () -> Void) {
//    let startTime = CACurrentMediaTime()
//    call()
//    let endTime = CACurrentMediaTime()
//    if let title = title {
//        print("\(title): ")
//    }
//    println("Time - \(endTime - startTime)")
//}
//
//
//func doSomeWork() {
//    
//    measure("Array") {
//        var ar = [String]()
//        for i in 0...10000 {
//            ar.append("New elem \(i)")
//        }
//    }

@end
