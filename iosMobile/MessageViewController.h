//
//  MessageViewController.h
//  Thrive
//
//  Created by Aaron Salo on 3/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MessageViewController : UIViewController  {
    UILabel *mCategoryTitle;
    UILabel *mCategoryAuthor;
    //UINavigationBar *mMessageTitle;
    //UIButton *mPlayButton;
    UILabel *mTime;
    UIProgressView *mMessageProgress;
    UIImageView *mImageView;
    NSString *webID;
    NSTimer *playbackTimer;
    UIProgressView *progressView;
    MPMoviePlayerController *audioPlayer;
    bool audioPlaying;
}

@property (nonatomic, retain) IBOutlet UILabel *mCategoryTitle;
@property (nonatomic, retain) IBOutlet UILabel *mCategoryAuthor;
@property (nonatomic, retain) IBOutlet UILabel *mTime;
@property (nonatomic, retain) IBOutlet UIImageView *mImageView;
@property (nonatomic, retain) MPMoviePlayerController *audioPlayer;
@property (nonatomic, retain) NSTimer *playbackTimer;
@property (nonatomic, retain) IBOutlet UIProgressView *progressView;

@property (nonatomic, retain) NSString *webID;

-(IBAction) playAudio;
-(void) loadMessage;

@end
