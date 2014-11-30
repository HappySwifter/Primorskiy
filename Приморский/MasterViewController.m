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
#import "NSString+HTML.h"
#import "Constants.h"
#import "MBProgressHUD.h"
#import "Utilites.h"
//#import "UIImageView+AFNetworking.h"
#import "NewsTableViewCell.h"
#import "NSDate+HumanizedTime.h"
#import "NewsDetailsVC.h"

#import "ASOXScrollTableViewCell.h"
#import "XScrollViewCell.h"

#import "CommonNews.h"
#import "MainNews.h"

#import <SDWebImage/UIImageView+WebCache.h>


@interface MasterViewController () <MWFeedParserDelegate, ASOXScrollTableViewCellDelegate, SDWebImageManagerDelegate> {
    
    NSDateFormatter *formatter;

}
@property (nonatomic, strong) MWFeedParser *mainNewsFeedParser;
@property (nonatomic, strong) MWFeedParser *commonNewsFeedParser;

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *parsedCommonNews;
@property (nonatomic, strong) NSMutableArray *parsedMainNews;


@property (nonatomic, strong) NSMutableArray *mainNewsToShow;
@property (nonatomic, strong) NSMutableArray *newsToShow;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic) BOOL isLoading;

@property (nonatomic, strong) SDWebImageManager *imageManager;

@property (nonatomic) BOOL dragging;
@property (nonatomic) CGPoint lastContentOffset;

@end

@implementation MasterViewController {

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Приморский край";
    
    self.imageManager = [SDWebImageManager sharedManager];
    self.imageManager.delegate = self;
    
//    self.navigationController.hidesBarsOnSwipe = YES;
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    self.parsedCommonNews = [[NSMutableArray alloc]init];
    self.parsedMainNews = [[NSMutableArray alloc]init];
    self.newsToShow = [[NSMutableArray alloc]init];
    self.mainNewsToShow = [[NSMutableArray alloc]init];

    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventAllEvents];
    self.refreshControl = refreshControl;
    
    self.hud = [[MBProgressHUD alloc]initWithView:self.view];
    
    
    [self downloadAndParseNews];

    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender {
    if ([segue.identifier isEqualToString:@"ShowDetailsSegue"]) {
        NewsDetailsVC *controller = segue.destinationViewController;
        controller.news = self.newsToShow[sender.row];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        //
//        if ([self.newsToShow count]) {
//            return 3;
//        }
//        else {
//            return 0;
//        }
        //
        return [self.newsToShow count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        ASOXScrollTableViewCell *cell = [ASOXScrollTableViewCell tableView:tableView cellForRowInTableViewIndexPath:indexPath withReusableCellIdentifier:MAINNEWSCELL delegate:self];
        return cell;
    } else {
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        
        [self configureCell:cell atIndexPath:indexPath];
        
        if (indexPath.row > [self.newsToShow count] - 2) {
            [self loadNext];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 210;
    } else {
        return 102;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 1) {
//        NewsTableViewCell *newsCell = (NewsTableViewCell *)cell;
//        newsCell.newsImageView.transform = CGAffineTransformMakeScale(0.8, 0.8);
//        [UIView animateWithDuration:0.3 animations:^{
//            newsCell.newsImageView.transform = CGAffineTransformMakeScale(1, 1);
//        }];
//    }
   
}

- (void)configureCell:(NewsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {

    
    

    CommonNews *item = [self.newsToShow objectAtIndex:indexPath.row];
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
            
            [self.imageManager downloadImageWithURL:imageURL options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    cell.newsImageView.image = image;
                    cell.newsImageView.hidden = NO;
                } else {
                    NSLog(@"image download error: %@", error.description);
                    cell.newsImageView.image = [UIImage imageNamed:@"error_image"];
                    cell.newsImageView.hidden = NO;
                }
                [cell.loadingIndicator stopAnimating];
                
            }];
        }
    }
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
    if (parser == self.mainNewsFeedParser) {
        if (item) [self.parsedMainNews addObject:item];
    }
    if (parser == self.commonNewsFeedParser) {
        if (item) [self.parsedCommonNews addObject:item];
    }
}

