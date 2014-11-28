//
//  HTTPNewsParser.h
//  Приморский
//
//  Created by iosdev on 28.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HTMLNewsParserDelegate <NSObject>

@required
- (void)parserDidFinishParseData:(NSArray *)data;

@end


@interface HTMLNewsParser : NSObject

@property (nonatomic, weak) id <HTMLNewsParserDelegate> delegate;

- (instancetype)initWithURL:(NSString *)URLString;
- (void)parse;
@end
