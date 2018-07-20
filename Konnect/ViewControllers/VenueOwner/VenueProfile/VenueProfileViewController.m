//
//  VenueProfileViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 12/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueProfileViewController.h"
#import "VenueAddressTableViewCell.h"
#import "VenueSliderCellTableViewCell.h"
@interface VenueProfileViewController ()
{
    NSArray *arrVenueName;
    NSArray *arrVenueAddress;
}
@end

@implementation VenueProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tblVenueDetails.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    arrVenueName = [NSArray arrayWithObjects:@"",@"Venue Address",@"Venue Hours",@"Venue Type",@"Venue Specials",nil];
    
    arrVenueAddress = [NSArray arrayWithObjects:@"",@"4 Pennsylvania Plaza, New York.",@"11:00 AM to 12:30 PM",@"Sport Bar",@"Beer on Top",nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - KIImagePager DataSource
- (NSArray *) arrayWithImages:(KIImagePager*)pager
{
    return @[
             @"https://wallpaperscraft.com/image/bar_interior_background_83826_602x339.jpg",
             @"http://hd.wallpaperswide.com/thumbs/bar-t2.jpg",
             @"https://wallpaperscraft.com/image/bar_cafe_chairs_tables_interior_style_39215_602x339.jpg",
             @"http://hd.wallpaperswide.com/thumbs/bar-t2.jpg",
             @"https://wallpaperscraft.com/image/bar_cafe_chairs_tables_interior_style_39215_602x339.jpg",
             ];
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image inPager:(KIImagePager *)pager
{
    return UIViewContentModeScaleAspectFill;
}

#pragma mark - KIImagePager Delegate
- (void) imagePager:(KIImagePager *)imagePager didScrollToIndex:(NSUInteger)index
{
    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}

- (void) imagePager:(KIImagePager *)imagePager didSelectImageAtIndex:(NSUInteger)index
{
    NSLog(@"%s %lu", __PRETTY_FUNCTION__, (unsigned long)index);
}


#pragma mark - UITableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return arrVenueAddress.count;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    if (indexPath.row==0)
    {
        return 259;
    }
    else
    {
        return 80;
    }
    
    
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0)
    {
    static NSString *CellIdentifier = @"CellSlider";
    VenueSliderCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[VenueSliderCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        cell.viewSlider.pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        cell.viewSlider.pageControl.pageIndicatorTintColor = [UIColor greenColor];
        cell.viewSlider.slideshowTimeInterval = 5.5f;
        cell.viewSlider.slideshowShouldCallScrollToDelegate = YES;
        cell.viewSlider.delegate = self;
        cell.viewSlider.dataSource = self;
        
    return cell;
    }
    else
        
    {
        static NSString *CellIdentifier = @"Cell";
        VenueAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[VenueAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.lblVenueStatic.text = [arrVenueName objectAtIndex:indexPath.row];
        cell.lblVenueAddressDetails.text = [arrVenueAddress objectAtIndex:indexPath.row];
        return cell;
    }
    
}

#pragma mark - IBAction Method
-(IBAction)clickEditEvent:(id)sender
{
    
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
