//
//  VenueRatingViewController.h
//  Konnect
//
//  Created by Simpalm_mac on 04/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "BaseVC.h"

@interface VenueRatingViewController : BaseVC<UITextViewDelegate>
- (IBAction)actionBack:(id)sender;
@property (weak, nonatomic) IBOutlet HCSStarRatingView *viewRating;

@property (weak, nonatomic) IBOutlet UITextView *txtViewComment;
- (IBAction)actionSubmit:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblPlaceHoler;

@end
