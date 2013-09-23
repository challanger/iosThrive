//
//  MessageViewController.m
//  Thrive
//
//  Created by Aaron Salo on 3/8/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageCategory.h"
#import "MessageItem.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>

@implementation MessageViewController
@synthesize webID, mTitle, mCategoryTitle, mCategoryAuthor, mTime, mImageView, playbackTimer, progressView, audioPlayer, audioPlayerItem,playButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    valid_audio_player=false;
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    [self loadMessage];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    
    if([audioPlayer rate] != 0.0)
    {
        //audioPlaying = FALSE;
        [audioPlayer pause];
        
        if (timeObserver)
        {
            [audioPlayer removeTimeObserver:timeObserver];
            [timeObserver release];
            timeObserver = nil;
        }
    }
}

- (void)viewDidUnload
{
    NSLog(@"View did unload");
    [audioPlayer pause];
    
    if (timeObserver) 
    {
        [audioPlayer removeTimeObserver:timeObserver];
        [timeObserver release];
        timeObserver = nil;
    }
    
    [super viewDidUnload];
    //[playbackTimer invalidate];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) playAudio
{
    if(valid_audio_player)
    {
        if([audioPlayer rate] != 0.0)
        {
            [audioPlayer pause];
            [playButton setImage:[UIImage imageNamed:@"message_tab_play.png"] forState:UIControlStateNormal];
        }
        else
        {
            [audioPlayer play];
            [playButton setImage:[UIImage imageNamed:@"message_tab_pause.png"] forState:UIControlStateNormal];
        }
    }
    else
    {
        NSLog(@"The audio file is not ready or does not exist");
    }
}

-(void)updateTime
{
    if (audioPlayerItem.status == AVPlayerItemStatusReadyToPlay)  
    {
        CMTime playerItemDuration =([audioPlayerItem duration]);
        if (CMTIME_IS_INVALID(playerItemDuration))
        {
            return;
        }
        
        
        
        double duration = CMTimeGetSeconds(playerItemDuration);
        
        if (isfinite(duration) && (duration > 0))
        {
            double time = CMTimeGetSeconds([audioPlayer currentTime]);
            
            int minutes = (int)roundf(floor(time/60));
            int seconds = (int)floorf(time - (minutes * 60));
            
            int duration_minutes = (int)roundf(floor(duration/60));
            int duration_seconds = (int)floorf(duration - (duration_minutes * 60));
            
            NSString *timeInfoString = [[NSString alloc] initWithFormat:@"%i:%02i/%i:%02i",minutes,seconds,duration_minutes,duration_seconds];
            
            float progress = time / duration;
            
            progressView.progress=progress;
            mTime.text = timeInfoString;
            [timeInfoString release];
            
            //NSLog(@"Time %f %f",duration, time);  
        }
        
    }
}

-(void)loadAudio: (NSString *) audio_file
{
    NSLog(@"audo file location %@",audio_file);
    NSURL *url = [NSURL URLWithString:audio_file]; //[[NSURL alloc] initWithString:audio_file ];
    self.audioPlayerItem =  [AVPlayerItem playerItemWithURL:url];
    self.audioPlayer = [AVPlayer playerWithPlayerItem:self.audioPlayerItem];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(100, 100);
    spinner.transform = CGAffineTransformMakeScale(2, 2);
    spinner.hidesWhenStopped = YES;
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [url release];
    url=nil;
    
    [audioPlayer addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:audioPlayerItem];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == audioPlayer && [keyPath isEqualToString:@"status"]) {
        [spinner stopAnimating];
        
        if (audioPlayer.status == AVPlayerStatusFailed) {
            NSLog(@"AVPlayer Failed");
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Audio player failed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
            
        } else if (audioPlayer.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [self.audioPlayer play];
            valid_audio_player=true;
            audioPlaying=true;
            
            [playButton setImage:[UIImage imageNamed:@"message_tab_pause.png"] forState:UIControlStateNormal];
            
            timeObserver = [[audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, NSEC_PER_SEC) queue:NULL usingBlock: ^(CMTime time) { [self updateTime]; }] retain];
        } else if (audioPlayer.status == AVPlayerItemStatusUnknown) {
            NSLog(@"AVPlayer Unknown");
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Audio player status unknow" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alertView show];
            [alertView release];
            
        }
    }
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    [audioPlayer seekToTime:kCMTimeZero];
    
    [playButton setImage:[UIImage imageNamed:@"message_tab_play.png"] forState:UIControlStateNormal];
}

-(void)AudioPlayerPlay:(NSNotification *)notification
{
    CMTime duration = [[[[[self.audioPlayerItem tracks] objectAtIndex:0] assetTrack] asset] duration];
    Float64 duration_seconds = CMTimeGetSeconds(duration);
    NSLog(@"Audio ready duraction is %f",duration_seconds);
}

-(void) loadMessage
{
    int webID_int= [webID intValue];
    
    //initialize the variables that are needed to point to the images location
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    MessageItem *mItem = [[MessageItem alloc] init];
    MessageCategory *mCategory = [[MessageCategory alloc] init];
    if([mItem load_item_db:webID_int])
    {
        self.navigationItem.title=[mItem get_name];
        [mTitle setText:[mItem get_name]];
        //mTitle.font = [UIFont fontWithName:@"Arial" size:20];
        //mTitle.textColor = [UIColor whiteColor];
        
        [self loadAudio: [mItem get_file]];
        
        if([mCategory load_item_db:[mItem get_category]])
        {
            [mCategoryTitle setText:[mCategory get_name]];
            //mCategoryTitle.font = [UIFont fontWithName:@"Arial" size:17];
            //mCategoryTitle.textColor = [UIColor whiteColor];
            
            [mCategoryAuthor setText:[mCategory get_author]];
            //mCategoryAuthor.font = [UIFont fontWithName:@"Arial" size:12];
            //mCategoryAuthor.textColor = [UIColor whiteColor];
            
            if([mCategory is_image_loaded])
            {
                //now that we have the image from the web send it to be displayed 
                NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[mCategory get_image]];
                UIImage *img = [[UIImage alloc] initWithContentsOfFile:filePath];
                [mImageView setImage:img];
                [img release];
            }
            else 
                NSLog(@"The image is not yet loaded");
            
        }
        else 
        {
            //TODO do something if we fail to load the category
            NSLog(@"Failed to load the category");
        }
    }
    else 
    {
        //TODO do something since we failed to load the message 
        NSLog(@"Failed to load the message");
    }
    
    [mCategory release];
    mCategory = nil;
    [mItem release];
    mItem = nil;
}

@end