- (void)feedParserDidFinish:(MWFeedParser *)parser {
    NSLog(@"Finished Parsing%@", (parser.stopped ? @" (Stopped)" : @""));
    if (parser == self.mainNewsFeedParser) {
        [Utilites updateCommonNewsInDataBase:self.parsedMainNews];
        [self showMainNews];
    }
    
    if (parser == self.commonNewsFeedParser) {
        [self.hud hide:YES];
        [Utilites addUniqueCommonNewsToDataBase:self.parsedCommonNews];
        [self loadNext];
    }
}

- (void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"Finished Parsing With Error: %@", error);
    [self loadNext];
    [self.hud hide:YES];

    if (parser == self.mainNewsFeedParser) {
        if (self.parsedMainNews.count == 0) {
        } else {
            // Failed but some items parsed, so show and inform of error
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing main mews Incomplete"
                                                            message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    
    if (parser == self.commonNewsFeedParser) {
        if (self.parsedCommonNews.count == 0) {
        } else {
            // Failed but some items parsed, so show and inform of error
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Parsing common mews Incomplete"
                                                            message:@"There was an error during the parsing of this feed. Not all of the feed items could parsed."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        }
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

- (void)showMainNews
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:MainNewsEntity inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"date" ascending:NO];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *news = [self.managedObjectContext executeFetchRequest:request error:&error];
    [self.mainNewsToShow addObjectsFromArray:news];
    NSLog(@"loaded news from DB. Count: %i", [self.mainNewsToShow count]);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationRight];
    
    NSURL *commonNewsFeedURL = [NSURL URLWithString:CommonNewsURL];
    self.commonNewsFeedParser = [[MWFeedParser alloc] initWithFeedURL:commonNewsFeedURL];
    self.commonNewsFeedParser.delegate = self;
    self.commonNewsFeedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
    self.commonNewsFeedParser.connectionType = ConnectionTypeAsynchronously;
    [self.commonNewsFeedParser parse];
    
//    [self.tableView reloadData];
}

- (void)downloadAndParseNews {
    [self.hud show:YES];

    NSURL *mainNewsFeedURL = [NSURL URLWithString:MainNewsURL];
    self.mainNewsFeedParser = [[MWFeedParser alloc] initWithFeedURL:mainNewsFeedURL];
    self.mainNewsFeedParser.delegate = self;
    self.mainNewsFeedParser.feedParseType = ParseTypeFull; // Parse feed info and all items
    self.mainNewsFeedParser.connectionType = ConnectionTypeAsynchronously;
    [self.mainNewsFeedParser parse];

    
   
}


- (void)refreshAction {
    [self.refreshControl endRefreshing];
    [self clear];
    [self.tableView reloadData];
    [self downloadAndParseNews];
}


- (void)clear {
    [self.parsedMainNews removeAllObjects];
    [self.parsedCommonNews removeAllObjects];
    [self.newsToShow removeAllObjects];
    [self.mainNewsToShow removeAllObjects];
    
    
//    SDImageCache *c = [SDImageCache sharedImageCache];
//    [c clearDisk];
//    [c clearMemory];
//    [c cleanDisk];
//    NSLog(@"cleanes disk");
}



- (int)countRowinDB { // чтобы не пытаться грузить новости которых нет
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

- (NSString *)fixDateWithTimeZone:(NSDate *)newsDate {
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:TIMEZONEDIFF sinceDate:newsDate];
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    [dateFormatters setDateFormat:@"dd-MMM-yyyy hh:mm"];
    [dateFormatters setDateStyle:NSDateFormatterShortStyle];
    [dateFormatters setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatters setDoesRelativeDateFormatting:YES];
    [dateFormatters setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatters stringFromDate: destinationDate];
}




#pragma mark - ASOXScrollTableViewCellDelegate

- (NSInteger)horizontalScrollContentsView:(UICollectionView *)horizontalScrollContentsView numberOfItemsInTableViewIndexPath:(NSIndexPath *)tableViewIndexPath {
    
    // Return the number of items in each category to be displayed on each ASOXScrollTableViewCell object
    return [self.mainNewsToShow count];
}

