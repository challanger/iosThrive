//
//  News.m
//  iosMobile
//
//  Created by Aaron Salo on 2/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "News.h"
#import "/usr/include/sqlite3.h"
#import "VariableStore.h"


@implementation News

-(NSString *) get_image
{
    return image_mobile;
}

-(BOOL) is_image_loaded
{
    if(mobile_loaded==1)
        return TRUE;
    else
        return FALSE;
}

-(BOOL) pull_image_from_web
{
    if([image_web isEqualToString: @""])
    {
        NSLog(@"no location store for the web image");
        return false;
    }
    else 
    {
        NSURL *url = [NSURL URLWithString:image_web];
        NSData *urlData = [NSData dataWithContentsOfURL: url];
        if(urlData)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            //get the file extention
            NSString *extention;
            NSRange extention_location = [image_web rangeOfString:@"." options:NSBackwardsSearch];
            extention = [image_web substringFromIndex:extention_location.location];
            
            //Get the unix timestamp
            NSString *timestamp = [NSString stringWithFormat: @"%d",(long)[[NSDate date] timeIntervalSince1970]];
            //build the file name
            NSString *file_name = [NSString stringWithFormat:@"%i_%@_%@", n_id,timestamp,extention];
            
            NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,file_name];
            
            //Store the file
            [urlData writeToFile:filePath atomically:YES];
            
            //save the file name
            image_mobile=[NSMutableString stringWithString: file_name];
            mobile_loaded=1;
            [self save_to_db];
            
            /*[filePath release];
            [file_name release];
            [timestamp release];
            [extention release];
            [documentsDirectory release];
            [paths release];*/
            
            return true;
        }
        else
        {
            NSLog(@"URL error %@",image_web);
            return false;
        }
        //[url release];
        //[urlData release];
    }
}

-(NSString *) get_link
{
    return link;
}

-(NSString *) get_caption
{
    return caption;
}

-(BOOL) is_active
{
    if(active==1)
        return true;
    else
        return false;
}

-(NSString *) get_web_image
{
    return image_web;
}

-(int) get_web_id
{
    return n_id;
}

-(long) get_last_synced 
{
    return last_synced;
}

