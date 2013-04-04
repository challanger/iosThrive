//
//  MessageItem.h
//  iosMobile
//
//  Created by Aaron Salo on 3/4/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"
#import "JSONKit.h"

@interface MessageItem : NSObject {
    int n_id;
    int web_id;
    int category_id;
    NSMutableString *file;
    NSMutableString *name;
    int active;
    int date;
    int last_synced;
}

-(NSString *) get_file;
-(NSString *) get_name;
-(NSString *) get_formated_date;
-(int) get_date;
-(BOOL) get_active;
-(int) get_web_id;
-(int) get_category;
-(int) get_last_synced;

//pull a single item from the db by the id
-(BOOL) load_item_db: (int) db_id;
-(void) load_item_db_statment: (sqlite3_stmt *) statement;
//save an item to the db
-(BOOL) save_to_db;
//load item from source 
-(void) load_items_from_server: (NSDictionary *)serverData data: (int) json_cat_id;
//load the current message items for a given category id
+(NSMutableArray *) load_current_files_db: (int) cat_id;

@end
