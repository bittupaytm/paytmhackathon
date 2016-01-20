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
@property (weak, nonatomic) IBOutlet UIView *labelContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)backButtonClicked:(id)sender;
@end

#define PREFERRED_HEADER_HEIGHT 420
#define TEXT_ANIMATION_START 120
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
    [self setupThisView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- TableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5.0f;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Section: %d",section+1];
}

#pragma mark- UITablewView Delegate (UIScrollView)
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
    if (yPos>=TEXT_ANIMATION_START)
    {
        [self moveLabelToRightSide];
    }
    else
    {
        [self moveLabelToOriginalSide];
    }
    
}

#pragma mark- Helper Methods

- (void)moveLabelToRightSide
{
    CGRect newFrame = self.labelContainerView.frame;
    CGFloat xAxis = newFrame.origin.x+2;
    if (xAxis>=50) {
        return;
    }
    newFrame.origin.x = xAxis;
    self.labelContainerView.frame = newFrame;
}

- (void)moveLabelToOriginalSide
{
    CGRect newFrame = self.labelContainerView.frame;
    CGFloat xAxis = newFrame.origin.x-2;
    if (xAxis<10) {
        xAxis = 0;
    }
    newFrame.origin.x = xAxis;
    self.labelContainerView.frame = newFrame;
}

- (void)setupThisView
{
    [self setUpTableViewOffsets];
    [self setupImageViewAspects];
    [self setupAlphaSettingsForViewAndImageView];
}

- (void)setUpTableViewOffsets
{
    [self.tableView setContentInset:UIEdgeInsetsMake(self.animatedView.bounds.size.height, 0, 0, 0)];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
}

- (void)setupImageViewAspects
{
    float headerImageYOffset = 88 + self.animatedView.bounds.size.height - self.view.bounds.size.height;
    CGRect headerImageFrame = _animatedView.frame;
    headerImageFrame.origin.y = headerImageYOffset;
}

- (void)setupAlphaSettingsForViewAndImageView
{
    [self.alphaView setAlpha:0.f];
    [self.imageView setAlpha:1.0f];
    [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
}

#pragma mark- Button Actions
- (IBAction)backButtonClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
