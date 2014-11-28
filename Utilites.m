//
//  Utilites.m
//  Приморский
//
//  Created by iosdev on 25.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import "Utilites.h"
#import "AppDelegate.h"
#import "CommonNews.h"

@implementation Utilites




+ (void)addUniqueCommonNewsToDataBase:(NSArray *)downloadedNews {
    

    
    // LOADING LAST NEWS FROM DATA BASE
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CommonNewsEntity inManagedObjectContext:moc];
    
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
            [Utilites insertNewFeedItem:item inMOC:moc forEntity:CommonNewsEntity];
        }
        [appDelegate saveContext];
        
    } else {
        if ([lastDBEntry count]) {
            CommonNews *news = [lastDBEntry firstObject];
            NSDate *lastDBEntryDate = news.date;
            
            for (MWFeedItem *downloadedNew in downloadedNews) {
                if (news.date && ([lastDBEntryDate compare:downloadedNew.date] == NSOrderedAscending)) {
                    NSLog(@"to DB added new entry with publishing date: %@ /n", downloadedNew.date);
                    [Utilites insertNewFeedItem:downloadedNew inMOC:moc forEntity:CommonNewsEntity];
                }
            }
            [appDelegate saveContext];
        }
    }
}


+ (void)updateCommonNewsInDataBase:(NSArray *)downloadedNews {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = appDelegate.managedObjectContext;
    
    NSFetchRequest * allMainNews = [[NSFetchRequest alloc] init];
    [allMainNews setEntity:[NSEntityDescription entityForName:MainNewsEntity inManagedObjectContext:moc]];
    [allMainNews setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    NSError * error = nil;
    NSArray * mainNews = [moc executeFetchRequest:allMainNews error:&error];
    
    //error handling goes here
    for (NSManagedObject * news in mainNews) {
        [moc deleteObject:news];
    }
    [appDelegate saveContext];
    
    for (MWFeedItem *downloadedNew in downloadedNews) {
        [Utilites insertNewFeedItem:downloadedNew inMOC:moc forEntity:MainNewsEntity];
    }
    [appDelegate saveContext];

}




+ (void)insertNewFeedItem:(MWFeedItem *)feedItem inMOC:(id)moc forEntity:(NSString *)entity {
    
    NSManagedObjectContext *manCont = moc;
    CommonNews *news = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:manCont];
    
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
    if (feedItem.link) {
        news.websiteLink = feedItem.link;
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
