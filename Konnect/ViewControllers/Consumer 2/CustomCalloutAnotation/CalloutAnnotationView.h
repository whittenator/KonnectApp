//
//  CalloutAnnotationView.h
//  CustomCalloutSample
//
//  Created by tochi on 11/05/17.
//  Copyright 2011 aguuu,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol CalloutAnnotationViewDelegate;
@interface CalloutAnnotationView : MKAnnotationView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *destitleLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imgPopUp;

@property (nonatomic, assign) id<CalloutAnnotationViewDelegate> delegate;
@end

@protocol CalloutAnnotationViewDelegate
@required
- (void)calloutButtonClicked:(NSString *)title;
@end
