//
//  VariableStore.h
//  iosMobile
//
//  Created by Aaron Salo on 2/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface VariableStore : NSObject {
    sqlite3 *thriveDB_local;  //Declare a pointer to the db file
    
}

+ (VariableStore *)sharedInstance;

+(NSString *) databasePath;
-(sqlite3 *) thriveDB;

@end
