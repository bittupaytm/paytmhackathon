//
//  CustomAnimationView.m
//  Hackathon
//
//  Created by Sudeep Unnikrishnan on 20/01/16.
//  Copyright © 2016 Paytm. All rights reserved.
//

#import "CustomAnimationView.h"
#import "CustomAnimationScheduler.h"
#import "CustomAnimationViewLayer.h"
#import <objc/runtime.h>
#import "UIImage+CustomAnimationView.h"

@implementation CustomAnimationView

+ (void)setBlurEnabled:(BOOL)blurEnabled
{
    [CustomAnimationScheduler sharedInstance].blurEnabled = blurEnabled;
}

+ (void)setUpdatesEnabled
{
    [[CustomAnimationScheduler sharedInstance] setUpdatesEnabled];
}

+ (void)setUpdatesDisabled
{
    [[CustomAnimationScheduler sharedInstance] setUpdatesDisabled];
}

+ (Class)layerClass
{
    return [CustomAnimationViewLayer class];
}

- (void)setUp
{
    if (!_iterationsSet) _iterations = 3;
    if (!_blurRadiusSet) [self blurLayer].blurRadius = 40;
    if (!_dynamicSet) _dynamic = YES;
    if (!_blurEnabledSet) _blurEnabled = YES;
    self.updateInterval = _updateInterval;
    self.layer.magnificationFilter = @"linear"; // kCAFilterLinear
    
    unsigned int numberOfMethods;
    Method *methods = class_copyMethodList([UIView class], &numberOfMethods);
    for (unsigned int i = 0; i < numberOfMethods; i++)
    {
        Method method = methods[i];
        SEL selector = method_getName(method);
        if (selector == @selector(tintColor))
        {
            _tintColor = ((id (*)(id,SEL))method_getImplementation(method))(self, selector);
            break;
        }
    }
    free(methods);
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setUp];
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setIterations:(NSUInteger)iterations
{
    _iterationsSet = YES;
    _iterations = iterations;
    [self setNeedsDisplay];
}

- (void)setBlurRadius:(CGFloat)blurRadius
{
    _blurRadiusSet = YES;
    [self blurLayer].blurRadius = blurRadius;
}

- (CGFloat)blurRadius
{
    return [self blurLayer].blurRadius;
}

- (void)setBlurEnabled:(BOOL)blurEnabled
{
    _blurEnabledSet = YES;
    if (_blurEnabled != blurEnabled)
    {
        _blurEnabled = blurEnabled;
        [self schedule];
        if (_blurEnabled)
        {
            [self setNeedsDisplay];
        }
    }
}

- (void)setDynamic:(BOOL)dynamic
{
    _dynamicSet = YES;
    if (_dynamic != dynamic)
    {
        _dynamic = dynamic;
        [self schedule];
        if (!dynamic)
        {
            [self setNeedsDisplay];
        }
    }
}

- (UIView *)underlyingView
{
    return _underlyingView ?: self.superview;
}

- (CALayer *)underlyingLayer
{
    return self.underlyingView.layer;
}

- (CustomAnimationViewLayer *)blurLayer
{
    return (CustomAnimationViewLayer *)self.layer;
}

- (CustomAnimationViewLayer *)blurPresentationLayer
{
    CustomAnimationViewLayer *blurLayer = [self blurLayer];
    return (CustomAnimationViewLayer *)blurLayer.presentationLayer ?: blurLayer;
}

- (void)setUpdateInterval:(NSTimeInterval)updateInterval
{
    _updateInterval = updateInterval;
    if (_updateInterval <= 0) _updateInterval = 1.0/60;
}

- (void)setTintColor:(UIColor *)tintColor
{
    _tintColor = tintColor;
    [self setNeedsDisplay];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self.layer setNeedsDisplay];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    [self schedule];
}

- (void)schedule
{
    if (self.window && self.dynamic && self.blurEnabled)
    {
        [[CustomAnimationScheduler sharedInstance] addView:self];
    }
    else
    {
        [[CustomAnimationScheduler sharedInstance] removeView:self];
    }
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    [self.layer setNeedsDisplay];
}

- (BOOL)shouldUpdate
{
    __strong CALayer *underlyingLayer = [self underlyingLayer];
    
    return
    underlyingLayer && !underlyingLayer.hidden &&
    self.blurEnabled && [CustomAnimationScheduler sharedInstance].blurEnabled &&
    !CGRectIsEmpty([self.layer.presentationLayer ?: self.layer bounds]) && !CGRectIsEmpty(underlyingLayer.bounds);
}

