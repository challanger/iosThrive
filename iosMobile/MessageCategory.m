//
//  MessageCategory.m
//  iosMobile
//
//  Created by Aaron Salo on 3/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MessageCategory.h"
#import "sqlite3.h"
#import "VariableStore.h"

@implementation MessageCategory

-(NSString *) get_image
{
    return mobile_image;
}
-(BOOL) is_image_loaded
{
    if(image_loaded==1)
        return true;
    else
        return false;
}
-(BOOL) pull_image_from_web
{
    if([web_image isEqualToString: @""])
    {
        NSLog(@"no location store for the web image");
        return false;
    }
    else 
    {
        NSURL *url = [NSURL URLWithString:web_image];
        NSData *urlData = [NSData dataWithContentsOfURL: url];
        if(urlData)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            //get the file extention
            NSString *extention;
            NSRange extention_location = [web_image rangeOfString:@"." options:NSBackwardsSearch];
            extention = [web_image substringFromIndex:extention_location.location];
            
            //Get the unix timestamp
            NSString *timestamp = [NSString stringWithFormat: @"%ld",(long)[[NSDate date] timeIntervalSince1970]];
            //build the file name
            NSString *file_name = [NSString stringWithFormat:@"%i_%@_%@", n_id,timestamp,extention];
            
            NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,file_name];
            
            //Store the file
            [urlData writeToFile:filePath atomically:YES];
            
            //save the file name
            mobile_image=[NSMutableString stringWithString: file_name];
            image_loaded=1;
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
            NSLog(@"URL error %@",web_image);
            return false;
        }
        //[url release];
        //[urlData release];
    }

}
-(NSString *) get_name
{
    return name;
}
-(NSString *) get_author
{
    return author;
}
-(int) get_date
{
    return date;
}
-(BOOL) get_active
{
    if(active==1)
        return true;
    else 
        return false;
}
-(int) get_web_id
{
    return web_id;
}

-(int) get_last_synced
{
    return last_synced;
}

//pull a single item from the db by the id
-(BOOL) load_item_db: (int) db_id
{
    //initiate the sqlite variables that are needed to pull the data
    sqlite3_stmt *statement;
    sqlite3 *thriveDB=[[VariableStore sharedInstance] thriveDB];
    const char *dbpath = [[VariableStore databasePath] UTF8String];
    
    if(sqlite3_open(dbpath,&thriveDB)==SQLITE_OK)
    {
        //Get the unix timestamp
        NSString *loadSQL = [NSString stringWithFormat: @"SELECT * from MESSAGE_CATEGORY WHERE webID=%i",db_id];
        const char *query_stmt = [loadSQL UTF8String];
        if(sqlite3_prepare_v2(thriveDB,query_stmt,-1,&statement,NULL)==SQLITE_OK)
        {
            //Now that we have the data process its 
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                //populate a Message categoies object with the db data 
                //MessageCategory *mCategory = [[MessageCategory alloc] init];
                [self load_item_db_statment:statement];
                
                sqlite3_finalize(statement);
                sqlite3_close(thriveDB);
                return true;
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to pull the category %i",db_id);
        }
        sqlite3_close(thriveDB);
    }
    return false;
}

