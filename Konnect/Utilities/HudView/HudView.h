//
//  HUDView.h
//  HUDView
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
@interface HudView : UIView
{
	UILabel *loadingLabel;
	HudView *loadingView;
    UIView *viewAlphafive;
    UIView *abhi;
    CGRect portraitrect,landscaperect;
}

@property (nonatomic,retain) UILabel *loadingLabel;
@property (nonatomic,retain)  HudView *loadingView;
-(id)loadingViewInView:(UIView *)aSuperview text:(NSString*)hudText;
-(void)removeView;
-(void)setUserInteractionEnabledForSuperview:(UIView *)aSuperview;
-(void)setHudOrientationToLandscape:(BOOL)orient;
@end
