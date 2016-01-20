//
//  TwitterViewController.m
//  Hackathon
//
//  Created by Bittu Davis on 20/01/16.
//  Copyright © 2016 Paytm. All rights reserved.
//




#import "TwitterViewController.h"
#import "UIImage+CustomAnimationView.h"

CGFloat headerStopOffset = 40;
CGFloat headerLabelOffset = 95;
CGFloat headerLabelDistance = 35;


@interface TwitterViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabelHeader;
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *composeButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIView *scrollViewAdjuster;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (strong , nonatomic) UIImageView *headerBlurredView;
@end

@implementation TwitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Twitter";
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController setHidesBarsOnTap:YES];
    self.navigationController.hidesBarsOnSwipe = YES;
    _scrollView.delegate = self;
    
    self.profileImageView.layer.cornerRadius = 10.0;
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.borderWidth = 3.0;

    // Do any additional setup after loading the view from its nib.
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _headerBlurredView = [[UIImageView alloc] initWithFrame:_headerView.bounds];
    _headerBlurredView.image = [[UIImage imageNamed:@"header.jpeg"] imageBlurWithWidth:10 iterations:20 tintColor:[UIColor clearColor]];
    _headerBlurredView.contentMode = UIViewContentModeScaleAspectFill;
    _headerBlurredView.alpha = 0.0;
    [_headerView insertSubview:_headerBlurredView belowSubview:_nameLabelHeader];
    _headerView.clipsToBounds = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat scrollOffset = scrollView.contentOffset.y;
    
    CATransform3D profileImageTransform = CATransform3DIdentity;
    CATransform3D headerViewTransform = CATransform3DIdentity;
    
    if(scrollOffset < 0){
        CGFloat headerViewScale = -(scrollOffset) / _headerView.bounds.size.height;
        CGFloat headerViewSizeChange = ((_headerView.bounds.size.height * (1.0 + headerViewScale)) - _headerView.bounds.size.height)/2.0;
        
        headerViewTransform = CATransform3DTranslate(headerViewTransform, 0, headerViewSizeChange, 0);
        headerViewTransform = CATransform3DScale(headerViewTransform, 1.0 + headerViewScale, 1.0 + headerViewScale, 0);
        
        _headerView.layer.transform = headerViewTransform;
        
    }
    
    else
    {
        headerViewTransform = CATransform3DTranslate(headerViewTransform, 0, MAX(-headerStopOffset,-scrollOffset), 0);
        
        CATransform3D headerLabelTransform = CATransform3DMakeTranslation(0, MAX(-headerLabelDistance,headerLabelOffset-scrollOffset), 0);
        
        
        _nameLabelHeader.layer.transform = headerLabelTransform;
        
        //  ------------ Blur
        
        _headerBlurredView.alpha = MIN (1.0, (scrollOffset - headerLabelOffset)/headerLabelDistance);
        
        // Avatar -----------
        
        CGFloat profileImageScale = (MIN(headerStopOffset, scrollOffset)) / _profileImageView.bounds.size.height / 1.4 ;// Slow down the animation
        CGFloat profileImageSizeChange = ((_profileImageView.bounds.size.height * (1.0 + profileImageScale)) - _profileImageView.bounds.size.height) / 2.0;
        
        profileImageTransform = CATransform3DTranslate(profileImageTransform, 0, profileImageSizeChange, 0);
        profileImageTransform = CATransform3DScale(profileImageTransform, 1.0 - profileImageScale, 1.0 - profileImageScale, 0);
        
        if(scrollOffset <= headerStopOffset) {
            
            if(_profileImageView.layer.zPosition < _headerView.layer.zPosition){
                _headerView.layer.zPosition = 0;
            }
            
        }else {
            if (_profileImageView.layer.zPosition >= _headerView.layer.zPosition){
                _headerView.layer.zPosition = 2;
            }
        }
    }
    
    // Apply Transformations
    
    _headerView.layer.transform = headerViewTransform;
    _profileImageView.layer.transform = profileImageTransform;
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
