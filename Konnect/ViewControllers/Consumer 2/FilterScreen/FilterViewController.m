//
//  FilterViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 29/09/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "FilterViewController.h"
#import "FilterCell/FilterTableViewCell.h"
#import "MainViewController.h"
@interface FilterViewController ()
{
    BOOL isManageFilterImage;
}
@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    arrTableData = [[NSMutableArray alloc]initWithObjects:@"Konnect Venue with events", @"All Konnect Venues",@"All Venues", nil];
    _tblFilterData.dataSource = self;
    _tblFilterData.delegate = self;
    [_tblFilterData reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return 3;
    
}- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"FilterCell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    FilterTableViewCell *cell = (FilterTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblFilterType.text = [arrTableData objectAtIndex:indexPath.row];
    cell.imgFilter.tag = indexPath.row;
    cell.btnFilterType.tag = indexPath.row;
    [cell.btnFilterType addTarget: self action: @selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    if([Singlton sharedManager].arrFiltersForData.count > 0)
    {
        //Checking the condition and changing the imafe of button in cell accordingly.
        if([[[Singlton sharedManager].arrFiltersForData objectAtIndex:0]isEqualToString:[arrTableData objectAtIndex:indexPath.row]])
        {
         [ cell.imgFilter setImage:[UIImage imageNamed:@"imgFilterCheckSelected"] ];
        }
       else
        {
           [ cell.imgFilter setImage:[UIImage imageNamed:@"imgFilterCheckUnselected"] ];
        }
    }
    else
    {
        if(isManageFilterImage == YES)
        {}
        else
        {
          if(indexPath.row == 2)
          {
             [cell.imgFilter setImage:[UIImage imageNamed:@"imgFilterCheckSelected"]];
          }
         else
         {
            [cell.imgFilter setImage:[UIImage imageNamed:@"imgFilterCheckUnselected"]];
         }
        }
    }
    return cell;
    
}

- (IBAction)buttonClicked:(id)sender
{
    //Method for  chnage  the image select and unselect for button in cell
  UIButton *button=(UIButton *) sender;
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    FilterTableViewCell *tappedCell = (FilterTableViewCell *)[_tblFilterData cellForRowAtIndexPath:indexpath];
    [Singlton sharedManager].arrFiltersForData = [NSMutableArray new];
    [[Singlton sharedManager].arrFiltersForData removeAllObjects];
    if ([tappedCell.imgFilter.image isEqual:[UIImage imageNamed:@"imgFilterCheckUnselected"]])
    {
        [tappedCell.imgFilter setImage:[UIImage imageNamed:@"imgFilterCheckSelected"] ];
          [[Singlton sharedManager].arrFiltersForData addObject:[arrTableData objectAtIndex:button.tag] ];
        isManageFilterImage = NO;
    }
    else
    {
        isManageFilterImage = YES;
        [tappedCell.imgFilter setImage:[UIImage imageNamed:@"imgFilterCheckUnselected"]];
        [Singlton sharedManager].arrFiltersForData = nil;
    
    }
     [_tblFilterData reloadData];
}
/* UIButton *button=(UIButton *) sender;
 UIImage *image2 = [UIImage imageNamed:@"imgFilterCheckSelected"];
 UIImage *imageBtn = [button imageForState:UIControlStateNormal];
 if([ UIImagePNGRepresentation(image2) isEqualToData:
 UIImagePNGRepresentation(imageBtn)])
 {
 [Singlton sharedManager].arrFiltersForData = [NSMutableArray new];
 [[Singlton sharedManager].arrFiltersForData removeAllObjects];
 //[button setImage:[UIImage imageNamed:@"imgFilterCheckUnselected"] forState:UIControlStateNormal];
 }
 else
 {
 // [button setImage:image2 forState:UIControlStateNormal];
 [Singlton sharedManager].arrFiltersForData = [NSMutableArray new];
 [[Singlton sharedManager].arrFiltersForData removeAllObjects];
 [[Singlton sharedManager].arrFiltersForData addObject:[arrTableData objectAtIndex:button.tag] ];
 }
 [_tblFilterData reloadData];*/
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

- (IBAction)actionApplyFilter:(id)sender {
    if([Singlton sharedManager].arrFiltersForData.count == 0)
    {
        [[Singlton sharedManager] alert:self title:Alert message:@"You have to select filter from the list"];
    }
    else
    {
       [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)actionBack:(id)sender {
    [[Singlton sharedManager].arrFiltersForData removeAllObjects];
    [Singlton sharedManager].arrFiltersForData = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
@end
