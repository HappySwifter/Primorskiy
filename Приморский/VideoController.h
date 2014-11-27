//
//  VideoController.h
//  Приморский
//
//  Created by iosdev on 27.11.14.
//  Copyright (c) 2014 J&L. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface VideoController : UIViewController  <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) MPMoviePlayerController *videoController;

- (IBAction)captureVideo:(id)sender;

@end
