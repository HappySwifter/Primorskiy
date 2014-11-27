//
//  NewsDetailsVC.m
//  Приморский
//
//  Created by iosdev on 26.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

// TODO if content lenght > 1

#import "NewsDetailsVC.h"
#import "TFHpple.h"
#import "DetailsImageCell.h"
#import "DetailsTextCell.h"
#import "UIImageView+AFNetworking.h"

#define IMGQUERY @"//div[@class='fntxt']/p/img"
#define TEXTQUERY @"//div[@class='fntxt']/p"


@interface NewsDetailsVC ()
@property (strong, nonatomic)  NSMutableArray *newsContent;

@end

@implementation NewsDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//     self.tableView.estimatedRowHeight = 1000.0;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    
//    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"HTMLExample" withExtension:nil];
    
    NSData *htmlData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.news.websiteLink]];
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:htmlData];
    
    
   self.newsContent = [[NSMutableArray alloc]initWithCapacity:100];

    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:TEXTQUERY];
    
    for (TFHppleElement *element in tutorialsNodes) {
        
        
        if ([element content]) {
            [self insertTextTOArray:[element content]];
//            NSLog(@"element 0 content %@", [element content]);
        } else if ([[element tagName] isEqualToString:@"img"]) {
            [self insertImageURLToArray:[element attributes][@"src"]];
//            NSLog(@"image 0 = %@", [element attributes][@"src"]);
        } else {
            for (TFHppleElement *elementt in [element children]) {
                
                if ([elementt content]) {
                    [self insertTextTOArray:[elementt content]];
//                    NSLog(@"element 1 content %@", [elementt content]);
                } else if ([[elementt tagName] isEqualToString:@"img"]) {
                     [self insertImageURLToArray:[elementt attributes][@"src"]];
//                    NSLog(@"image 1 = %@", [elementt attributes][@"src"]);
                } else {
                     for (TFHppleElement *elementtt in [elementt children]) {
                     
                         if ([elementtt content]) {
                             [self insertTextTOArray:[elementtt content]];
//                             NSLog(@"element 2 content %@", [elementtt content]);
                         } else if ([[elementtt tagName] isEqualToString:@"img"]) {
//                             NSLog(@"image 2 = %@", [elementtt attributes][@"src"]);
                            [self insertImageURLToArray:[elementtt attributes][@"src"]];
                         } else {
                             for (TFHppleElement *elementttt in [elementtt children]) {
                                 if ([elementttt content]) {
                                     [self insertTextTOArray:[elementttt content]];
//                                     NSLog(@"element 3 content %@", [elementttt content]);
                                 } else if ([[elementttt tagName] isEqualToString:@"img"]) {
//                                     NSLog(@"image 3 = %@", [elementttt attributes][@"src"]);
                                    [self insertImageURLToArray:[elementttt attributes][@"src"]];
                                 }
                             }
                         }
                     }
                }
            }
        }
    }
    [self.tableView reloadData];
}


- (void)insertImageURLToArray:(NSString *)image {
    NSString *baseURL = @"http://primorsky.ru";
    NSString *fullString = [NSString stringWithFormat:@"%@%@", baseURL, image];
    NSURL *imageURL = [NSURL URLWithString:fullString];
    [self.newsContent addObject:imageURL];
}

- (void)insertTextTOArray:(NSString *)text {
    
    // TODO replace пробел/новая строка на пустоту
    if ([text length] > 1) {
        [self.newsContent addObject:text];

    } else {
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.newsContent count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id item = self.newsContent[indexPath.row];
    
    if ([item isKindOfClass:[NSURL class]]) {
        
        DetailsImageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        cell.detailsImageView.hidden = YES;
        [cell.loadingIndicator startAnimating];
        cell.loadingIndicator.tintColor = [UIColor blueColor];
        cell.loadingIndicator.hidesWhenStopped = YES;

        [cell.detailsImageView setImageWithURLRequest:[NSURLRequest requestWithURL:item] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [cell.loadingIndicator stopAnimating];
            cell.detailsImageView.hidden = NO;
            cell.detailsImageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            UIImage *errorImage = nil; // TODO add error image
            cell.detailsImageView.image = errorImage;
        }];
        return cell;
    } else {
        DetailsTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        cell.detailsTextLabel.text = item;
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

@end
