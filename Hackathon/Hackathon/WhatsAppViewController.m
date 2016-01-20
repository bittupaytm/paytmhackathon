//
//  WhatsAppViewController.m
//  Hackathon
//
//  Created by Bittu Davis on 20/01/16.
//  Copyright © 2016 Paytm. All rights reserved.
//

#import "WhatsAppViewController.h"

@interface WhatsAppViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *animatedView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIView *alphaView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) float count;
@end

#define PREFERRED_HEADER_HEIGHT 330
#define TEXT_ANIMATION_START 300
@implementation WhatsAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WhatsApp";
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.navigationController setNavigationBarHidden:YES];
    [self.tableView setContentInset:UIEdgeInsetsMake(self.animatedView.bounds.size.height, 0, 0, 0)];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    
    float headerImageYOffset = 88 + self.animatedView.bounds.size.height - self.view.bounds.size.height;
    CGRect headerImageFrame = _animatedView.frame;
    headerImageFrame.origin.y = headerImageYOffset;
    
    [self.alphaView setAlpha:0.f];
    [self.imageView setAlpha:1.0f];
    self.count = 0.0f;
    [self.titleLabel setAdjustsFontSizeToFitWidth:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- TableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellIdentifier = @"Cell";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil==cell) {
        cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = @"Hello";
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat scrollOffset = -scrollView.contentOffset.y;
    CGFloat yPos = scrollOffset -_animatedView.bounds.size.height;

    CGFloat stoppableHeight = _animatedView.bounds.size.height-yPos;
    
    float alpha=1.0-(-yPos/ _animatedView.frame.size.height);
    self.imageView.alpha=alpha;
    
    [self.alphaView setAlpha:(-yPos/ _animatedView.frame.size.height)];
    
    [self animateLabelWithPosition:yPos withStoppableHeight:stoppableHeight];
    
    if (stoppableHeight>=PREFERRED_HEADER_HEIGHT) {
        return;
    }
    _animatedView.frame = CGRectMake(0, yPos, _animatedView.frame.size.width, _animatedView.frame.size.height);

}


- (void)animateLabelWithPosition:(float)yPosition withStoppableHeight:(float)stoppableHeight
{
    CGFloat yPos = -yPosition;
    if (yPos>=120) {
        CGRect newFrame = self.titleLabel.frame;
        CGFloat xAxis = newFrame.origin.x+2;
        if (xAxis>=50) {
            return;
        }
        newFrame.origin.x = xAxis;
        self.titleLabel.frame = newFrame;
    }
    else
    {
        CGRect newFrame = self.titleLabel.frame;
        CGFloat xAxis = newFrame.origin.x-2;
        if (xAxis<10) {
            return;
        }
        newFrame.origin.x = xAxis;
        self.titleLabel.frame = newFrame;
    }
    
}
@end
