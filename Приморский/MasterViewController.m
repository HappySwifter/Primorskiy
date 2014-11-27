//
//  MasterViewController.m
//  Приморский
//
//  Created by Artem on 24.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import "MasterViewController.h"
#import "AppDelegate.h"
#import "MWFeedParser.h"
#import "News.h"
#import "NSString+HTML.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "Utilites.h"
#import "UIImageView+AFNetworking.h"
#import "NewsTableViewCell.h"
#import "NSDate+HumanizedTime.h"
#import "NewsDetailsVC.h"

@interface MasterViewController () <MWFeedParserDelegate> {
    MWFeedParser *feedParser;
    NSDateFormatter *formatter;

}
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *parsedItems;
@property (nonatomic, strong) NSMutableArray *newsToShow;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) BOOL isLoading;
@end

@implementation MasterViewController {

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Приморский край";
//    self.navigationController.hidesBarsOnSwipe = YES;
    self.parsedItems = [[NSMutableArray alloc]init];
    self.newsToShow = [[NSMutableArray alloc]init];

    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventAllEvents];
    self.refreshControl = refreshControl;
    
    self.hud = [[MBProgressHUD alloc]initWithView:self.view];
    
    if (TESTDATA) {
        [self loadNext];
    } else {
        [self downloadAndParseData];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender {
    if ([segue.identifier isEqualToString:@"ShowDetailsSegue"]) {
        NewsDetailsVC *controller = segue.destinationViewController;
        controller.news = self.newsToShow[sender.row];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newsToShow count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    if (indexPath.row > [self.newsToShow count] - 2) {
        [self loadNext];
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsTableViewCell *newsCell = (NewsTableViewCell *)cell;
    newsCell.newsImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [UIView animateWithDuration:0.3 animations:^{
        newsCell.newsImageView.transform = CGAffineTransformMakeScale(1, 1);
    }];
}

- (void)configureCell:(NewsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    News *item = [self.newsToShow objectAtIndex:indexPath.row];
    if (item) {
        
        // Process
        NSString *itemTitle = item.title ? [item.title stringByConvertingHTMLToPlainText] : @"Без заголовка";
        
        if (item.date) {
//            cell.dateLabel.text = [NSString stringWithFormat:@"%@", item.date];
//           NSString *dateStrr = [self fixDate:item.date];
//            NSString *dateStr =[item.date stringWithHumanizedTimeDifference:NSDateHumanizedSuffixAgo withFullString:NO];
            cell.dateLabel.text = [self fixDateWithTimeZone:item.date];

        } else {
            cell.dateLabel.text = @"";
        }

        // Set
        cell.titleLabel.text = itemTitle;
        
        
        if ([item.imageURL length]) {
            NSURL *imageURL = [NSURL URLWithString:item.imageURL];
            cell.newsImageView.hidden = YES;
            [cell.loadingIndicator startAnimating];
            cell.loadingIndicator.tintColor = [UIColor orangeColor];
            cell.loadingIndicator.hidesWhenStopped = YES;
            [cell.newsImageView setImageWithURLRequest:[NSURLRequest requestWithURL:imageURL] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [cell.loadingIndicator stopAnimating];
                cell.newsImageView.image = image;
                cell.newsImageView.hidden = NO;
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [cell.loadingIndicator stopAnimating];
                cell.newsImageView.image = [UIImage imageNamed:@"error_image"];
                cell.newsImageView.hidden = NO;
            }];
        }
    }
}


- (NSString *)fixDateWithTimeZone:(NSDate *)newsDate {
//    NSString *dateStr = @"2012-07-16 07:33:01";
//    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
//    [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSDate *date = newsDate;
//    NSLog(@"date : %@",newsDate);
//    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
//    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
//    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:date];
//    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
//    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:TIMEZONEDIFF sinceDate:newsDate];
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"dd-MMM-yyyy hh:mm"];
    [dateFormatters setDateStyle:NSDateFormatterShortStyle];
    [dateFormatters setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatters setDoesRelativeDateFormatting:YES];
    [dateFormatters setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatters stringFromDate: destinationDate];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowDetailsSegue" sender:indexPath];
}


#pragma mark - feed parser delegates

- (void)feedParserDidStart:(MWFeedParser *)parser {
    NSLog(@"Started Parsing: %@", parser.url);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
//    NSLog(@"Parsed Feed Info: “%@”", info.title);
}

- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
//    NSLog(@"Parsed Feed Item: “%@”", item.title);
    if (item) [self.parsedItems addObject:item];
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
    NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    [self.hud hide:YES];
    [Utilites addUniqueNewsToDataBase:self.parsedItems];
    [self loadNext];
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"Finished Parsing With Error: %@", error);
    [self loadNext];
    [self.hud hide:YES];

    if (self.parsedItems.count == 0) {
    } else {
        // Failed but some items parsed, so show and inform of error
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing Incomplete"
                                                        message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - private

- (void)loadNext {
    
    if ((!self.isLoading) && ([self.newsToShow count] < [self countRowinDB])) {
        self.isLoading = YES;
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:CommonNewsEntity inManagedObjectContext:self.managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:@"date" ascending:NO];
        [request setSortDescriptors:@[sortDescriptor]];
        request.fetchOffset = [self.newsToShow count];;
        request.fetchLimit = 30;
        
        NSError *error;
        NSArray *news = [self.managedObjectContext executeFetchRequest:request error:&error];
        [self.newsToShow addObjectsFromArray:news];
        NSLog(@"loaded news from DB. Count: %i", [self.newsToShow count]);
        [self.tableView reloadData];
        self.isLoading = NO;
    }

}

- (void)downloadAndParseData {
    [self.hud show:YES];
    NSURL *feedURL = [NSURL URLWithString:CommonNewsURL];
    feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
    feedParser.delegate = self;
    feedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
    feedParser.connectionType = ConnectionTypeAsynchronously;
    [feedParser parse];
}

- (void)refreshAction {
    [self.refreshControl endRefreshing];
    [self clear];
    [self downloadAndParseData];
    [self.tableView reloadData];
}


- (void)clear {
    [self.parsedItems removeAllObjects];
    [self.newsToShow removeAllObjects];
}



- (int)countRowinDB {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:CommonNewsEntity inManagedObjectContext:self.managedObjectContext]];
    NSError *error;
   int count = [self.managedObjectContext countForFetchRequest:request error:&error];
    if (!error) {
        return count;
    } else {
        // TODO handle error
        return 0;
    }
}

@end
