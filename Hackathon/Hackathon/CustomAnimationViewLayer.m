//
//  CustomAnimationViewLayer.m
//  Hackathon
//
//  Created by Sudeep Unnikrishnan on 20/01/16.
//  Copyright © 2016 Paytm. All rights reserved.
//

#import "CustomAnimationViewLayer.h"

@implementation CustomAnimationViewLayer

@dynamic blurRadius;

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([@[@"blurRadius", @"bounds", @"position"] containsObject:key])
    {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

@end
