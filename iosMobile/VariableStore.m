//
//  VariableStore.m
//  iosMobile
//
//  Created by Aaron Salo on 2/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "VariableStore.h"

NSString *databasePath_local;

@implementation VariableStore
+ (VariableStore *)sharedInstance
{
    static VariableStore * myInstance = nil;
    
    if(nil == myInstance) {
        myInstance = [[[self class] alloc] init];
        
        //initialize the variables 
        NSString *docsDir;
        NSArray *dirPaths;
        //get the documents directory
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        docsDir = [dirPaths objectAtIndex:0];
        //Build the path to the database file
        databasePath_local = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"thrive.db"]];
        
        //[dirPaths release];
        //[docsDir release];
    }
    
    return myInstance;
}

+(NSString *) databasePath
{
    return databasePath_local;
}

-(sqlite3 *) thriveDB
{
    return thriveDB_local;
}

@end