- (UICollectionViewCell *)horizontalScrollContentsView:(UICollectionView *)horizontalScrollContentsView cellForItemAtContentIndexPath:(NSIndexPath *)contentIndexPath inTableViewIndexPath:(NSIndexPath *)tableViewIndexPath {
    
    
    XScrollViewCell *cell = (XScrollViewCell *)[horizontalScrollContentsView dequeueReusableCellWithReuseIdentifier:@"XScrollViewCell" forIndexPath:contentIndexPath];
 
    MainNews *news = [self.mainNewsToShow objectAtIndex:contentIndexPath.item];

    
    cell.articleImage.hidden = YES;
    
    [self.imageManager downloadImageWithURL:[NSURL URLWithString:news.imageURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (image) {

            cell.articleImage.image = image;
            cell.articleImage.hidden = NO;

        } else {
            cell.articleImage.hidden = NO;
            NSLog(@"image download error: %@", error.description);
        }
    }];
    
    
    return cell;
}

- (void)horizontalScrollContentsView:(UICollectionView *)horizontalScrollContentsView didSelectItemAtContentIndexPath:(NSIndexPath *)contentIndexPath inTableViewIndexPath:(NSIndexPath *)tableViewIndexPath {
    
    [horizontalScrollContentsView deselectItemAtIndexPath:contentIndexPath animated:YES]; // A custom behaviour in this example for removing highlight from the cell immediately after it had been selected
    
    NSLog(@"Section %ld Row %ld Item %ld is selected", (unsigned long)tableViewIndexPath.section, (unsigned long)tableViewIndexPath.row, (unsigned long)contentIndexPath.item);
}


#pragma mark - SDWebImageView delegate

- (UIImage *)imageManager:(SDWebImageManager *)imageManager transformDownloadedImage:(UIImage *)image withURL:(NSURL *)imageURL
{
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) { // check for retina
        if (image.size.width > 260 && image.size.height > 170) {
            return [Utilites imageWithImage:image scaledToSize:CGSizeMake(260, 170)];
        }
    } else {
        if (image.size.width > 130 && image.size.height > 85) {
            return [Utilites imageWithImage:image scaledToSize:CGSizeMake(130, 85)];
        }
    }
    return image;
}




#pragma mark - tab bar manipulations

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _dragging=YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _dragging=NO;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if ([scrollView isKindOfClass:[UITableView class]] && self.navigationController.visibleViewController == self) {
//        
//        CGPoint currentOffset = scrollView.contentOffset;
//        if (currentOffset.y > 0 && _dragging) {
//            if (currentOffset.y < _lastContentOffset.y)
//            {
//                
//                CGRect screenRect = [[UIScreen mainScreen] bounds];
//                float fHeight = screenRect.size.height - self.tabBarController.tabBar.frame.size.height;
//
//                if (self.tabBarController.tabBar.frame.origin.y >= fHeight) {
//                    [self showTabBar];
//                }
//            }
//            else
//            {
//                CGRect screenRect = [[UIScreen mainScreen] bounds];
//                float fHeight = screenRect.size.height;
//                if (self.tabBarController.tabBar.frame.origin.y <= fHeight) {
//                    [self hideTabBar];
//                }
//            }
//            _lastContentOffset = currentOffset;
//        }
//    }
}




- (IBAction)SettingsTouched:(id)sender {
    
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.tabBarController.tabBar setHidden:!self.tabBarController.tabBar.isHidden];
//
//    }];
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[self.view.window layer] addAnimation:animation forKey:@"layerAnimation"];
    [self.tabBarController.tabBar setHidden:!self.tabBarController.tabBar.isHidden];

//    self.tabBarController.tabBar.isHidden ? [self showTabBar] : [self hideTabBar];
    
    
    
    
    
    
}




- (void) hideTabBar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    float fHeight = screenRect.size.height;
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width;
    }
    
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
            view.backgroundColor = [UIColor blackColor];
        }
    }
    [UIView commitAnimations];
}



- (void) showTabBar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float fHeight = screenRect.size.height - self.tabBarController.tabBar.frame.size.height;
    
    if(  UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) )
    {
        fHeight = screenRect.size.width - self.tabBarController.tabBar.frame.size.height;
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    for(UIView *view in self.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
        }
    }
    [UIView commitAnimations];
}

#pragma mark - Actions


@end
