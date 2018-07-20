//
//  PinAnnotation.h
//  CustomCalloutSample
//
//  Created by tochi on 11/05/17.
//  Copyright 2011 aguuu,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CalloutAnnotation.h"


@interface PinAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property  NSString *konnectVenue;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic) int index;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) CalloutAnnotation *calloutAnnotation;

@end
