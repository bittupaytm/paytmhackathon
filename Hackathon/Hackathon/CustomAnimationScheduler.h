//
//  CustomAnimationScheduler.h
//  Hackathon
//
//  Created by Sudeep Unnikrishnan on 20/01/16.
//  Copyright © 2016 Paytm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomAnimationView.h"


@interface CustomAnimationScheduler : NSObject

@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic, assign) NSUInteger viewIndex;
@property (nonatomic, assign) NSUInteger updatesEnabled;
@property (nonatomic, assign) BOOL blurEnabled;
@property (nonatomic, assign) BOOL updating;


+ (instancetype)sharedInstance;
- (instancetype)init;
- (void)setBlurEnabled:(BOOL)blurEnabled;
- (void)setUpdatesEnabled;
- (void)setUpdatesDisabled;
- (void)addView:(CustomAnimationView *)view;

- (void)removeView:(CustomAnimationView *)view;
- (void)updateAsynchronously;

@end
