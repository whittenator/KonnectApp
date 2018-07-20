//
//  HudView.m
//  HudView
//

#import "AppDelegate.h"
#import "HudView.h"
#import <QuartzCore/QuartzCore.h>


CGPathRef HudViewNewPathWithRoundRect(CGRect rect, CGFloat cornerRadius)
{
    //
    // Create the boundary path
    //
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL,
                      rect.origin.x,
                      rect.origin.y + rect.size.height - cornerRadius);
    
    // Top left corner
    CGPathAddArcToPoint(path, NULL,
                        rect.origin.x,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        cornerRadius);
    
    // Top right corner
    CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,cornerRadius);
    
    // Bottom right corner
    CGPathAddArcToPoint(path, NULL,
                        rect.origin.x + rect.size.width,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        cornerRadius);
    
    // Bottom left corner
    CGPathAddArcToPoint(path, NULL,
                        rect.origin.x,
                        rect.origin.y + rect.size.height,
                        rect.origin.x,
                        rect.origin.y,
                        cornerRadius);
    
    // Close the path at the rounded rect
    CGPathCloseSubpath(path);
    
    return path;
}
@interface HudView (){
    AppDelegate *appDelegate1;
}

@end

@implementation HudView
@synthesize loadingLabel,loadingView;

- (id)loadingViewInView:(UIView *)aSuperview text:(NSString*)hudText
{
    [aSuperview setUserInteractionEnabled:NO];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"HudLandScape" object:self];
    appDelegate1=(AppDelegate*)[UIApplication sharedApplication].delegate;
    loadingView=[[HudView alloc]init];
    
    loadingView.frame = CGRectMake(aSuperview.frame.size.width/2-75, aSuperview.frame.size.height/2-40, 150,80 );
    
    
    if (!loadingView)
    {
        return nil;
    }
    loadingView.opaque = NO;
    
    [aSuperview addSubview:loadingView];
    
    
    const CGFloat DEFAULT_LABEL_WIDTH = 160.0;
    const CGFloat DEFAULT_LABEL_HEIGHT = 50;
    CGRect labelFrame = CGRectMake(0, 30, DEFAULT_LABEL_WIDTH, DEFAULT_LABEL_HEIGHT);
    
    if ([hudText length]>20) {
        //loadingLabel.frame=CGRectMake(0,0,160,160);
        loadingLabel =[[UILabel alloc]initWithFrame:CGRectMake(0,30,160,160)];
        loadingLabel.numberOfLines = 5;
        loadingLabel.font = [UIFont boldSystemFontOfSize:13];
    }else {
        loadingLabel =[[UILabel alloc]initWithFrame:labelFrame];
        loadingLabel.numberOfLines = 2;
        loadingLabel.font = [UIFont boldSystemFontOfSize:14];
    }
    loadingLabel.text = hudText;
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.backgroundColor = [UIColor clearColor];
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    
    loadingLabel.autoresizingMask =UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleBottomMargin;
    
    [loadingView addSubview:loadingLabel];
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(60, 10, 30,30)];
    [activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    //initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [loadingView addSubview:activityIndicatorView];
    activityIndicatorView.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    [activityIndicatorView startAnimating];
    
    
    //
    // Set up the fade-in animation
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    [[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
    loadingView.alpha = 1;
    
    //Memory leak handling
    //	[activityIndicatorView release];
    [loadingView setBackgroundColor:[UIColor clearColor]];
    return loadingView;
}


- (void)removeView
{
    UIView *aSuperview = [self superview];
    [super removeFromSuperview];
    [aSuperview setUserInteractionEnabled:YES];
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionFade];
    
    [[aSuperview layer] addAnimation:animation forKey:@"layerAnimation"];
}

-(void)setUserInteractionEnabledForSuperview:(UIView *)aSuperview
{
    //loadingLabel.alpha = 0;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [aSuperview setUserInteractionEnabled:YES];
    
}

- (void)drawRect:(CGRect)rect
{
    CGRect rect2=rect;
    rect2.size.height -= 1;
    rect2.size.width -= 1;
    
    CGRect rect1=rect2;
    rect1.size.height -= 0.5;
    rect1.size.width -= 0.5;
    
    const CGFloat RECT_PADDING = 4.0;
    rect1 = CGRectInset(rect1, RECT_PADDING, RECT_PADDING);
    
    const CGFloat ROUND_RECT_CORNER_RADIUS = 8.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    const CGFloat BACKGROUND_OPACITY2 = 0.4f;
    CGPathRef roundRectPath3 = HudViewNewPathWithRoundRect(rect2, ROUND_RECT_CORNER_RADIUS);
    
    CGContextSetRGBFillColor(context,  1,1,1, BACKGROUND_OPACITY2);
    CGContextAddPath(context, roundRectPath3);
    CGContextFillPath(context);
    
    
    const CGFloat BACKGROUND_OPACITY = 1.0f;
    
    CGPathRef roundRectPath = HudViewNewPathWithRoundRect(rect1, ROUND_RECT_CORNER_RADIUS);
    CGContextSetRGBFillColor(context, 0, 0, 0, BACKGROUND_OPACITY);
    CGContextAddPath(context, roundRectPath);
    CGContextFillPath(context);
    CGPathRelease(roundRectPath3);
    CGPathRelease(roundRectPath);
}

-(void)setHudOrientationToLandscape:(BOOL)orient{
    if(orient){
        loadingView.frame=landscaperect;
    }else{
        loadingView.frame=portraitrect;
    }
}

@end
