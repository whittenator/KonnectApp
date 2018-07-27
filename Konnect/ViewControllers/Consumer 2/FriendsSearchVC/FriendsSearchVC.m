//
//  FriendsSearchVC.m
//  Konnect
//
//  Created by Travis Whitten on 7/26/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "FriendsSearchVC.h"
#import "KN_User.h"
#import "FriendsSearchTableViewCell.h"
#import "ProfileScreenViewController.h"
#import "UIImageView+WebCache.h"

@interface FriendsSearchVC ()
{
    NSMutableArray *arrFilteredArray;
}

@end

@implementation FriendsSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    arrTableData = [NSMutableArray new];
    arrFilteredArray = [NSMutableArray new];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    _txtSearch.leftView = paddingView;
    _txtSearch.leftViewMode = UITextFieldViewModeAlways;
    [self GetListOfUsers];
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
        //arrTableData = [NSMutableArray arrayWithArray:resultArray];
        _arrayUsers = [NSMutableArray arrayWithArray:resultArray];
        /*
        if (arrTableData.count>0) {
            _tblFriendSearch.delegate = self;
            _tblFriendSearch.dataSource = self;
            _tblFriendSearch.hidden = NO;
            [_tblFriendSearch reloadData];
        }
        else
        {
            _tblFriendSearch.hidden = YES;
        }
         */
        if (_arrayUsers.count>0) {
            _tblFriendSearch.delegate = self;
            _tblFriendSearch.dataSource = self;
            _tblFriendSearch.hidden = NO;
            [_tblFriendSearch reloadData];
        }
        else
        {
            _tblFriendSearch.hidden = YES;
        }
    });
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)GetListOfUsers
{
    [[Singlton sharedManager]showHUD];
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    
    [[dynamoDBObjectMapper scan:[KN_User class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             [[Singlton sharedManager]killHUD];
             NSLog(@"The request failed. Error: [%@]", task.error);
         }
         if(task.result) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@" Paginated Output %@",task.result);
                 arrTableData = [NSMutableArray new];
                 [[Singlton sharedManager]killHUD];
                 AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                 for (KN_User *chat in paginatedOutput.items)
                 {
                     [_arrayUsers addObject:chat.dictionaryValue];
                     [arrTableData addObject:chat.dictionaryValue];
                 }
                 if(arrTableData.count > 0)
                 {
                     NSMutableDictionary *tempDict = [NSMutableDictionary new];
                     
                     for(int j=0; j<arrTableData.count; j++)
                     {
                         tempDict = [[arrTableData objectAtIndex:j]mutableCopy];
                         [tempDict setObject:[[arrTableData objectAtIndex:j]valueForKey:@"Firstname"]forKey:@"name"];
                         [arrTableData replaceObjectAtIndex:j withObject:tempDict];
                     }
                 }
                 [arrTableData addObjectsFromArray:[Singlton sharedManager].arrDataTempStorage];
                 [arrFilteredArray addObjectsFromArray:arrTableData];
                 
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
    //return arrTableData.count;
    return _arrayUsers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 61;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    FriendsSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[FriendsSearchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //NSDictionary *dictData = [arrTableData objectAtIndex:indexPath.row];
    //cell.lblDescription.text = [dictData valueForKey:@"name"];
    cell.lblDescription.text = [NSString stringWithFormat:@"%@ %@",[[_arrayUsers objectAtIndex:indexPath.row]valueForKey:@"Firstname"],[[_arrayUsers objectAtIndex:indexPath.row]valueForKey:@"Lastname"]];
    NSString *usersImageName = [[[_arrayUsers valueForKey:@"UserImage"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,usersImageName]];
    [cell.userImg sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    //cell.lblDescription.text = [NSString stringWithFormat:@"%@ %@",[[_arrayUsers objectAtIndex:indexPath.row]valueForKey:@"FirstName"],
                               // [[_arrayUsers objectAtIndex:indexPath.row]valueForKey:@"LastName"]];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictValAtIndex = [_arrayUsers objectAtIndex:indexPath.row];
    NSArray *allKeys = [dictValAtIndex allKeys];
    
    if([allKeys containsObject:@"UserId"])
    {
        NSLog(@"Person Exists");
        ProfileScreenViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
        [Singlton sharedManager].dictNonLoginUser = [_arrayUsers objectAtIndex:indexPath.row];
        //ivc.dictUserProfile = [arrTableData objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:ivc animated:YES];
        
    }
}

-(IBAction)actionBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
