//
//  VenueFAQViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 16/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueFAQViewController.h"
#import "VFAQTableViewCell.h"
@interface VenueFAQViewController ()<UIWebViewDelegate>

@end

@implementation VenueFAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self LoadWebviewWithData];
    // Do any additional setup after loading the view.
}

-(void)LoadWebviewWithData
{
    NSString *htmlFile, *htmlString;
    htmlFile = [[NSBundle mainBundle] pathForResource:@"KonnectFAQ" ofType:@"html"];
    htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    _webViewFAQ.delegate = self;
    [_webViewFAQ loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 10;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{

    return 130;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    VFAQTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[VFAQTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [cell.lblDescription sizeToFit];
    return cell;
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
