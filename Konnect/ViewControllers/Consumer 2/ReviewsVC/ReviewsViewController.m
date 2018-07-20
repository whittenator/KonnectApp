//
//  ReviewsViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 04/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "ReviewsViewController.h"
#import "MainViewController.h"
#import "KN_VenueRating.h"
#import "ReviewTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "ProfileScreenViewController.h"
@interface ReviewsViewController ()
{
    NSMutableArray *arrRating;
}
@end

@implementation ReviewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self GettingAllReviews];
    
    // Do any additional setup after loading the view.
}

-(void)GettingAllReviews
{
    _tblReviews.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tblReviews.estimatedRowHeight = 40.0;
    _tblReviews.rowHeight = UITableViewAutomaticDimension;
    [[Singlton sharedManager]showHUD];
    self.view.userInteractionEnabled = NO;
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.expressionAttributeNames = @{
                                                @"#P": [NSString stringWithFormat:@"%@", @"VenueId"]
                                                };
    scanExpression.filterExpression = @"(#P = :val1)";
    //    scanExpression.filterExpression = @"contains(#P,:val1) AND contains(#Q,:val2)";
    scanExpression.expressionAttributeValues = @{
                                                 @":val1" : [[Singlton sharedManager].dictVenueInfo valueForKey:@"place_id"]
                                                 };
    [[dynamoDBObjectMapper scan:[KN_VenueRating class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             self.view.userInteractionEnabled = YES;
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         
         if (task.result) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [[Singlton sharedManager]killHUD];
                 self.view.userInteractionEnabled = YES;
                 arrRating = [NSMutableArray new];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_VenueRating *chat in paginatedOutput.items) {
                     
                     [arrRating addObject:chat];
                     
                 }
                 
                 if (arrRating.count>0) {
                     
                     self.view.userInteractionEnabled = YES;
                     NSSortDescriptor * brandDescriptor = [[NSSortDescriptor alloc] initWithKey:@"CreatedAt" ascending:NO];
                     NSArray * sortedArray = [arrRating sortedArrayUsingDescriptors:@[brandDescriptor]];
                     [arrRating removeAllObjects];
                     [arrRating addObjectsFromArray:[sortedArray mutableCopy]];
                     [_tblReviews reloadData];
                 }
                 else
                 {
                     self.view.userInteractionEnabled = YES;
                     [[Singlton sharedManager]killHUD];
                     _tblReviews.hidden = YES;
                    // [self.navigationController popViewControllerAnimated:YES];
                      [[Singlton sharedManager] alert:self title:Alert message:@"This Venue has no Comments"];
                     
                     
                     
                 }
                 
             });
             
         }
         
         return nil;
         
     }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return arrRating.count;
    
}- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"ReviewsCell";
    ReviewTableViewCell *cell = (ReviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *dictData;
    dictData = [arrRating objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.btnGotoProfile.tag = indexPath.row;
    [cell.btnGotoProfile addTarget:self
                            action:@selector(goToProfile:)
       forControlEvents:UIControlEventTouchUpInside];
   NSURL *imageUrl = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@.jpg",BASE_CONSUMER_IMAGE_URL,[[dictData valueForKey:@"Email"]stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"]]];
    [cell.imgUser sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"imgEditProfileDefaultUser"]];

    cell.imgUserName.text = [dictData valueForKey:@"UserName"];
    if([[dictData valueForKey:@"VenueComment"]isEqualToString:@"NA"])
    {
        cell.lblDescription.text = @"     ";
    }
    else
    {
     cell.lblDescription.text = [dictData valueForKey:@"VenueComment"];
    }
    cell.viewRating.value = [[dictData valueForKey:@"VenueRatingValue"] doubleValue];
     [[Singlton sharedManager]imageProfileRounded:cell.imgUser withFlot:cell.imgUser.frame.size.width/2 withCheckLayer:NO];
    cell.viewRating.userInteractionEnabled = NO;
    return cell;
    
}
- (IBAction)goToProfile:(UIButton *)sender
{
    
    ProfileScreenViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
   //[[[NSUserDefaults standardUserDefaults]setValue:[arrRating objectAtIndex:sender.tag] forKey:@"nonLoginUser"]];
    [Singlton sharedManager].dictNonLoginUser = [arrRating objectAtIndex:sender.tag];
    [self.navigationController pushViewController:ivc animated:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    MainViewController *mainViewController = (MainViewController *)self.sideMenuController;
    mainViewController.leftViewSwipeGestureEnabled = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
