//
//  UIImage+CustomAnimationView.h
//  Hackathon
//
//  Created by Sudeep Unnikrishnan on 20/01/16.
//  Copyright © 2016 Paytm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>


@interface UIImage (CustomAnimationView)

- (UIImage *)imageBlurWithWidth:(CGFloat)width iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor;


@end