-(void) load_item_db_statment: (sqlite3_stmt *) statement
{
    n_id = sqlite3_column_int(statement, 0);
    web_id = sqlite3_column_int(statement, 1);
    name = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
    web_image = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
    mobile_image = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
    author = [[NSMutableString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
    date = sqlite3_column_int(statement, 6);
    image_loaded = sqlite3_column_int64(statement, 7);
    active = sqlite3_column_int64(statement, 8);
    last_synced = sqlite3_column_int(statement, 9);
    //NSLog(@"DB last synced: %i",last_synced);
}
//save an item to the db
-(BOOL) save_to_db
{
    sqlite3_stmt *statement;
    
    sqlite3 *thriveDB=[[VariableStore sharedInstance] thriveDB];
    
    const char *dbpath = [[VariableStore databasePath] UTF8String];
    
    if(sqlite3_open(dbpath,&thriveDB)==SQLITE_OK)
    {
        NSString *saveSQL;
        //NSLog(@"Save last synced: %i",last_synced);
        if(n_id==0)
        {
            saveSQL = [NSString stringWithFormat: @"INSERT INTO MESSAGE_CATEGORY (webID,name,web_image,author,date,last_synced) VALUES ('%i','%@', '%@', '%@', %i,%i)",web_id,name,web_image,author,date,last_synced];
        }
        else 
        {
            saveSQL = [NSString stringWithFormat: @"UPDATE MESSAGE_CATEGORY set name='%@', web_image='%@', mobile_image='%@', author='%@', date=%i, image_loaded=%i, active=%i, last_synced=%i WHERE webID=%i",name,web_image,mobile_image,author,date,image_loaded,active,last_synced,web_id];
        }
        const char *query_stmt = [saveSQL UTF8String];
        if(sqlite3_prepare_v2(thriveDB,query_stmt,-1,&statement,NULL)==SQLITE_OK)
        {
            int db_status=sqlite3_step(statement);
            if(db_status== SQLITE_DONE)
            {
                sqlite3_finalize(statement);
                sqlite3_close(thriveDB);
                return true;                
            }
            else 
            {
                //TODO deal with no record being found
                NSLog(@"failed to save the record1 id: \"%i\" db_code: %i %@",web_id,db_status,saveSQL); 
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to save the record2 id: %i %@",web_id, saveSQL);
        }
        sqlite3_close(thriveDB);
        //[saveSQL release];
    }
    
    return false;

}
//load item from source 
-(void) load_items_from_server: (NSDictionary *) JSONData
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
        web_id= [[JSONData objectForKey:@"id"] intValue];
        web_image = [[NSMutableString alloc] initWithString:[JSONData objectForKey:@"imageurl"]];
        mobile_image = [[NSMutableString alloc] initWithString:@""]; //[NSMutableString stringWithString:@""];
        name = [[NSMutableString alloc] initWithString:[JSONData objectForKey:@"title"]];
        author = [[NSMutableString alloc] initWithString:[JSONData objectForKey:@"author"]];
        active = 1;
        date = [[JSONData objectForKey:@"date"] intValue];
        image_loaded = 0;
        last_synced = [[JSONData objectForKey:@"last_modified"] intValue];
        
        [self save_to_db]; 
        //NSLog(@"createing %i",[self get_web_id]);
    }
    else 
    {
        //Existing record
        //NSLog(@" last synced %i %i",last_synced, last_synced_json);
        if(last_synced< last_synced_json) //only update if the old record is out of date
        {
            if(image_loaded==1)//if the image was previously loaded delete it
            {
                //initialize the variables that are needed to point to the images location
                NSFileManager *filemgr = [NSFileManager defaultManager];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString * filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,mobile_image];
                [filemgr removeItemAtPath:filePath error: NULL]; 
            }
            
            //New record create it
            web_id= [[JSONData objectForKey:@"id"] intValue];
            web_image = [[NSMutableString alloc] initWithString:[JSONData objectForKey:@"imageurl"]];
            mobile_image = [[NSMutableString alloc] initWithString:@""]; //[NSMutableString stringWithString:@""];
            name = [[NSMutableString alloc] initWithString:[JSONData objectForKey:@"title"]];
            author = [[NSMutableString alloc] initWithString:[JSONData objectForKey:@"author"]];
            active = 1;
            date = [[JSONData objectForKey:@"date"] intValue];
            image_loaded = 0;
            last_synced = [[JSONData objectForKey:@"last_modified"] intValue];
            //NSLog(@"update category %i",[self get_web_id]);
            [self save_to_db]; 
        }
        //else
           // NSLog(@"record uptodate %i %i %i",[self get_web_id],last_synced,last_synced_json);
    }

}

+(NSMutableArray *) load_current_category_db
{
    NSMutableArray *categories;
    categories = [[NSMutableArray alloc] init];
    //initiate the sqlite variables that are needed to pull the data
    sqlite3_stmt *statement;
    sqlite3 *thriveDB=[[VariableStore sharedInstance] thriveDB];
    const char *dbpath = [[VariableStore databasePath] UTF8String];
    
    int count=0;
    
    if(sqlite3_open(dbpath,&thriveDB)==SQLITE_OK)
    {
        //Get the unix timestamp
        NSString *loadSQL = [NSString stringWithFormat: @"SELECT * from MESSAGE_CATEGORY WHERE active=1 order by date desc"];
        const char *query_stmt = [loadSQL UTF8String];
        if(sqlite3_prepare_v2(thriveDB,query_stmt,-1,&statement,NULL)==SQLITE_OK)
        {
            //Now that we have the data process its 
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                //populate a Message categoies object with the db data 
                MessageCategory *mCategory = [[MessageCategory alloc] init];
                [mCategory load_item_db_statment:statement];

                [categories addObject:mCategory];
                
                [mCategory release];
                mCategory = nil;
                
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
    
    //if we loaded any message categories items run through them. 
    if(count>0)
    {
        MessageCategory *category_item;
        for(category_item in categories)
        {
            //Check to see if we have the image otherwise try to load it
            if([category_item is_image_loaded]==false)
            {
                [category_item pull_image_from_web];
            }
        }
    }
    
    return categories;
}

-(void)dealloc
{
    [name release];
    name = nil;
    [web_image release];
    web_image = nil;
    [mobile_image release];
    mobile_image = nil;
    [author release];
    author = nil;
    
    [super dealloc];
}
@end
