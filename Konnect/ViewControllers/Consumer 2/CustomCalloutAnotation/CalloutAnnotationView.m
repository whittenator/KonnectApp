//
//  CalloutAnnotationView.m
//  CustomCalloutSample
//
//  Created by tochi on 11/05/17.
//  Copyright 2011 aguuu,Inc. All rights reserved.
//

#import "CalloutAnnotationView.h"
#import "CalloutAnnotation.h"

@implementation CalloutAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
  
  if (self) {
      self.frame = CGRectMake(0.0f, 0.0f, 180, 280);
     // self.backgroundColor = [UIColor colorWithRed:0.9411 green:0.9411 blue:0.9411 alpha:1.0];
      self.backgroundColor = [UIColor clearColor];
      self.layer.borderColor = [UIColor colorWithRed:0.3254 green:0.5843 blue:0.9019 alpha:1.0].CGColor;
      //self.layer.borderWidth = 4.0f; location_tool_tip
    
     
    
     
      
      _imgPopUp = [[UIImageView alloc]init];
      [self.imgPopUp setFrame:CGRectMake(30, 180, 153, 74)];
      [self.imgPopUp setImage:[UIImage imageNamed:@"imgCalloutPopUp"]];
      
      _button = [UIButton buttonWithType:UIButtonTypeCustom];
      [self.button setFrame:CGRectMake(15, 180, 153, 74)];
      //[self.button setTitle:@"more info" forState:UIControlStateNormal];
      //[self.button setTitleColor:[UIColor colorWithRed:140 green:214 blue:255 alpha:1.0] forState:UIControlStateNormal];
      [self.button addTarget:self action:@selector(calloutButtonClicked) forControlEvents:UIControlEventTouchUpInside];
      
      _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 190, 135, 15)];//8CD6FF
      self.titleLabel.textColor = [UIColor colorWithRed:140.0f/255.0f green:214.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    
      self.titleLabel.textAlignment = NSTextAlignmentLeft;
      self.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14];
      _titleLabel.numberOfLines = 1;
      _titleLabel.minimumScaleFactor = 0.5;
      _titleLabel.adjustsFontSizeToFitWidth = YES;
      
    
      
      _destitleLabel= [[UILabel alloc] initWithFrame:CGRectMake(40, 205, 135, 33)];
      _destitleLabel.textColor = [UIColor whiteColor];
      self.destitleLabel.textAlignment = NSTextAlignmentLeft;
      self.destitleLabel.font = [UIFont fontWithName:@"Arial" size:10];
      _destitleLabel.numberOfLines = 2;
      _destitleLabel.minimumScaleFactor = 0.4;
      _destitleLabel.adjustsFontSizeToFitWidth = YES;

      [self addSubview:self.imgPopUp];
      [self addSubview:self.titleLabel];
       [self addSubview:self.destitleLabel];
      [self addSubview:self.button];
  }
  return self;
}


-(void)drawRect:(CGRect)rect
{
  [super drawRect:rect];
  self.titleLabel.text = self.title;
    self.destitleLabel.text=self.subTitle;
}

#pragma mark - Button clicked
- (void)calloutButtonClicked
{
  CalloutAnnotation *annotation = self.annotation;
  [self.delegate calloutButtonClicked:(NSString *)annotation.title];
}
@end
