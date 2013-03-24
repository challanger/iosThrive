//
//  MessageItem.m
//  iosMobile
//
//  Created by Aaron Salo on 3/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "MessageItem.h"
#import "/usr/include/sqlite3.h"
#import "VariableStore.h"

@implementation MessageItem

-(NSString *) get_file
{
    return file;
}
-(NSString *) get_name
{
    return name;
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

-(int) get_category
{
    return category_id;
}

-(int) get_last_synced
{
    return last_synced;
}

-(NSString *) get_formated_date
{
    return @"01/06/2013";
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
        NSString *loadSQL = [NSString stringWithFormat: @"SELECT * from MESSAGE_FILES WHERE webID=%i",db_id];
        const char *query_stmt = [loadSQL UTF8String];
        if(sqlite3_prepare_v2(thriveDB,query_stmt,-1,&statement,NULL)==SQLITE_OK)
        {
            //Now that we have the data process its 
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                //populate a Message categoies object with the db data 
                //MessageItem *mItem = [[MessageItem alloc] init];
                [self load_item_db_statment:statement];
                
                sqlite3_finalize(statement);
                sqlite3_close(thriveDB);
                return true;
            }
            sqlite3_finalize(statement);
        }
        else
        {
            NSLog(@"Failed to pull all of the news items %i",db_id);
        }
        sqlite3_close(thriveDB);
    }
    return false;

}
-(void) load_item_db_statment: (sqlite3_stmt *) statement
{
    n_id = sqlite3_column_int(statement, 0);
    web_id = sqlite3_column_int(statement, 1);
    category_id = sqlite3_column_int(statement, 2);
    file = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
    name = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
    active = sqlite3_column_int64(statement, 5);
    date = sqlite3_column_int(statement, 6);
    last_synced = sqlite3_column_int(statement, 7);
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
        if(n_id==0)
        {
            saveSQL = [NSString stringWithFormat: @"INSERT INTO MESSAGE_FILES (webID,category,file,name,date,last_synced) VALUES (%i,%i,'%@','%@',%i,%i)",web_id,category_id,file,name,date,last_synced];
        }
        else 
        {
            saveSQL = [NSString stringWithFormat: @"UPDATE MESSAGE_FILES set category=%i, file='%@', name='%@', date=%i, last_synced=%i WHERE webID=%i",category_id,file,name,date,last_synced,web_id];
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
-(void) load_items_from_server: (NSDictionary *) JSONData: (int) json_cat_id
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
        category_id = json_cat_id;
        file = [JSONData objectForKey:@"url"];
        name = [JSONData objectForKey:@"title"];
        active = 1;
        date = [[JSONData objectForKey:@"date"] intValue];
        last_synced = [[JSONData objectForKey:@"last_modified"] intValue];
        
        [self save_to_db]; 
    }
    else 
    {
        //Existing record
        if(last_synced< last_synced_json) //only update if the old record is out of date
        {
            web_id= [[JSONData objectForKey:@"id"] intValue];
            category_id = json_cat_id;
            file = [JSONData objectForKey:@"url"];
            name = [JSONData objectForKey:@"title"];
            active = 1;
            date = [[JSONData objectForKey:@"date"] intValue];
            last_synced = [[JSONData objectForKey:@"last_modified"] intValue];
            
            [self save_to_db];            
        }
        //else 
        //NSLog(@"record is upto date %ld %i",last_synced, last_synced_json);
    }

}

+(NSMutableArray *) load_current_files_db: (int) cat_id
{
    NSMutableArray *message_items;
    message_items = [[NSMutableArray alloc] init];
    //initiate the sqlite variables that are needed to pull the data
    sqlite3_stmt *statement;
    sqlite3 *thriveDB=[[VariableStore sharedInstance] thriveDB];
    const char *dbpath = [[VariableStore databasePath] UTF8String];
    
    int count=0;
    
    if(sqlite3_open(dbpath,&thriveDB)==SQLITE_OK)
    {
        //Get the unix timestamp
        NSString *loadSQL = [NSString stringWithFormat: @"SELECT * from MESSAGE_FILES WHERE category=%i order by date desc",cat_id];
        const char *query_stmt = [loadSQL UTF8String];
        if(sqlite3_prepare_v2(thriveDB,query_stmt,-1,&statement,NULL)==SQLITE_OK)
        {
            //Now that we have the data process its 
            while (sqlite3_step(statement)== SQLITE_ROW)
            {
                //populate a Message categoies object with the db data 
                MessageItem *mItem = [[MessageItem alloc] init];
                [mItem load_item_db_statment:statement];
                
                [message_items addObject:mItem];
                
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
    
    return message_items;
}

@end
