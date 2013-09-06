//
//  FirstViewController.h
//  iosMobile
//
//  Created by Aaron Salo on 2/15/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"

@interface FirstViewController : UIViewController {
    UIView* mMainView;
    UIImageView* mImageView;
    UIImageView* mImageDropShadowView;
    NSTimer* loadNewsTimer;
    
    NSTimer* animateNewsTimer;
    
    NSMutableArray* imageViews;
    NSMutableArray* imageShadowViews;
    
    int newsImageIndex;
    int newsAnimationDirection;
}

@property (nonatomic, retain) IBOutlet UIView* mainView;
@property (nonatomic, retain) IBOutlet UIImageView* imageView;
@property (nonatomic, retain) IBOutlet UIImageView* imageDropShadowView;
@property (nonatomic, retain) NSTimer *loadNewsTimer;
@property (nonatomic, retain) NSTimer *animateNewsTimer;

-(BOOL) loadData;
-(void)autoTriggerNewsAnimation;
-(void)killNewsTimer;
-(void)startNewsTimer;
-(IBAction)swipeDetectedLeft:(UIGestureRecognizer *)sender;
-(IBAction)swipeDetectedRight:(UIGestureRecognizer *)sender;

@end
