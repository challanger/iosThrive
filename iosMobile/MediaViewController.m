//
//  MediaViewController.m
//  iosMobile
//
//  Created by Aaron Salo on 3/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MediaViewController.h"
#import "MessageCategory.h"
#import "MessageItem.h"

#import "MessageViewController.h"

@implementation MediaViewController
@synthesize scrollView = mUIScrollView;
@synthesize loadMediaTimmer;


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
    NSLog(@"Media tab loaded");
    self.navigationController.navigationBar.hidden = YES;
    //[self loadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [self loadData];
    //reload the media view every 5 min
    loadMediaTimmer = [NSTimer scheduledTimerWithTimeInterval:300.0 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [loadMediaTimmer invalidate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL) loadData
{
    NSLog(@"load media");
    [[self.scrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //pull the images to display on the News page 
    NSMutableArray *categories=[MessageCategory load_current_category_db];
    
    //initialize the variables that are needed to point to the images location
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //NSLog(@"number of loaded categories %i",[categories count]);
    
    int x=10;
    
    //loop through all the categories
    MessageCategory *mCategory;
    for(mCategory in categories)
    {
        //NSLog(@"Category Name %@ webID %i",[mCategory get_name],[mCategory get_web_id]);
        NSMutableArray *category_items=[MessageItem load_current_files_db:[mCategory get_web_id]];
        
        //add the image
        UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(10,x,120,120)] autorelease];
        //now that we have the image from the web send it to be displayed 
        NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[mCategory get_image]];
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:filePath];
        [imgView setImage:img];
        [img release];
        [self.scrollView addSubview:imgView];
        
        //Add the title
        UILabel *cat_name = [[[UILabel alloc] initWithFrame:CGRectMake(140,x,170,40)] autorelease];
        [cat_name setText: [mCategory get_name]];
        cat_name.backgroundColor = [UIColor clearColor];
        cat_name.font = [UIFont fontWithName:@"Arial" size:27];
        cat_name.textColor = [UIColor whiteColor];
        [self.scrollView addSubview:cat_name];
        
        UILabel *cat_author = [[[UILabel alloc] initWithFrame:CGRectMake(140,x+33,170,20)] autorelease];
        [cat_author setText: [mCategory get_author]];
        cat_author.font = [UIFont fontWithName:@"Arial" size:12];
        cat_author.textColor = [UIColor whiteColor];
        cat_author.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:cat_author];
        
        
        x=x+140;
        
        //NSLog(@"number of items %i",[category_items count]);
        MessageItem *mItem;
        
        UIColor *grey_color = [UIColor grayColor];
        UIColor *black_color = [UIColor blackColor];
        
        int item_count=0;
        for(mItem in category_items)
        {
            //NSLog(@"Message name %@",[mItem get_name]);
            
            UIButton *message_name = [UIButton buttonWithType:UIButtonTypeCustom];
            message_name.frame = CGRectMake(15,x,195,35);
            [message_name.titleLabel setTextAlignment:UITextAlignmentLeft];
            message_name.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
            message_name.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [message_name setTitle:[mItem get_name] forState:UIControlStateNormal];
            if((item_count%2)==0)
                message_name.backgroundColor = black_color;
            else 
                message_name.backgroundColor = grey_color;
            [message_name.titleLabel setFont:[UIFont fontWithName:@"Arial" size:16]];
            [message_name.titleLabel setTextColor:[UIColor whiteColor]];
            
            [message_name setTag: [mItem get_web_id]];
            [message_name addTarget:self action:@selector(loadMessage:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
            
            [self.scrollView addSubview:message_name];
            
            UILabel *message_date = [[[UILabel alloc] initWithFrame:CGRectMake(210,x,100,35)] autorelease];
            [message_date setText: [mItem get_formated_date]];
            if((item_count%2)==0)
                message_date.backgroundColor = black_color;
            else 
                message_date.backgroundColor = grey_color;
            message_date.font = [UIFont fontWithName:@"Arial" size:16];
            message_date.textColor = [UIColor whiteColor];
            message_date.textAlignment = UITextAlignmentRight;
            [self.scrollView addSubview:message_date];
            
            x=x+35;
            item_count++;
            
        }
        x=x+20;
        
        
    }

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, x);
    //self.scrollView.contentSize = CGSizeMake(2000, 2000);
    //[self.scrollView.contentInset.bottom = 50];
    
    
    //[news_images release];
    return false;
}

-(void) loadMessage: (id)sender
{
    UIButton *button = (UIButton *)sender;
    //NSLog(@"button press %i",button.tag);
    
    MessageViewController *messageView = [[MessageViewController alloc] initWithNibName:@"MessageViewController" bundle:nil];
    //messageView.delegate = self;
    messageView.webID = [NSString stringWithFormat:@"%i",button.tag];
    //messageView.modalTransitionStyle
    [self.navigationController pushViewController:messageView animated:YES];
    //[self.navigationController popToViewController:messageView animated:YES];
    //[self presentModalViewController:messageView animated:YES];
    //[messageView loadView];
    
    /*UIView *messageView =[[UIView alloc] autorelease];
    messageView.backgroundColor =[UIColor brownColor];
    [self.scrollView addSubview:messageView];*/
    
    //NSLog(@"Button end");
}

@end
