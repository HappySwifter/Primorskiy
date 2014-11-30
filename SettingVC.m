//
//  SettingVC.m
//  Приморский
//
//  Created by Artem on 30.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import "SettingVC.h"
#import "SDImageCache.h"


@implementation SettingVC



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;
    
    
    switch (section) {
        case 0:
            if (row == 0) { // изображения
                [self clearImages];
            }
            break;
            
        case 1:
            if (row == 0) { // главные новости
                
            } else if (row == 1) { // общие новости
                
            } else if (row == 2) { // детали новостей
                
            }
            
        default:
            break;
    }
    
    if (section == 0) {
        
    }
}



- (void)clearImages {
    SDImageCache *c = [SDImageCache sharedImageCache];
    NSLog(@"image cache size %i", [c getSize]);
    NSLog(@"image cache count %i", [c getDiskCount]);
    NSLog(@"deleting...");
    
    [c clearMemory];
    NSLog(@"memory cleaned");
    
    [c cleanDiskWithCompletionBlock:^{
        NSLog(@"disk cleaned");
    }];
    
    [c clearDiskOnCompletion:^{
        NSLog(@"disk cleared");
    }];
    
}

@end