- (void)displayLayer:(__unused CALayer *)layer
{
    [self updateAsynchronously:NO completion:NULL];
}

- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)key
{
    if ([key isEqualToString:@"blurRadius"])
    {
        //animations are enabled
        CAAnimation *action = (CAAnimation *)[super actionForLayer:layer forKey:@"backgroundColor"];
        if ((NSNull *)action != [NSNull null])
        {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:key];
            animation.fromValue = [layer.presentationLayer valueForKey:key];
            
            //CAMediatiming attributes
            animation.beginTime = action.beginTime;
            animation.duration = action.duration;
            animation.speed = action.speed;
            animation.timeOffset = action.timeOffset;
            animation.repeatCount = action.repeatCount;
            animation.repeatDuration = action.repeatDuration;
            animation.autoreverses = action.autoreverses;
            animation.fillMode = action.fillMode;
            
            //CAAnimation attributes
            animation.timingFunction = action.timingFunction;
            animation.delegate = action.delegate;
            
            return animation;
        }
    }
    return [super actionForLayer:layer forKey:key];
}

- (UIImage *)snapshotOfUnderlyingView
{
    __strong CustomAnimationViewLayer *blurLayer = [self blurPresentationLayer];
    __strong CALayer *underlyingLayer = [self underlyingLayer];
    CGRect bounds = [blurLayer convertRect:blurLayer.bounds toLayer:underlyingLayer];
    
    self.lastUpdate = [NSDate date];
    CGFloat scale = 0.5;
    if (self.iterations)
    {
        CGFloat blockSize = 12.0f/self.iterations;
        scale = blockSize/MAX(blockSize * 2, blurLayer.blurRadius);
        scale = 1.0f/floorf(1.0f/scale);
    }
    CGSize size = bounds.size;
    if (self.contentMode == UIViewContentModeScaleToFill ||
        self.contentMode == UIViewContentModeScaleAspectFill ||
        self.contentMode == UIViewContentModeScaleAspectFit ||
        self.contentMode == UIViewContentModeRedraw)
    {
        //prevents edge artefacts
        size.width = floorf(size.width * scale) / scale;
        size.height = floorf(size.height * scale) / scale;
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f && [UIScreen mainScreen].scale == 1.0f)
    {
        //prevents pixelation on old devices
        scale = 1.0f;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, -bounds.origin.x, -bounds.origin.y);
    
    NSArray *hiddenViews = [self prepareUnderlyingViewForSnapshot];
    [underlyingLayer renderInContext:context];
    [self restoreSuperviewAfterSnapshot:hiddenViews];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
}

- (NSArray *)prepareUnderlyingViewForSnapshot
{
    __strong CALayer *blurlayer = [self blurLayer];
    __strong CALayer *underlyingLayer = [self underlyingLayer];
    while (blurlayer.superlayer && blurlayer.superlayer != underlyingLayer)
    {
        blurlayer = blurlayer.superlayer;
    }
    NSMutableArray *layers = [NSMutableArray array];
    NSUInteger index = [underlyingLayer.sublayers indexOfObject:blurlayer];
    if (index != NSNotFound)
    {
        for (NSUInteger i = index; i < [underlyingLayer.sublayers count]; i++)
        {
            CALayer *layer = underlyingLayer.sublayers[i];
            if (!layer.hidden)
            {
                layer.hidden = YES;
                [layers addObject:layer];
            }
        }
    }
    return layers;
}

- (void)restoreSuperviewAfterSnapshot:(NSArray *)hiddenLayers
{
    for (CALayer *layer in hiddenLayers)
    {
        layer.hidden = NO;
    }
}

- (UIImage *)blurredSnapshot:(UIImage *)snapshot radius:(CGFloat)blurRadius
{
    return [snapshot blurredImageWithRadius:blurRadius
                                 iterations:self.iterations
                                  tintColor:self.tintColor];
}

- (void)setLayerContents:(UIImage *)image
{
    self.layer.contents = (id)image.CGImage;
    self.layer.contentsScale = image.scale;
}

- (void)updateAsynchronously:(BOOL)async completion:(void (^)())completion
{
    if ([self shouldUpdate])
    {
        UIImage *snapshot = [self snapshotOfUnderlyingView];
        if (async)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                UIImage *blurredImage = [self blurredSnapshot:snapshot radius:self.blurRadius];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    [self setLayerContents:blurredImage];
                    if (completion) completion();
                });
            });
        }
        else
        {
            [self setLayerContents:[self blurredSnapshot:snapshot radius:[self blurPresentationLayer].blurRadius]];
            if (completion) completion();
        }
    }
    else if (completion)
    {
        completion();
    }
}
@end
