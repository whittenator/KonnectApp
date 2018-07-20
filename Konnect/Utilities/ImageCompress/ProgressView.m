//
//  ProgressView.m
//  RealTime
//
//  Created by Balraj Randhawa on 27/04/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ProgressView.h"

@implementation ProgressView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        // Determine our start and stop angles for the arc (in radians)
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Display our percentage as a string
    NSString* textContent = [NSString stringWithFormat:@"%d", self.percent];
    
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:CGPointMake(rect.size.width / 2, rect.size.height / 2)
                          radius:15
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * (_percent / 120.0) + startAngle
                       clockwise:YES];
    
    // Set the display for the path, and stroke it
    bezierPath.lineWidth = 3;
    [[UIColor whiteColor] setStroke];
    [bezierPath stroke];
    
    // Text Drawing
    CGRect textRect = CGRectMake((rect.size.width / 2.0) - 71/2.0,18, 71, 45);
    [[UIColor whiteColor] setFill];
    [textContent drawInRect: textRect withFont: [UIFont fontWithName: @"Montserrat-Regular" size:12.0] lineBreakMode: NSLineBreakByWordWrapping alignment: NSTextAlignmentCenter];
}
@end
