//
//  HTTPNewsParser.m
//  Приморский
//
//  Created by iosdev on 28.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import "HTMLNewsParser.h"
#import "TFHpple.h"
#import "Constants.h"

@interface HTMLNewsParser ()

@property (nonatomic, strong) NSString *url;

@end

@implementation HTMLNewsParser



- (instancetype)initWithURL:(NSString *)URLString {
    self = [super init];
    if (self) {
        self.url = URLString;
    }
    return self;
}


- (void)parse {
    NSURL *filePath;
    
    if (TESTDATA) {
        filePath = [[NSBundle mainBundle] URLForResource:@"MainNewsHTMLExample" withExtension:nil];
    } else {
        filePath = [NSURL URLWithString:self.url];
    }
    NSData *htmlData = [NSData dataWithContentsOfURL:filePath];
    TFHpple *contentParser = [TFHpple hppleWithHTMLData:htmlData];
    
    
//#define MAINNEWSQUERY @"//div[@class='npost']/a"

//    NSArray *contentNodes = [contentParser searchWithXPathQuery:MAINNEWSQUERY];
//    
//    for (TFHppleElement *element in contentNodes) {
//        
//        
//        NSLog(@"tag name %@", [element tagName]);
//        NSLog(@"element content name %@", [element content]);
//
//        
//        for (TFHppleElement *newsElement in [element children]) {
//            NSLog(@"element____ %@", newsElement);

//        }
//    }

    
    //    for (TFHppleElement *element in contentNodes) {
    //        [self addElementToArray:element];
    //        for (TFHppleElement *elementt in [element children]) {
    //            [self addElementToArray:elementt];
    //            for (TFHppleElement *elementtt in [elementt children]) {
    //                [self addElementToArray:elementtt];
    //                if ([[elementtt children]count]) {
    //                    TFHppleElement *elementttt = [elementtt children][0];
    //                    [self addElementToArray:elementttt];
    //                }
    //            }
    //        }
    //    }
}

@end
