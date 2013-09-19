//
//  FirstViewController.m
//  iosMobile
//
//  Created by Aaron Salo on 2/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "News.h"


@implementation FirstViewController
@synthesize imageView = mImageView;
@synthesize imageDropShadowView = mImageDropShadowView;
@synthesize mainView = mMainView;
@synthesize loadNewsTimer;
@synthesize animateNewsTimer;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    NSLog(@"view did load");
    [super viewDidLoad];
    //load a default image into the News viewere just incase nothing else loads 
    NSAssert(self.imageView, @"self.imageView is nil. Check your IBOutlet connections");
    self.imageView.backgroundColor = [UIColor blackColor];
    self.imageView.clipsToBounds = YES;
    
    imageViews = [[NSMutableArray alloc] init];
    imageShadowViews = [[NSMutableArray alloc] init];
    newsAnimationDirection=1;
    
    UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetectedLeft:)];
    swipeRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizerLeft];
    [swipeRecognizerLeft release];
    
    UISwipeGestureRecognizer *swipeRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDetectedRight:)];
    swipeRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRecognizerRight];
    [swipeRecognizerRight release];
    
    //load the rest of the news items 
    //[self loadData];
}

-(IBAction)swipeDetectedLeft:(UIGestureRecognizer *)sender {
    //NSLog(@"swipe left");
    [self killNewsTimer];
    [self animateSlides:@"left"];
    newsAnimationDirection=1;//set the direction to left for the next automated animation
    [self startNewsTimer];
}

-(IBAction)swipeDetectedRight:(UIGestureRecognizer *)sender {
    //NSLog(@"swipe right");
    [self killNewsTimer];
    [self animateSlides:@"right"];
    newsAnimationDirection=2;//set the direction to right for the next automated animation
    [self startNewsTimer];
}

-(void)killNewsTimer
{
    if([animateNewsTimer isValid])//only stop the timer if it exits 
    {
        [animateNewsTimer invalidate];
        animateNewsTimer = nil;
    }
}

-(void)startNewsTimer
{
    animateNewsTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(autoTriggerNewsAnimation) userInfo:nil repeats:YES];
}

-(void)animateSlides:(NSString *)direction {
    //NSLog(@"Move the slide %@",direction);
    
    BOOL animate=false;
    
    if(([direction isEqualToString:@"right"])&&(newsImageIndex!=0))
    {
        animate=true;
        newsImageIndex--;
    }
    else if(([direction isEqualToString:@"left"])&&(newsImageIndex!=(imageViews.count-1)))
    {
        animate=true;
        newsImageIndex++;
    }
    
    if(animate==true)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
        for(int i=0; i<imageViews.count; i++)
        {
            UIImageView *workingImage=[imageViews objectAtIndex:i];
            UIImageView *workingDropShadowImage = [imageShadowViews objectAtIndex:i];
            CGPoint tempPoint=workingImage.center;
            if([direction isEqual:@"right"])
            {
                workingImage.center = CGPointMake(tempPoint.x+275, 221.0f);
                workingDropShadowImage.center = CGPointMake(tempPoint.x+276.2, 224.0f);
            }
            else
            {
                workingImage.center = CGPointMake(tempPoint.x-275, 221.0f);
                workingDropShadowImage.center = CGPointMake(tempPoint.x-272.5, 224.0f);
            }
        }
        [UIView commitAnimations];
    }
    
    //NSLog(@"news index %i",newsImageIndex);
}


-(void)autoTriggerNewsAnimation{
    if((newsImageIndex==(imageViews.count-1))&&(newsAnimationDirection==1))
        newsAnimationDirection=2;
    else if((newsImageIndex==0)&&(newsAnimationDirection==2))
        newsAnimationDirection=1;
    
    if(newsAnimationDirection==1)
        [self animateSlides:@"left"];
    else
        [self animateSlides:@"right"];
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadData];
    //NSLog(@"Current Dirrection2 %i",newsAnimationDirection);
    //reload the image view every 5 min (300.0)
    loadNewsTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
    [self startNewsTimer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:@"refreshView" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [loadNewsTimer invalidate];
    [self killNewsTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshView" object:nil];
}

-(void)refreshView:(NSNotification *) notification
{
    [self loadData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    self.imageView = nil;
    [super viewDidUnload];
    
    [imageViews release];
    imageViews=nil;
    [imageShadowViews release];
    imageShadowViews=nil;

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(BOOL) loadData
{
    NSLog(@"load news items");
    //pull the images to display on the News page 
    NSMutableArray *news_images=[News load_current_items_db];
    
    //place the news images in the image viewer
    /*self.imageView.animationImages = news_images;
    self.imageView.animationDuration= 10;
    [self.imageView startAnimating];*/
    
    self.imageView.alpha=0;
    self.imageDropShadowView.alpha=0;
    
    //clear out the previous images
    if(imageViews.count>0)
    {
        for (UIImageView *v in imageViews) {
            if([v isKindOfClass:[UIImageView class]])
                [v removeFromSuperview];
        }
        imageViews = [[NSMutableArray alloc] init];
    }
    if(imageShadowViews.count>0)
    {
        for (UIImageView *v in imageShadowViews) {
            if([v isKindOfClass:[UIImageView class]])
                [v removeFromSuperview];
        }
        imageShadowViews = [[NSMutableArray alloc] init];
    }
    
    
    float x_axis=27;
    newsImageIndex=0;
    
    for(int i=0; i<news_images.count; i++)
    {
        //create the drop shadow image
        UIImageView *dropImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x_axis,95,267,259)];
        UIImage *imgDrop = [UIImage imageNamed:@"home_tab_drop_shadow.png"];
        //dropImageView.backgroundColor=[UIColor greenColor];
        [dropImageView setImage:imgDrop];
        [self.mainView addSubview:dropImageView];
        
        [imageShadowViews addObject: dropImageView];
        
        [imgDrop release];
        imgDrop=nil;
        [dropImageView release];
        dropImageView=nil;
        
        //now that we have the image from the web send it to be displayed
        UIImageView *newsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x_axis,97,262,248)] ;
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:[news_images objectAtIndex:i]];
        [newsImageView setImage:img];
        [self.mainView addSubview:newsImageView];
        
        [imageViews addObject: newsImageView];
        
        [img release];
        img=nil;
        [newsImageView release];
        newsImageView=nil;
        
        
        
        x_axis=x_axis+279;//offset the next one image
    }

    
    [news_images release];
    return false;
}


- (void)dealloc
{
    //[mImageView release];
    /*[imageViews release];
    imageViews=nil;
    [imageShadowViews release];
    imageShadowViews=nil;*/
    
    [super dealloc];
}

@end
