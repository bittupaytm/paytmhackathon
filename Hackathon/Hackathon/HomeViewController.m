//
//  HomeViewController.m
//  Hackathon
//
//  Created by Bittu Davis on 20/01/16.
//  Copyright © 2016 Paytm. All rights reserved.
//

#import "HomeViewController.h"
#import "TwitterViewController.h"
#import "WhatsAppViewController.h"

@interface HomeViewController ()
- (IBAction)twitterButtonClicked:(id)sender;
- (IBAction)watsappButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *whatsAppButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self setupThisView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions
- (IBAction)twitterButtonClicked:(id)sender
{
    [self showTwitterView];
}

- (IBAction)watsappButtonClicked:(id)sender
{
    [self showWatsAppView];
}

#pragma mark Helper Methods
- (void)showTwitterView
{
    TwitterViewController *twitterViewController = [[TwitterViewController alloc]initWithNibName:@"TwitterViewController" bundle:nil];
    [self.navigationController pushViewController:twitterViewController animated:YES];
}

- (void)showWatsAppView
{
    WhatsAppViewController *whatsAppController = [[WhatsAppViewController alloc]initWithNibName:@"WhatsAppViewController" bundle:nil];
    [self.navigationController pushViewController:whatsAppController animated:YES];
    
}

- (void)setupThisView
{
    [self decorateButton:self.whatsAppButton];
    [self decorateButton:self.twitterButton];
    self.imageView.layer.cornerRadius = 5.0f;
}

- (void)decorateButton:(UIView *)view
{
    view.layer.cornerRadius = 5.0f;
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 2.0f;
}
@end
