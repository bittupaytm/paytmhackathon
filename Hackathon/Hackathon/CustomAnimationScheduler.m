//
//  CustomAnimationScheduler.m
//  Hackathon
//
//  Created by Sudeep Unnikrishnan on 20/01/16.
//  Copyright © 2016 Paytm. All rights reserved.
//

#import "CustomAnimationScheduler.h"

@implementation CustomAnimationScheduler

+ (instancetype)sharedInstance
{
    static CustomAnimationScheduler *sharedInstance = nil;
    if (!sharedInstance)
    {
        sharedInstance = [[CustomAnimationScheduler alloc] init];
    }
    return sharedInstance;
}

- (instancetype)init
{
    if ((self = [super init]))
    {
        _updatesEnabled = 1;
        _blurEnabled = YES;
        _views = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)setBlurEnabled:(BOOL)blurEnabled
{
    _blurEnabled = blurEnabled;
    if (blurEnabled)
    {
        for (CustomAnimationView *view in self.views)
        {
            [view setNeedsDisplay];
        }
        [self updateAsynchronously];
    }
}

- (void)setUpdatesEnabled
{
    _updatesEnabled ++;
    [self updateAsynchronously];
}

- (void)setUpdatesDisabled
{
    _updatesEnabled --;
}

- (void)addView:(CustomAnimationView *)view
{
    if (![self.views containsObject:view])
    {
        [self.views addObject:view];
        [self updateAsynchronously];
    }
}

- (void)removeView:(CustomAnimationView *)view
{
    NSUInteger index = [self.views indexOfObject:view];
    if (index != NSNotFound)
    {
        if (index <= self.viewIndex)
        {
            self.viewIndex --;
        }
        [self.views removeObjectAtIndex:index];
    }
}

- (void)updateAsynchronously
{
    if (self.blurEnabled && !self.updating && self.updatesEnabled > 0 && [self.views count])
    {
        NSTimeInterval timeUntilNextUpdate = 1.0 / 60;
        
        //loop through until we find a view that's ready to be drawn
        self.viewIndex = self.viewIndex % [self.views count];
        for (NSUInteger i = self.viewIndex; i < [self.views count]; i++)
        {
            CustomAnimationView *view = self.views[i];
            if (view.dynamic && !view.hidden && view.window && [view shouldUpdate])
            {
                NSTimeInterval nextUpdate = [view.lastUpdate timeIntervalSinceNow] + view.updateInterval;
                if (!view.lastUpdate || nextUpdate <= 0)
                {
                    self.updating = YES;
                    [view updateAsynchronously:YES completion:^{
                        
                        //render next view
                        self.updating = NO;
                        self.viewIndex = i + 1;
                        [self updateAsynchronously];
                    }];
                    return;
                }
                else
                {
                    timeUntilNextUpdate = MIN(timeUntilNextUpdate, nextUpdate);
                }
            }
        }
        
        //try again, delaying until the time when the next view needs an update.
        self.viewIndex = 0;
        [self performSelector:@selector(updateAsynchronously)
                   withObject:nil
                   afterDelay:timeUntilNextUpdate
                      inModes:@[NSDefaultRunLoopMode, UITrackingRunLoopMode]];
    }
}


@end
