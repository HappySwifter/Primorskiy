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
#import "NSString+XMLEntities.h"
#import "TTTAttributedLabel.h"
#import "Constants.h"
#import "WatchVideoCell.h"



@interface NewsDetailsVC () <TTTAttributedLabelDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) NSMutableArray *newsContent;
@property (strong, nonatomic) NSMutableArray *rowBlock;
@end

@implementation NewsDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
//     self.tableView.estimatedRowHeight = 200.0;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(NSIndexPath *)sender {
    if ([segue.identifier isEqualToString:@"WatchVideoSegue"]) {
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    self.newsContent = [[NSMutableArray alloc]initWithCapacity:100];
    self.rowBlock = [[NSMutableArray alloc]initWithCapacity:100];

    
//    NSData *data = [NSData dataWithContentsOfURL:filePathh];
//    NSString *stttr= [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSString *str = [stttr stringByDecodingHTMLEntities];
//    [self.newsContent addObject:str];
    
    NSURL *filePath;
    
    if (TESTDATA) {
        filePath = [[NSBundle mainBundle] URLForResource:@"HTMLExample" withExtension:nil];
    } else {
        filePath = [NSURL URLWithString:self.news.websiteLink];
    }
    NSData *htmlData = [NSData dataWithContentsOfURL:filePath];
    TFHpple *contentParser = [TFHpple hppleWithHTMLData:htmlData];
    
    

    NSArray *contentNodes = [contentParser searchWithXPathQuery:CONTENTQUERY];
    
    for (TFHppleElement *element in contentNodes) {
        [self addElementToArray:element];
            for (TFHppleElement *elementt in [element children]) {
                [self addElementToArray:elementt];
                for (TFHppleElement *elementtt in [elementt children]) {
                    [self addElementToArray:elementtt];
                    if ([[elementtt children]count]) {
                        TFHppleElement *elementttt = [elementtt children][0];
                        [self addElementToArray:elementttt];
                    }
                }
        }
    }
    [self addNewItemToShow];
    
    
    NSArray *videoNodes = [contentParser searchWithXPathQuery:VIDEOQUERY];
    for (TFHppleElement *element in videoNodes) {
        NSString *videoURL = [[element attributes]objectForKey:@"src"];
        if ([videoURL length] > 4) {
            [self.newsContent addObject:@{@"videoURL": videoURL}];
        }
    }
    
    
    [self.tableView reloadData];
   
}


- (void)insertImageURL:(NSString *)image toArray:(NSMutableArray *)array {
    NSString *baseURL = @"http://primorsky.ru";
    NSString *fullString = [NSString stringWithFormat:@"%@%@", baseURL, image];
    NSURL *imageURL = [NSURL URLWithString:fullString];
    [self.rowBlock addObject:imageURL];
}

//- (void)insertText:(NSString *)text toArray:(NSMutableArray *)array{
//    
////    NSString *summary = [text stringByRemovingNewLinesAndWhitespace];
//
//    // TODO replace пробел/новая строка на пустоту
//    if ([text length] > 1) {
//        [self.rowBlock addObject:text];
//
//    }
//    
//    else {
//        
//    }
//}

- (void)addElementToArray:(TFHppleElement *)element {
    
    
//    NSLog(@"____ELEMENT CONTENT -- %@", [element content]);
//    NSLog(@"____ELEMENT ATTRIBUNES -- %@", [element attributes]);
//    NSLog(@"____ELEMENT tagName -- %@", [element tagName]);
//    NSLog(@"+++++");
    if ([[element tagName] isEqualToString:@"p"]) {
        [self addNewItemToShow];

        
        
    } else {
        if ([[element content] length] > 1) {
            [self.rowBlock addObject:[element content]];
        }
        if ([[element tagName] isEqualToString:@"img"]) {
            [self insertImageURL:[element attributes][@"src"] toArray:self.rowBlock];
        }
    }
    

    
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
        cell.loadingIndicator.tintColor = [UIColor orangeColor];
        cell.loadingIndicator.hidesWhenStopped = YES;

        [cell.detailsImageView setImageWithURLRequest:[NSURLRequest requestWithURL:item] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [cell.loadingIndicator stopAnimating];
            cell.detailsImageView.hidden = NO;
            cell.detailsImageView.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [cell.loadingIndicator stopAnimating];
            cell.detailsImageView.image = [UIImage imageNamed:@"error_image"];
            cell.detailsImageView.hidden = NO;
        }];
        return cell;
    } else if ([item isKindOfClass:[NSDictionary class]]) {
        WatchVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VideoCell" forIndexPath:indexPath];
        return cell;
    } else {
        DetailsTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCell" forIndexPath:indexPath];
        cell.detailsTextLabel.attributedText = [self attributedBodyTextForIndexPath:indexPath];
        
        
        if (TESTDATA) {
            TTTAttributedLabel *tttLabel = (TTTAttributedLabel *)cell.detailsTextLabel;
            tttLabel.delegate = self;
            tttLabel.text = item;
            NSRange r = [item rangeOfString:@"Primamedia"];
            [tttLabel addLinkToURL:[NSURL URLWithString:@"http://primamedia.ru/news/sport/26.11.2014/403877/prezident-rossiyskogo-futbolnogo-soyuza-posetil-primore-s-rabochim-vizitom.html"] withRange:r];
        }

        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id item = self.newsContent[indexPath.row];
    
    if ([item isKindOfClass:[NSString class]]) {
        CGRect boundingRect = [[self attributedBodyTextForIndexPath:indexPath] boundingRectWithSize:CGSizeMake(self.tableView.bounds.size.width - 20, CGFLOAT_MAX)
                                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                      context:nil];
        return (CGFloat)(ceil(boundingRect.size.height) + 18);
    } else if ([item isKindOfClass:[NSDictionary class]]) {
        return 40;
    } else {
        return 210;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.newsContent[indexPath.row];
    if ([item isKindOfClass:[NSDictionary class]]) {
        [self performSegueWithIdentifier:@"WatchVideoSegue" sender:indexPath];
    }
}


#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    [[[UIActionSheet alloc] initWithTitle:[url absoluteString] delegate:self cancelButtonTitle:NSLocalizedString(@"Отмена", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Открыть ссылку в сафари", nil), nil] showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
}



#pragma mark - private

- (NSAttributedString *)attributedBodyTextForIndexPath:(NSIndexPath *)indexPath
{
    if (self.newsContent[indexPath.row]) {
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [UIFont fontWithName:@"HelveticaNeue" size:17], NSFontAttributeName,
                                              nil];
        return [[NSAttributedString alloc]initWithString:self.newsContent[indexPath.row] attributes:attributesDictionary];
    } else {
        return [[NSAttributedString alloc]initWithString:@""];
    }
    
}

- (void)addNewItemToShow {
    if ([self.rowBlock count] > 0) {
        
        if ([[self.rowBlock firstObject]isKindOfClass:[NSURL class]]) {
            [self.newsContent addObjectsFromArray:self.rowBlock];
        } else {
            NSString *rowData = [self.rowBlock componentsJoinedByString:@""];
            [self.newsContent addObject:rowData];
        }
        self.rowBlock = [NSMutableArray new]; //empty
    }
}

@end
