//
//  FriendsListScreenVC.m
//  Konnect
//
//  Created by Simpalm_mac on 17/01/18.
//  Copyright © 2018 Balraj Randhawa. All rights reserved.
//

#import "FriendsListScreenVC.h"
#import <AWSS3/AWSS3.h>
#import "KN_User.h"
#import "FriendsCell.h"
#import "UIImageView+WebCache.h"
#import "ProfileScreenViewController.h"
@interface FriendsListScreenVC ()

@end

@implementation FriendsListScreenVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _lblHeading.text = _strTitle;
    if([[Singlton sharedManager] CheckInterConnectivity] == NO)
    {
        [[Singlton sharedManager] alert:self title:Alert message:InternetCheck];
        return;
    }
    [self GetListOfFriends:_arrayFriends];
    // Do any additional setup after loading the view.
}

-(void)GetListOfFriends:(NSMutableArray *)arrayOfId
{
 [[Singlton sharedManager]showHUD];
NSMutableDictionary *dictionaryAttributes = [[NSMutableDictionary alloc] init];
    NSString *expression = @"";
    for (int i = 0; i < arrayOfId.count; i++) {
        NSString *variableName = [NSString stringWithFormat:@":val%i", i+1];
        [dictionaryAttributes setValue:arrayOfId[i] forKey:variableName];
        expression = [expression stringByAppendingString:expression.length ? [NSString stringWithFormat:@"OR #P = %@ " , variableName] : [NSString stringWithFormat:@"#P = %@ " , variableName]];
    }
    
    AWSDynamoDBScanExpression *query = [AWSDynamoDBScanExpression new];
    query.expressionAttributeNames = @{
                                       @"#P": [NSString stringWithFormat:@"%@", @"UserId"]
                                       };
    query.filterExpression = expression;
    query.expressionAttributeValues = dictionaryAttributes;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    [[dynamoDBObjectMapper scan:[KN_User class] expression:query] continueWithBlock:^id _Nullable(AWSTask * _Nonnull task) {
        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@" Paginated Output %@",task.result);
                [_arrayFriends removeAllObjects];
                [[Singlton sharedManager]killHUD];
                AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                for (KN_User *chat in paginatedOutput.items) {
                    [_arrayFriends addObject:chat.dictionaryValue];
                    }
               _tblfriends.delegate = self;
                _tblfriends.dataSource = self;
                [_tblfriends reloadData];
               
            });
           
        }
        if (task.error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error %@",task.error);
                [[Singlton sharedManager]killHUD];
            });
        }
        return nil;
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _arrayFriends.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *quantityCellIdentifier = @"Cell";
    FriendsCell *cell = (FriendsCell *)[tableView dequeueReusableCellWithIdentifier:quantityCellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblName.text = [NSString stringWithFormat:@"%@ %@",[[_arrayFriends objectAtIndex:indexPath.row]valueForKey:@"Firstname"],[[_arrayFriends objectAtIndex:indexPath.row]valueForKey:@"Lastname"]];
    NSString *strForEventImageName = [[[_arrayFriends valueForKey:@"UserImage"]objectAtIndex:indexPath.row] stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BASE_CONSUMER_IMAGE_URL,strForEventImageName]];
    [cell.imgUser sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"DefaultSetupImage"]];
    return  cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   /* ProfileScreenViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileScreenViewController"];
    [Singlton sharedManager].dictNonLoginUser = [_arrayFriends objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:ivc animated:YES];*/
   
    
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
