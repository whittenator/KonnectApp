//
//  ProgressView.h
//  RealTime
//
//  Created by Balraj Randhawa on 27/04/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressView : UIView
{
    CGFloat startAngle;
    CGFloat endAngle;
}
@property (assign) int percent;
@end
