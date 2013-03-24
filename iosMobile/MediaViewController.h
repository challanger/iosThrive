//
//  MediaViewController.h
//  iosMobile
//
//  Created by Aaron Salo on 3/2/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MediaViewController : UIViewController {
    UIScrollView *mUIScrollView;
}

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;

-(BOOL) loadData;
-(void) loadMessage: (id)sender;

@end
