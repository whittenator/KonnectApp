//
//  VenueContactUsViewController.m
//  Konnect
//
//  Created by Balraj Randhawa on 16/10/17.
//  Copyright © 2017 Balraj Randhawa. All rights reserved.
//

#import "VenueContactUsViewController.h"

@interface VenueContactUsViewController ()<UITextViewDelegate>

@end

@implementation VenueContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txtMessage.delegate = self;
    
    //For the textField Padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    txtEMail.leftView = paddingView;
    txtEMail.leftViewMode = UITextFieldViewModeAlways;
    
    
    [txtEMail.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [txtEMail.layer setBorderWidth: 0.5];
    
    [txtMessage.layer setBorderColor: [[UIColor lightGrayColor] CGColor]];
    [txtMessage.layer setBorderWidth: 0.5];

    // Do any additional setup after loading the view.
}

#pragma mark - IBAction Method

- (IBAction)clickButtons:(id)sender {
    
    if ([[Singlton sharedManager]check_null_data:txtEMail.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:Eamil_Alert];
        
    }
    else if  (![[Singlton sharedManager] validEmail:txtEMail.text])
    {
        [[Singlton sharedManager] alert:self title:Alert message:ValidEmail_Alert];
        
    }
    else if ([[Singlton sharedManager]check_null_data:txtMessage.text]) {
        
        [[Singlton sharedManager] alert:self title:Alert message:ContactUs];
        
    }
    else
    {
            [self.view endEditing:YES];
    }
    
    
}
#pragma mark - ----------Touches event------------
//Implement for hide keyborad on touch event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [txtEMail resignFirstResponder];
        [txtMessage resignFirstResponder];
        
    }
}

#pragma mark - UITextView Delegates
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
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
