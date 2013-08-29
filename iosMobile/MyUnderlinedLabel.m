//
//  MyUnderlinedLabel.m
//  Thrive
//
//  Created by Aaron Salo on 8/22/13.
//
//

#import "MyUnderlinedLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyUnderlinedLabel

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Get bounds
    CGRect f = self.bounds;
    CGFloat yOff = f.origin.y + f.size.height - 3.0;
    
    // Calculate text width
    CGSize tWidth = [self.text sizeWithFont:self.font];
    
    // Draw underline
    CGContextRef con = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(con, self.textColor.CGColor);
    CGContextSetLineWidth(con, 1.0);
    CGContextMoveToPoint(con, f.origin.x, yOff);
    CGContextAddLineToPoint(con, f.origin.x + tWidth.width, yOff);
    CGContextStrokePath(con);
}

@end