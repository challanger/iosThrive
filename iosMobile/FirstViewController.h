//
//  FirstViewController.h
//  iosMobile
//
//  Created by Aaron Salo on 2/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "/usr/include/sqlite3.h"

@interface FirstViewController : UIViewController {
    UIImageView* mImageView;
    NSTimer* loadNewsTimer;
}

@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) NSTimer *loadNewsTimer;

-(BOOL) loadData;

@end