-(void) load_item_db:(int) db_id
{
    sqlite3_stmt *statement;
    
    sqlite3 *thriveDB=[[VariableStore sharedInstance] thriveDB];

    const char *dbpath = [[VariableStore databasePath] UTF8String];
    
    if(sqlite3_open(dbpath,&thriveDB)==SQLITE_OK)
    {
        NSString *loadSQL = [NSString stringWithFormat: @"SELECT * from NEWS WHERE webID=%i",db_id];
        const char *query_stmt = [loadSQL UTF8String];
        if(sqlite3_prepare_v2(thriveDB,query_stmt,-1,&statement,NULL)==SQLITE_OK)
        {
            if(sqlite3_step(statement)== SQLITE_ROW)
            {
                local_id = sqlite3_column_int(statement, 0);
                n_id = sqlite3_column_int(statement, 1);
                image_web = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                image_mobile = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                link = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                caption = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                active = sqlite3_column_int(statement, 6);
                start_date = sqlite3_column_int(statement, 7);
                end_date = sqlite3_column_int(statement, 8);
                mobile_loaded = sqlite3_column_int(statement, 9);
                last_synced = sqlite3_column_int(statement, 10);
                
                //NSLog(@"Founde webID %i", n_id);
                 
            }
            else 
            {
                //TODO deal with not record being found
                NSLog(@"NO news record was found with an id of: \"%i\"",db_id); 
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to run the record id: %i",db_id);
        }
        sqlite3_close(thriveDB);
        //[loadSQL release];
    }
}

-(BOOL) save_to_db
{
    sqlite3_stmt *statement;
    
    sqlite3 *thriveDB=[[VariableStore sharedInstance] thriveDB];
    
    const char *dbpath = [[VariableStore databasePath] UTF8String];
    
    if(sqlite3_open(dbpath,&thriveDB)==SQLITE_OK)
    {
        NSString *saveSQL;
        if(local_id==0)
        {
             saveSQL = [NSString stringWithFormat: @"INSERT INTO NEWS (web_image,mobile_image, link, caption, active, start_date, end_date, mobile_loaded,last_synced,webID) VALUES ('%@','%@', '%@', '%@', %i, %i, %i, %i,%i,%i)",image_web,image_mobile,link,caption,active,start_date,end_date,mobile_loaded,last_synced,n_id];
        }
        else 
        {
            saveSQL = [NSString stringWithFormat: @"UPDATE NEWS set web_image='%@', mobile_image='%@', link='%@', caption='%@', active=%i, start_date=%i, end_date=%i, mobile_loaded=%i, last_synced=%i WHERE webID=%i",image_web,image_mobile,link,caption,active,start_date,end_date,mobile_loaded,last_synced,n_id];
        }
        const char *query_stmt = [saveSQL UTF8String];
        if(sqlite3_prepare_v2(thriveDB,query_stmt,-1,&statement,NULL)==SQLITE_OK)
        {
            int db_status=sqlite3_step(statement);
            if(db_status== SQLITE_DONE)
            {
                sqlite3_close(thriveDB);
                return true;                
            }
            else 
            {
                //TODO deal with no record being found
                NSLog(@"failed to save the record1 id: \"%i\" db_code: %i %@",n_id,db_status,saveSQL); 
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to save the record2 id: %i %@",n_id, saveSQL);
        }
        sqlite3_close(thriveDB);
        //[saveSQL release];
    }
    
    return false;
}

-(void) load_item_db_statment:(sqlite3_stmt *) statement
{
    local_id = sqlite3_column_int(statement, 0);
    n_id = sqlite3_column_int(statement, 1);
    image_web = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
    image_mobile = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
    link = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
    caption = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
    active = sqlite3_column_int(statement, 6);
    start_date = sqlite3_column_int64(statement, 7);
    end_date = sqlite3_column_int64(statement, 8);
    mobile_loaded = sqlite3_column_int(statement, 9);
    last_synced = sqlite3_column_int(statement, 10);
    
}

-(void) load_items_from_server:(NSDictionary *) JSONData
{
    //pull the id for the news item from the json data
    NSString *json_id= [JSONData objectForKey:@"id"];
    int jID= [json_id intValue];
    int last_synced_json = [[JSONData objectForKey:@"last_modified"] intValue];
    
    //try to load the data from the serve 
    [self load_item_db:jID];
    if([self get_web_id]==0)
    {
        //New record create it
        n_id= [[JSONData objectForKey:@"id"] intValue];
        image_web = [JSONData objectForKey:@"imageurl"];
        image_mobile = [NSMutableString stringWithString:@""];
        link = [JSONData objectForKey:@"link"];
        caption = [JSONData objectForKey:@"caption"];
        active = 1;
        start_date = [[JSONData objectForKey:@"start_date"] intValue];
        end_date = [[JSONData objectForKey:@"expires"] intValue];
        mobile_loaded = 0;
        last_synced = [[JSONData objectForKey:@"last_modified"] intValue];
        
        [self save_to_db]; 
    }
    else 
    {
       //Existing record
        if(last_synced< last_synced_json) //only update if the old record is out of date
        {
            if(mobile_loaded==1)//if the image was previously loaded delete it
            {
                //initialize the variables that are needed to point to the images location
                NSFileManager *filemgr = [NSFileManager defaultManager];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,image_mobile];
                [filemgr removeItemAtPath:filePath error: NULL]; 
            }
            
            n_id= [[JSONData objectForKey:@"id"] intValue];
            image_web = [JSONData objectForKey:@"imageurl"];
            image_mobile = [NSMutableString stringWithString:@""];
            link = [JSONData objectForKey:@"link"];
            caption = [JSONData objectForKey:@"caption"];
            active = 1;
            start_date = [[JSONData objectForKey:@"start_date"] intValue];
            end_date = [[JSONData objectForKey:@"expires"] intValue];
            mobile_loaded = 0;
            last_synced = [[JSONData objectForKey:@"last_modified"] intValue];
            
            [self save_to_db];            
        }
        //else 
            //NSLog(@"record is upto date %ld %i",last_synced, last_synced_json);
    }
    
    
}

+(NSMutableArray *) load_current_items_db
{
    //create the array that will hold the images to be returned 
    NSMutableArray *imageArray;
    NSMutableArray *news_items;
    news_items = [[NSMutableArray alloc] init];
    imageArray = [[NSMutableArray alloc] init];
    //imageArray = [NSMutableArray arrayWithObjects:[UIImage imageNamed:@"thrive"], nil];
    //initiate the sqlite variables that are needed to pull the data
    sqlite3_stmt *statement;
    sqlite3 *thriveDB=[[VariableStore sharedInstance] thriveDB];
    const char *dbpath = [[VariableStore databasePath] UTF8String];
    
    //initialize the variables that are needed to point to the images location
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    int count=0;
    
    if(sqlite3_open(dbpath,&thriveDB)==SQLITE_OK)
    {
        //Get the unix timestamp
        int long date=[[NSDate date] timeIntervalSince1970];
        //date=date*1000;
        NSString *loadSQL = [NSString stringWithFormat: @"SELECT * from NEWS WHERE end_date>%ld",date];
        const char *query_stmt = [loadSQL UTF8String];
        if(sqlite3_prepare_v2(thriveDB,query_stmt,-1,&statement,NULL)==SQLITE_OK)
        {
            //Now that we have the data process its 
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                //populate a News object with the db data 
                News *news_item = [[News alloc] init];
                [news_item load_item_db_statment:statement];
                
                [news_items addObject:news_item];
                
                count++;
            }
            
            if(count==0)
                NSLog(@"No active news items found %@",loadSQL);
            
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to pull all of the active news items");
        }
        sqlite3_close(thriveDB);
        
        //[loadSQL release];
    }
    
    //if we loaded any new items run through them. 
    if(count>0)
    {
        News *news_item;
        for(news_item in news_items)
        {
            //NSLog(@"WebID %i",[news_item get_web_id]);
            //Check to see if we have the image otherwise try to load it
            if([news_item is_image_loaded]==false)
            {
                if([news_item pull_image_from_web])
                {
                    //now that we have the image from the web send it to be displayed 
                    NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[news_item get_image]];
                    [imageArray addObject:[UIImage imageWithContentsOfFile:filePath]];
                    
                    //[filePath release];
                    
                }
            }
            else 
            {
                //since we all ready have the image send it to be displayed 
                NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[news_item get_image]];
                [imageArray addObject:[UIImage imageWithContentsOfFile:filePath]];
                
                //NSLog(@"%@",filePath);
                
                //[filePath release];
            }

        }
    }
    else 
    {
        [imageArray addObject:[UIImage imageNamed:@"thrive"]];
    }
    //[news_items relase];
    
    //[documentsDirectory release];
    //[paths release];
    
    return imageArray;
}

@end
