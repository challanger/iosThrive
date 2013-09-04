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
    
    //Add the header
    UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(0,x,320,56)] autorelease];
    //now that we have the image from the web send it to be displayed
    //NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[mCategory get_image]];
    UIImage *img = [UIImage imageNamed:@"header_media.png"];
    [imgView setImage:img];
    [img release];
    [self.scrollView addSubview:imgView];
    
    x=x+56+3;
    
    //loop through all the categories
    MessageCategory *mCategory;
    for(mCategory in categories)
    {
        //NSLog(@"Category Name %@ webID %i",[mCategory get_name],[mCategory get_web_id]);
        NSMutableArray *category_items=[MessageItem load_current_files_db:[mCategory get_web_id]];
        
        //add the drop shadow
        UIImageView *imgView_drop_shadow = [[[UIImageView alloc] initWithFrame:CGRectMake(10,x,109,110)] autorelease];
        UIImage *img_drop_shadow = [UIImage imageNamed:@"media_tab_drop_shadow.png"];
        [imgView_drop_shadow setImage:img_drop_shadow];
        [img_drop_shadow release];
        [self.scrollView addSubview:imgView_drop_shadow];
        
        //add the image 
        UIImageView *imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(12,x,101,102)] autorelease];
        //now that we have the image from the web send it to be displayed 
        NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[mCategory get_image]];
        UIImage *img = [[UIImage alloc] initWithContentsOfFile:filePath];
        [imgView setImage:img];
        [img release];
        [self.scrollView addSubview:imgView];
        
        //Add the title
        UILabel *cat_name = [[[UILabel alloc] initWithFrame:CGRectMake(122,x,170,25)] autorelease];
        [cat_name setText: [mCategory get_name]];
        cat_name.backgroundColor = [UIColor clearColor];
        cat_name.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:25];
        cat_name.textColor = [UIColor colorWithRed:41.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
        [self.scrollView addSubview:cat_name];
        
        UILabel *cat_author = [[[UILabel alloc] initWithFrame:CGRectMake(124,x+33,170,11)] autorelease];
        [cat_author setText: [mCategory get_author]];
        cat_author.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:11];
        cat_author.textColor = [UIColor colorWithRed:41.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
        cat_author.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:cat_author];
        
        
        x=x+140;
        
        //NSLog(@"number of items %i",[category_items count]);
        MessageItem *mItem;
        
        UIColor *ligth_green_color = [UIColor colorWithRed:100.0f/255.0f green:208.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
        UIColor *dark_green_color = [UIColor colorWithRed:3.0f/255.0f green:104.0f/255.0f blue:58.0f/255.0f alpha:1.0f];
        UIColor *font_light_color = [UIColor colorWithRed:252.0f/255.0f green:255.0f/255.0f blue:253.0f/255.0f alpha:1.0f];
        
        int item_count=0;
        for(mItem in category_items)
        {
            //NSLog(@"Message name %@",[mItem get_name]);
            
            UIButton *message_name = [UIButton buttonWithType:UIButtonTypeCustom];
            message_name.frame = CGRectMake(10,x,300,30);
            [message_name.titleLabel setTextAlignment:UITextAlignmentLeft];
            message_name.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
            message_name.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [message_name setTitle:[mItem get_name] forState:UIControlStateNormal];
            if((item_count%2)==0)
                message_name.backgroundColor = dark_green_color;
            else 
                message_name.backgroundColor = ligth_green_color;
            [message_name.titleLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:18]];
            [message_name.titleLabel setTextColor:font_light_color];
            
            [message_name setTag: [mItem get_web_id]];
            [message_name addTarget:self action:@selector(loadMessage:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
            
            [self.scrollView addSubview:message_name];
            
            UIButton *message_go_button = [UIButton buttonWithType:UIButtonTypeCustom];
            message_go_button.frame = CGRectMake(280,x+2,25,26);
            [message_go_button setImage:[UIImage imageNamed:@"media_tab_go_button.png"] forState:UIControlStateNormal];
            //message_go_button.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
            [message_go_button addTarget:self action:@selector(loadMessage:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
            [self.scrollView addSubview:message_go_button];
            
            x=x+30;
            
            UIButton *message_date = [UIButton buttonWithType:UIButtonTypeCustom];
            message_date.frame = CGRectMake(220,x-14,60,10);
            [message_date setTitle: [mItem get_formated_date] forState:UIControlStateNormal];
            if((item_count%2)==0)
                message_date.backgroundColor = dark_green_color;
            else 
                message_date.backgroundColor = ligth_green_color;
            [message_date.titleLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:11]];
            [message_date.titleLabel setTextColor:font_light_color];
            message_date.contentHorizontalAlignment =UIControlContentHorizontalAlignmentRight;
            [message_date addTarget:self action:@selector(loadMessage:) forControlEvents:(UIControlEvents)UIControlEventTouchUpInside];
            [self.scrollView addSubview:message_date];
            
            
            
            
            
            //x=x+10;
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
