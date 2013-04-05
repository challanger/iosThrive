//
//  iosMobileAppDelegate.h
//  iosMobile
//
//  Created by Aaron Salo on 2/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iosMobileAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    NSTimer* loadServerTimer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSTimer *loadServerTimer;
 
-(void) implementDB;
-(void)geServerRecords;
-(NSMutableArray *) pullServerRecords;

@end
