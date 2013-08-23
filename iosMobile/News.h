//
//  News.h
//  iosMobile
//
//  Created by Aaron Salo on 2/16/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"


@interface News : NSObject {
    int n_id;
    int local_id;
    NSMutableString *image_web;
    NSMutableString *image_mobile;
    NSMutableString *link;
    NSMutableString *caption;
    int active;
    long start_date;
    long end_date;
    int mobile_loaded;
    long last_synced;
}

//get the local location of the image
-(NSString *) get_image;
//check if the image is load yet
-(BOOL) is_image_loaded;
//try to pull the image from the web
-(BOOL) pull_image_from_web;
//return the link for the news item(web)
-(NSString *) get_link;
//return the caption for an image
-(NSString *) get_caption;
//check if the new item is active
-(BOOL) is_active;
//get the web id
-(int) get_web_id;
//get the last time this record was synced
-(long) get_last_synced;

//get the web image location
-(NSString *) get_web_image;

//pull a single item from the db by the id
-(void) load_item_db: (int) db_id;
-(void) load_item_db_statment: (sqlite3_stmt *) statement;
//save an item to the db
-(BOOL) save_to_db;
//load item from source 
-(void) load_items_from_server: (NSDictionary *) JSONData;
+(NSMutableArray *) load_current_items_db;
@end
