//
//  DetailsImageCell.m
//  Приморский
//
//  Created by iosdev on 26.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import "DetailsImageCell.h"

@implementation DetailsImageCell

- (void)awakeFromNib {
    self.loadingIndicator.tintColor = [UIColor blueColor];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
