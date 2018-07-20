//
//  FAQViewController.m
//  Konnect
//
//  Created by Simpalm_mac on 13/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "FAQViewController.h"
#import "FAQCell/FAQCell.h"
@interface FAQViewController ()<UIWebViewDelegate>

@end

@implementation FAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tblFAQ.estimatedRowHeight = 40.0;
    _tblFAQ.rowHeight = UITableViewAutomaticDimension;
    arrTableData = [NSMutableArray new];
    _tblFAQ.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    NSDictionary *dictData;
    dictData = @{@"userName" : @"Stacy Lambert", @"userImage" : @"imgCommentUserPic1", @"description" : @"On the other hand, we denounce with righteous indignation and dislike men who are so beguiled and demoralized by the charms of pleasure of the moment, so blinded by desire, that they cannot foresee the pain and trouble that are bound to ensue; and equal blame belongs to those who fail in their duty through weakness of will, which is the same as saying through shrinking from toil and pain. These cases are perfectly simple and easy to distinguish."};
    [arrTableData addObject:dictData];
    dictData = @{@"userName" : @"Thompson", @"userImage" : @"imgCommentUserPic2", @"description" : @"At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis est et expedita distinctio. Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est, omnis dolor repellendus. Temporibus autem quibusdam et aut officiis debitis aut rerum necessitatibus saepe eveniet ut et voluptates repudiandae sint et molestiae non recusandae."};
    [arrTableData addObject:dictData];
    dictData = @{@"userName" : @"Brown", @"userImage" : @"imgCommentUserPic3", @"description" : @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."};
    [arrTableData addObject:dictData];
    [_tblFAQ reloadData];
    [self LoadWebviewWithData];
}

-(void)LoadWebviewWithData
{
    NSString *htmlFile, *htmlString;
    htmlFile = [[NSBundle mainBundle] pathForResource:@"KonnectFAQ" ofType:@"html"];
    htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    _webViewFAQ.delegate = self;
    [_webViewFAQ loadHTMLString:htmlString baseURL: [[NSBundle mainBundle] bundleURL]];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    return 3;
    
}- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"FAQCell";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    FAQCell *cell = (FAQCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *dictData;
    dictData = [arrTableData objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lblHead.text = [dictData valueForKey:@"userName"];
   // cell.imgUserCommentCell.image = [UIImage imageNamed:[dictData valueForKey:@"userImage"]];
    cell.lblDescription.text = [dictData valueForKey:@"description"];
    return cell;
    
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

@end
