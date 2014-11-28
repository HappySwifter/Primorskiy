//
//  Constants.h
//  Приморский
//
//  Created by iosdev on 25.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//


#pragma mark - Debug
#define TESTDATA 0


#pragma mark - Website links
#define CommonNewsURL @"http://primorsky.ru/news/common/rss/"
#define MainNewsURL @"http://primorsky.ru/news/main/rss/"

#pragma mark - Cell identifiers
#define MAINNEWSCELL @"MainNewsCell"


#pragma mark - Data Base Entities
#define CommonNewsEntity @"CommonNews"
#define MainNewsEntity @"MainNews"


#pragma mark
#define CONTENTQUERY @"//div[@class='fntxt']/p"
#define VIDEOQUERY @"//div[@class='fnvid']/iframe"
//#define MAINNEWSQUERY @"//div[@class='npost']/a"


#pragma mark - other
#define TIMEZONEDIFF 10


typedef enum NewsType {
    CommonNewsType = 0,
    MainNewsType
} NewsType;