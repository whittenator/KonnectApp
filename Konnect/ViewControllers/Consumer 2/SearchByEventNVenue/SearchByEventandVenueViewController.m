//
//  SearchByEventandVenueViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 29/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "SearchByEventandVenueViewController.h"
#import "KN_Event.h"
#import "SearchEventNVenueCell.h"
#import "ConsumerVenueDetailVC.h"
#import "ConsumerVenueEventDetailVC.h"
#import "NonKonnectViewController.h"
@interface SearchByEventandVenueViewController ()
{
    NSMutableArray *arrFilteredArray;
}
@end

@implementation SearchByEventandVenueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrTableData = [NSMutableArray new];
    arrFilteredArray = [NSMutableArray new];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    _txtSearch.leftView = paddingView;
    _txtSearch.leftViewMode = UITextFieldViewModeAlways;
    if([Singlton sharedManager].arrKonnectVenues.count>0)
    {
    [self GetAllEventsForVenues];
    }
    [_txtSearch addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
}
-(void)textFieldDidChange
{
    [self  getApiForAutoComplete:_txtSearch.text];
}
-(void)getApiForAutoComplete:(NSString *)strInput

{
  dispatch_async(dispatch_get_main_queue(), ^{
     
   NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[c] %@", _txtSearch.text];
   NSArray *resultArray = [[arrFilteredArray filteredArrayUsingPredicate:predicate] mutableCopy];
                               arrTableData = [NSMutableArray arrayWithArray:resultArray];
                                               if (arrTableData.count>0) {
                                                   _tblVenueNEventNSearch.delegate = self;
                                                   _tblVenueNEventNSearch.dataSource = self;
                                                   _tblVenueNEventNSearch.hidden = NO;
                                                   [_tblVenueNEventNSearch reloadData];
                                               }
                                               else
                                               {
                                                   _tblVenueNEventNSearch.hidden = YES;
                                               }
                                           });
                                           
                                           
    

}
-(void)GetAllEventsForVenues
{
    [[Singlton sharedManager]showHUD];
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    
    [[dynamoDBObjectMapper scan:[KN_Event class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
            NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                 arrTableData = [NSMutableArray new];
                 [[Singlton sharedManager]killHUD];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_Event *chat in paginatedOutput.items)
                 {
                     NSDate *Eventdate = [[Singlton sharedManager]convertStringToDate:[NSString stringWithFormat:@"%@ %@",[chat valueForKey:@"EventDate"],[chat valueForKey:@"EndTime"]]];
                     
                     
                     BOOL checkEventTimeandDate = [[Singlton sharedManager]DateChekDifference:[NSDate date] andDate:Eventdate];
                     
                     if (checkEventTimeandDate) {
                         
                         [arrTableData addObject:chat.dictionaryValue];
                         
                     }
                    
                 }
                /* if([Singlton sharedManager].arrKonnectVenues.count>0)
                 {*/
                     
                    // [arrTableData addObjectsFromArray:[Singlton sharedManager].arrKonnectVenues];
                if(arrTableData.count > 0)
                {
                    NSMutableDictionary *tempDict = [NSMutableDictionary new];
                  
                        for(int j=0; j<arrTableData.count; j++)
                        {
                            tempDict = [[arrTableData objectAtIndex:j]mutableCopy];
                           [tempDict setObject:[[arrTableData objectAtIndex:j]valueForKey:@"Name"] forKey:@"name"];
                             [arrTableData replaceObjectAtIndex:j withObject:tempDict];
                                }
                            }
                
              
                     [arrTableData addObjectsFromArray:[Singlton sharedManager].arrDataTempStorage];
                     [arrFilteredArray addObjectsFromArray:arrTableData];
                   
                 //}
//                  if(arrTableData.count > 0)
//                 {
//                    [arrFilteredArray addObjectsFromArray:arrTableData];
//
//                 }
                  [[Singlton sharedManager]killHUD];
             });
             
         }
         
         return nil;
         
     }];
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return arrTableData.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    return 44;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    SearchEventNVenueCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SearchEventNVenueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary *dictData = [arrTableData objectAtIndex:indexPath.row];
    cell.lblDescription.text = [dictData valueForKey:@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dicValAtIndex = [arrTableData objectAtIndex:indexPath.row];
    NSArray *allKeys = [dicValAtIndex allKeys];

    if([allKeys containsObject:@"EventDate"])
    {
        NSLog(@"Event Exists");
        ConsumerVenueEventDetailVC *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerVenueEventDetailVC"];
        ivc.dicEventDetails = [arrTableData objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:ivc animated:YES];

    }
    else  if([allKeys containsObject:@"Konnect"])
    {
         NSLog(@"Venue Exists");
        for(int i =0 ; i < [Singlton sharedManager].arrDataTempStorage.count ; i++)
        {
            if([[[[Singlton sharedManager].arrDataTempStorage objectAtIndex:i]valueForKey:@"place_id"]isEqualToString:[dicValAtIndex valueForKey:@"place_id"]])
            {
                [Singlton sharedManager].dictVenueInfo = [[Singlton sharedManager].arrDataTempStorage objectAtIndex:i];
                [self.view endEditing:YES];
                ConsumerVenueDetailVC *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ConsumerVenueDetailVC"];
                [self.navigationController pushViewController:ivc animated:YES];
                break;
            }
        }
       
    }
    else
    {
         NSLog(@"Nonkonnect venue");
      [Singlton sharedManager].dictVenueInfo = [arrTableData objectAtIndex:indexPath.row];
        [self.view endEditing:YES];
        NonKonnectViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"NonKonnectViewController"];
        [self.navigationController pushViewController:ivc animated:YES];
    }
    
    
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
