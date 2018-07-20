//
//  VenueImageViewController.m
//  Konnect
//
//  Created by Balraj on 09/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "VenueImageViewController.h"
#import "UIImageView+WebCache.h"
#import "NSDate+NVTimeAgo.h"
#import "VenueOwnerCommentViewController.h"
#import "KN_Staging_PostEvent.h"
@interface VenueImageViewController ()

@end

@implementation VenueImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *url;
    if ([_strchek isEqualToString:@"Gallery"]) {
        
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_VENUEGALLERY_IMAGE_URL,_strImage]];
        lblEventName.text = _strEventName;
        lblFullDetails.text = _strEventName;
        btnComment.hidden = YES;
        [self addReadMoreStringToUILabel:lblEventName];
    }
    else
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_POST_EVENT_IMAGE_URL,_strImage]];
        lblEventName.text = _strEventName;
        btnComment.hidden = NO;
        NSString *strCount = [NSString stringWithFormat:@"%@ Comments",[_dicPostDetails valueForKey:@"commentCount"]];
        [btnComment setTitle:strCount forState:UIControlStateNormal];
    }
    
    [imgEvent sd_setImageWithURL:url
                placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    
    NSURL *Userurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,_strUserImage]];
    
    [imgUserProfile sd_setImageWithURL:Userurl
                      placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    
    
    if (![_strUserImage isEqual:[NSNull null]]) {
        NSURL *Userurl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,_strUserImage]];
        
        [imgUserProfile sd_setImageWithURL:Userurl
                          placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
        imgUserProfile.hidden = NO;
        lblUserName.hidden = NO;
        
        lblDateTime.frame = CGRectMake( lblDateTime.frame.origin.x, lblDateTime.frame.origin.y, lblDateTime.frame.size.width, lblDateTime.frame.size.height);
        lblUserName.text = _strName;
    }
    else
    {
        imgUserProfile.hidden = YES;
        lblUserName.hidden = YES;
        [lblDateTime setTranslatesAutoresizingMaskIntoConstraints:YES];
        lblDateTime.frame = CGRectMake( self.view.frame.origin.x+20, lblDateTime.frame.origin.y, lblDateTime.frame.size.width, lblDateTime.frame.size.height);
    }
  
    

    
    NSNumber *numberDate = _eventDateTime;
    NSDate *postdate = [NSDate dateWithTimeIntervalSince1970:[numberDate doubleValue]];
    NSString *strPostDate = [[Singlton sharedManager]convertDateToString:postdate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mm a"];
    NSDate *myDate = [formatter dateFromString:strPostDate];
    [formatter setDateFormat:@"MMMM d,yyyy hh:mm a"];
    NSString *ago = [myDate formattedAsTimeAgo];
    lblDateTime.text = ago;
    
    UITapGestureRecognizer *viewTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToView)];
    viewTapGesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:viewTapGesture];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"ChangeCommmentCount"
                                               object:nil];
}
#pragma mark - IBAction Method
-(IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)readMoreDidClickedGesture
{
    

    [UIView transitionWithView:viewContainer duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        
                        viewContainer.hidden = NO;
                        imgBackgraound.hidden = NO;
                        lblEventName.hidden = YES;
                        viewContainer.frame  =  CGRectMake(viewContainer.frame.origin.x, viewContainer.frame.origin.y+20, viewContainer.frame.size.width, viewContainer.frame.size.height);
                        
                    }completion:NULL];
}
-(void)tapToView
{
    
    
    [UIView transitionWithView:viewContainer duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        viewContainer.hidden = YES;
                        imgBackgraound.hidden = YES;
                        lblEventName.hidden = NO;
                        viewContainer.frame  =  CGRectMake(viewContainer.frame.origin.x, self.view.frame.size.height-215, viewContainer.frame.size.width, viewContainer.frame.size.height);
                        
                    }completion:NULL];
}
- (IBAction)clickCommentsButton:(id)sender {
    
    VenueOwnerCommentViewController *Vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VenueOwnerCommentViewController"];
    Vc.strPostId = [_dicPostDetails valueForKey:@"Id"];
    Vc.strEventName = _strEventName;
    Vc.strChek = _strchek;
    Vc.strNavigationCheck = @"Present";
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:Vc];
    loginNav.navigationBarHidden = YES;
    [self presentViewController:loginNav animated:YES completion:nil];
}
- (void) receiveTestNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"ChangeCommmentCount"])
    {
        NSDictionary *userInfo = notification.userInfo;
        if ([[userInfo allKeys] containsObject:@"Count"]) {
            
            NSString *strCount = [NSString stringWithFormat:@"%@ Comments",[userInfo valueForKey:@"Count"]];
            [btnComment setTitle:strCount forState:UIControlStateNormal];
        }
       
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Custom Method
- (void)addReadMoreStringToUILabel:(UILabel*)label
{
    NSString *readMoreText = @" ...Read More";
    NSInteger lengthForString = label.text.length;
    if (lengthForString >= 20)
    {
        NSInteger lengthForVisibleString = [self fitString:label.text intoLabel:label];
        NSMutableString *mutableString = [[NSMutableString alloc] initWithString:label.text];
        NSString *trimmedString = [mutableString stringByReplacingCharactersInRange:NSMakeRange(lengthForVisibleString, (label.text.length - lengthForVisibleString)) withString:@""];
        NSInteger readMoreLength = readMoreText.length;
        NSString *trimmedForReadMore = [trimmedString stringByReplacingCharactersInRange:NSMakeRange((trimmedString.length - readMoreLength), readMoreLength) withString:@""];
        NSMutableAttributedString *answerAttributed = [[NSMutableAttributedString alloc] initWithString:trimmedForReadMore attributes:@{
                                                                                                                                        NSFontAttributeName : label.font
                                                                                                                                        }];
        
        NSMutableAttributedString *readMoreAttributed = [[NSMutableAttributedString alloc] initWithString:readMoreText attributes:@{
                                                                                                                                    NSFontAttributeName : [UIFont fontWithName:@"Roboto-Regular" size:12],
                                                                                                                                    NSForegroundColorAttributeName : [UIColor grayColor]
                                                                                                                                    }];
        
        [answerAttributed appendAttributedString:readMoreAttributed];
        label.attributedText = answerAttributed;
        
        UITapGestureRecognizer *readMoreGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(readMoreDidClickedGesture)];
        readMoreGesture.numberOfTapsRequired = 1;
        [label addGestureRecognizer:readMoreGesture];
        
        label.userInteractionEnabled = YES;
    }
    else {
        
        NSLog(@"No need for 'Read More'...");
        
    }
}
- (NSUInteger)fitString:(NSString *)string intoLabel:(UILabel *)label
{
    UIFont *font           = label.font;
    NSLineBreakMode mode   = label.lineBreakMode;
    
    CGFloat labelWidth     = label.frame.size.width;
    CGFloat labelHeight    = label.frame.size.height;
    CGSize  sizeConstraint = CGSizeMake(labelWidth, CGFLOAT_MAX);
    
    if (SYSTEM_VERSION_GREATER_THAN(@"7.0"))
    {
        NSDictionary *attributes = @{ NSFontAttributeName : font };
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        CGRect boundingRect = [attributedText boundingRectWithSize:sizeConstraint options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        {
            if (boundingRect.size.height > labelHeight)
            {
                NSUInteger index = 0;
                NSUInteger prev;
                NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                
                do
                {
                    prev = index;
                    if (mode == NSLineBreakByCharWrapping)
                        index++;
                    else
                        index = [string rangeOfCharacterFromSet:characterSet options:0 range:NSMakeRange(index + 1, [string length] - index - 1)].location;
                }
                
                while (index != NSNotFound && index < [string length] && [[string substringToIndex:index] boundingRectWithSize:sizeConstraint options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size.height <= labelHeight);
                
                return prev;
            }
        }
    }
    else
    {
        if ([string sizeWithFont:font constrainedToSize:sizeConstraint lineBreakMode:mode].height > labelHeight)
        {
            NSUInteger index = 0;
            NSUInteger prev;
            NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            
            do
            {
                prev = index;
                if (mode == NSLineBreakByCharWrapping)
                    index++;
                else
                    index = [string rangeOfCharacterFromSet:characterSet options:0 range:NSMakeRange(index + 1, [string length] - index - 1)].location;
            }
            
            while (index != NSNotFound && index < [string length] && [[string substringToIndex:index] sizeWithFont:font constrainedToSize:sizeConstraint lineBreakMode:mode].height <= labelHeight);
            
            return prev;
        }
    }
    
    return [string length];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
