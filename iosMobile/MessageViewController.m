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

@implementation MessageViewController
@synthesize webID, mTitle, mCategoryTitle, mCategoryAuthor, mTime, mImageView, playbackTimer, progressView, audioPlayer,playButton;

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
    // Do any additional setup after loading the view from its nib.
    //[mCategoryTitle setText:@"test"];
    //NSLog(@"webID %@",webID);
}

-(void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    [self loadMessage];
}

-(void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    
    //stop the audio play back
    if(audioPlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        [playbackTimer invalidate];
        [audioPlayer stop];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //[playbackTimer invalidate];
    //[audioPlayer stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction) playAudio
{
    if(audioPlayer.playbackState == MPMoviePlaybackStatePlaying)
    {
        //audioPlaying = FALSE;
        [audioPlayer pause];
        [playButton setImage:[UIImage imageNamed:@"message_tab_play.png"] forState:UIControlStateNormal];
    }
    else
    {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(100, 100);
        spinner.transform = CGAffineTransformMakeScale(2, 2);
        spinner.hidesWhenStopped = YES;
        [self.view addSubview:spinner];
        [spinner startAnimating];
        
        [audioPlayer play];
        [playButton setImage:[UIImage imageNamed:@"message_tab_pause.png"] forState:UIControlStateNormal];
        //audioPlaying = TRUE;
    }
}

-(void)updateTime
{
    //NSArray *audioMetadata = [audioPlayer timedMetadata];
    //audioMetadata indexOfObject:<#(id)#>
    int minutes = (int)roundf(floor(audioPlayer.currentPlaybackTime/60));
    int seconds = (int)floorf(audioPlayer.currentPlaybackTime - (minutes * 60));
    
    
    
    int duration_minutes = (int)roundf(floor(audioPlayer.duration/60));
    int duration_seconds = (int)floorf(audioPlayer.duration - (duration_minutes * 60));
    
    //NSLog(@"Current Time %i:%02i/%i:%02i",minutes,seconds,duration_minutes,duration_seconds);
    
    NSString *timeInfoString = [[NSString alloc] initWithFormat:@"%i:%02i/%i:%02i",minutes,seconds,duration_minutes,duration_seconds];
    
    float progress = audioPlayer.currentPlaybackTime / audioPlayer.duration;
    
    progressView.progress=progress;
    
    mTime.text = timeInfoString;
    [timeInfoString release];
}

-(void)loadAudio: (NSString *) audio_file
{
    //NSLog(@"audo file location %@",audio_file);
    NSURL *url =[[NSURL alloc] initWithString:audio_file ];
    audioPlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    audioPlayer.movieSourceType = MPMovieSourceTypeStreaming;
    audioPlayer.view.hidden = YES;
    [self.view addSubview:audioPlayer.view];
    //[audioPlayer play];
    audioPlaying=false;
    
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviePlayerLoadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPMoviewPlayerPlay:) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

- (void)MPMoviePlayerLoadStateDidChange:(NSNotification *)notification
{
    if ((audioPlayer.loadState & MPMovieLoadStatePlaythroughOK) == MPMovieLoadStatePlaythroughOK)
    {
        [spinner stopAnimating];
       // NSLog(@"content play length is %g seconds", audioPlayer.duration);
        //NSLog(@"current time in %g seconds",audioPlayer.currentPlaybackTime);
        
        playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    }
}

-(void)MPMoviewPlayerPlay:(NSNotification *)notification
{
    if ((audioPlayer.loadState & MPMovieLoadStatePlaythroughOK) == MPMovieLoadStatePlaythroughOK)
    {
        [spinner stopAnimating];
        if(audioPlayer.playbackState == MPMoviePlaybackStatePlaying)
            playbackTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        else if(audioPlayer.playbackState == MPMoviePlaybackStatePaused)
            [playbackTimer invalidate];
        else  if(audioPlayer.playbackState == MPMoviePlaybackStateInterrupted)
            [playbackTimer invalidate];
    }
    //if(audioPlaying == TRUE)
        //NSLog(@"Play");
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
}

@end
