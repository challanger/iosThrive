//
//  iosMobileAppDelegate.m
//  iosMobile
//
//  Created by Aaron Salo on 2/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

//test comment
//test comment 2

#import "iosMobileAppDelegate.h"
#import "VariableStore.h"
#import "JSONKit.h"
#import "News.h"
#import "MessageCategory.h"
#import "MessageItem.h"

@implementation iosMobileAppDelegate


@synthesize window=_window;

@synthesize tabBarController=_tabBarController;

@synthesize loadServerTimer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"did finish launching with options");
    [self implementDB];
    // Override point for customization after application launch.
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    [self geServerRecords];
    loadServerTimer = [NSTimer scheduledTimerWithTimeInterval:1200.0 target:self selector:@selector(geServerRecords) userInfo:nil repeats:YES];//every 20 min contact the server to pull any new records 
    //[self pullServerRecords];
    return YES;
}

-(void)geServerRecords
{
    [self performSelectorInBackground:@selector(pullServerRecords) withObject:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_tabBarController release];
    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

-(void)implementDB
{
    sqlite3 *thriveDB=[[VariableStore sharedInstance] thriveDB];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //[filemgr removeItemAtPath:[VariableStore databasePath] error: NULL];    //test code to force the app to recreate the database each time remove from the production code
    
    if([filemgr fileExistsAtPath: [VariableStore databasePath]] == NO )
    {
        const char *dbpath = [[VariableStore databasePath] UTF8String];
        
        if(sqlite3_open(dbpath,&thriveDB) == SQLITE_OK )
        {
            char *errMsg;
            //char *errMsg2;
            const char *sql_stmt="CREATE TABLE IF NOT EXISTS NEWS (id INTEGER PRIMARY KEY AUTOINCREMENT, webID INTERGER DEFAULT 0, web_image TEXT DEFUALT '', mobile_image TEXT DEFAULT '', link TEXT DEFAULT '', caption TEXT DEFAULT '', active INTEGER DEFAULT 0, start_date INTEGER DEFAULT 0, end_date INTEGER DEFAULT 0, mobile_loaded INTERGER DEFAULT 0,last_synced INTEGER DEFAULT 0);";
            if(sqlite3_exec(thriveDB, sql_stmt,NULL,NULL,&errMsg)!=SQLITE_OK)
            {
                //TODO write some code to handle the fialure to create the db
                NSLog(@"Failed to create the NEWS table");
            }
            else 
            {
                
                /*const char *sql_stmt2="INSERT INTO NEWS (webID,web_image,active,start_date,end_date,last_synced) VALUES (1,'http://ithrive.ca/files/slides/SL-49.jpg',1,1361045976,1426537176,0)";
                if(sqlite3_exec(thriveDB, sql_stmt2,NULL,NULL,&errMsg2)!=SQLITE_OK)
                {
                    NSLog(@"Failed to create the db record");
                }
                
                const char *sql_stmt3="INSERT INTO NEWS (webID,web_image,active,start_date,end_date,last_synced) VALUES (2,'http://ithrive.ca/files/slides/SL-50.jpg',1,1361045976,1426537176,0)";
                if(sqlite3_exec(thriveDB, sql_stmt3,NULL,NULL,&errMsg2)!=SQLITE_OK)
                {
                    //TODO write some code to handle the fialure to create the db
                }*/
            }
           
            const char *sql_stmt_m_cat="CREATE TABLE IF NOT EXISTS MESSAGE_CATEGORY (id INTEGER PRIMARY KEY AUTOINCREMENT, webID INTEGER DEFAULT 0, name TEXT DEFAULT '', web_image TEXT DEFAULT '', mobile_image TEXT DEFAULT '', author TEXT DEFAULT '', date INTEGER DEFAULT'', image_loaded INTEGER DEFAULT 0, active INTEGER DEFAULT 1,last_synced INTEGER DEFAULT 0);";
            if(sqlite3_exec(thriveDB, sql_stmt_m_cat,NULL,NULL,&errMsg)!=SQLITE_OK)
            {
                //TODO write some code to handle the fialure to create the db
                NSLog(@"Failed to create the MESSAGTE_CATEGORY table");
            }
            else 
            {
                /*const char *sql_stmt4="INSERT INTO MESSAGE_CATEGORY (webID, name,web_image,author,date,last_synced) VALUES (1,'Simple','http://ithrive.ca/files/music/cover-simple.jpg','Ducane McLean',1339286400,0)";
                if(sqlite3_exec(thriveDB, sql_stmt4,NULL,NULL,&errMsg2)!=SQLITE_OK)
                {
                    NSLog(@"Failed to create the db record %s",sql_stmt4);
                }
                
                const char *sql_stmt5="INSERT INTO MESSAGE_CATEGORY (webID, name,web_image,author,date,last_synced) VALUES (2,'Gardrails','http://ithrive.ca/files/music/guardrails-cover.jpg','Jamie Smith, Ducane McLean',1339286400,0)";
                if(sqlite3_exec(thriveDB, sql_stmt5,NULL,NULL,&errMsg2)!=SQLITE_OK)
                {
                    NSLog(@"Failed to create the db record %s",sql_stmt5);
                }*/
            }
            
            const char *sql_stmt_m_file="CREATE TABLE IF NOT EXISTS MESSAGE_FILES (id INTEGER PRIMARY KEY AUTOINCREMENT, webID INTEGER DEFAULT 0, category INTEGER DEFAULT 0, file TEXT DEFAULT '', name TEXT DEFAULT '', active INTEGER DEFAULT 1, date INTEGER DEFAULT 0,last_synced INTEGER DEFAULT 0);";
            if(sqlite3_exec(thriveDB, sql_stmt_m_file,NULL,NULL,&errMsg)!=SQLITE_OK)
            {
                //TODO write some code to handle the fialure to create the db
                NSLog(@"Failed to create the MESSAGE_FILES table");
            }
            else 
            {
                /*const char *sql_stmt6="INSERT INTO MESSAGE_FILES (webID, category,file,name,date,last_synced) VALUES (1,1,'http://ithrive.ca/files/music/2012-06-10-duane-mclean-simple-follow.mp3','Follow',1339347600,0)";
                if(sqlite3_exec(thriveDB, sql_stmt6,NULL,NULL,&errMsg2)!=SQLITE_OK)
                {
                    NSLog(@"Failed to create the db record %s",sql_stmt6);
                }
                
                const char *sql_stmt7="INSERT INTO MESSAGE_FILES (webID, category,file,name,date,last_synced) VALUES (2,1,'http://ithrive.ca/files/music/2012-06-17-duane-mclean-simple-believe.mp3','Believe',1339952400,0)";
                if(sqlite3_exec(thriveDB, sql_stmt7,NULL,NULL,&errMsg2)!=SQLITE_OK)
                {
                    NSLog(@"Failed to create the db record %s",sql_stmt7);
                }
                
                const char *sql_stmt9="INSERT INTO MESSAGE_FILES (webID, category,file,name,date,last_synced) VALUES (4,1,'http://ithrive.ca/files/music/2012-06-17-duane-mclean-simple-believe.mp3','Believe2',1339952400,0)";
                if(sqlite3_exec(thriveDB, sql_stmt9,NULL,NULL,&errMsg2)!=SQLITE_OK)
                {
                    NSLog(@"Failed to create the db record %s",sql_stmt9);
                }
                
                const char *sql_stmt8="INSERT INTO MESSAGE_FILES (webID, category,file,name,date,last_synced) VALUES (3,2,'http://ithrive.ca/files/music/2013-01-06-guardrails-01-intro.mp3','Intro',1357470000,0)";
                if(sqlite3_exec(thriveDB, sql_stmt8,NULL,NULL,&errMsg2)!=SQLITE_OK)
                {
                    NSLog(@"Failed to create the db record %s",sql_stmt8);
                }*/
            }
            sqlite3_close(thriveDB);
            NSLog(@"LoadDB");
        }
        else 
        {
            //TODO write some code to hanle loading the db
            NSLog(@"DB all ready loaded");
        }
    }
    else 
        NSLog(@"DB file allready exists");
    
    //[filemgr release];
    
}

-(NSMutableArray *) pullServerRecords
{
    NSLog(@"pull records from the server");
    NSMutableArray *send;
    
    //NSString* jsonURL = [NSString stringWithFormat:@"http://challengernet.com/thrive_remote.php"];
    NSString* jsonURL = [NSString stringWithFormat:@"http://ithrive.ca/remote/mobile/"];
    NSError* err = nil;
    NSURLResponse* responce = nil;
    NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] init] autorelease];
    NSURL* URL = [NSURL URLWithString:jsonURL];
    [request setURL:URL];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    NSData* jsonData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responce error:&err];
    NSLog(@" Json data %@",responce);
    NSDictionary *resultsDictionary = [jsonData objectFromJSONData];
    NSLog(@"data found on the server, num entries %i",[resultsDictionary count]);
    
    //run through the news posts 
    NSArray *news_posts=[resultsDictionary objectForKey:@"slides"];
    NSLog(@"Number of news entries %i",[news_posts count]);
    int i=0;
    for(i=0; i< [news_posts count]; i++)
    {
        
        NSLog(@"News slide url %@", [[news_posts objectAtIndex:i] objectForKey:@"imageurl"]);
        News *server_news=[[News alloc] init];
        [server_news load_items_from_server:[news_posts objectAtIndex:i]];
        
    }
    
    //run through the news posts 
    NSArray *category_items=[resultsDictionary objectForKey:@"media"];
    for(i=0; i< [category_items count]; i++)
    {
        
        //NSLog(@"News slide url %@", [[news_posts objectAtIndex:i] objectForKey:@"imageurl"]);
        MessageCategory *server_cateogry=[[MessageCategory alloc] init];
        [server_cateogry load_items_from_server:[category_items objectAtIndex:i]];
        
        //Now save the messages for this category 
        NSArray *message_items=[[category_items objectAtIndex:i] objectForKey:@"items"];
        int j=0;
        for(j=0; j< [message_items count]; j++)
        {
            
            //NSLog(@"News slide url %@", [[news_posts objectAtIndex:i] objectForKey:@"imageurl"]);
            int cat_web_id=[[[category_items objectAtIndex:i] objectForKey:@"id"] intValue];
            MessageItem *server_message=[[MessageItem alloc] init];
            [server_message load_items_from_server:[message_items objectAtIndex:j] data: cat_web_id];
            
            
        }
    }
    
    return send;
}

@end
