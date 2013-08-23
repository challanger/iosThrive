//
//  MessageCategory.h
//  iosMobile
//
//  Created by Aaron Salo on 3/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface MessageCategory : NSObject {
    int n_id;
    int web_id;
    NSMutableString *name;
    NSMutableString *web_image;
    NSMutableString *mobile_image;
    NSMutableString *author;
    int date;
    int image_loaded;
    int active;
    int last_synced;
}

-(NSString *) get_image;
-(BOOL) is_image_loaded;
-(BOOL) pull_image_from_web;
-(NSString *) get_name;
-(NSString *) get_author;
-(int) get_date;
-(BOOL) get_active;
-(int) get_web_id;
-(int) get_last_synced;

//pull a single item from the db by the id
-(BOOL) load_item_db: (int) db_id;
-(void) load_item_db_statment: (sqlite3_stmt *) statement;
//save an item to the db
-(BOOL) save_to_db;
//load item from source 
-(void) load_items_from_server: (NSDictionary *) JSONData;
//load the current categoires 
+(NSMutableArray *) load_current_category_db;

@end
