//
//  DetailsImageCell.h
//  Приморский
//
//  Created by iosdev on 26.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *detailsImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;


@end
