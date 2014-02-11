//
//  MainView.m
//  Eting_IOS
//
//  Created by Rangken on 2014. 1. 1..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import "MainView.h"
#import "MainViewController.h"
#import "StoryManager.h"
#import "StampViewController.h"
#import "AppDelegate.h"
#import "AFAppDotNetAPIClient.h"
#import <FSExtendedAlertKit.h>
#import "MBProgressHUD.h"
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
@implementation MainView
- (id) initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        return self;
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
}
- (void)layoutSubviews{
    [super layoutSubviews];
}
- (void)runAnimation{
    [self earthquake:_spaceShipView];
    [self runSpinAnimationOnView:_earthImgView duration:25.0f rotations:1.0f repeat:INFINITY];
}
- (void)refreshView{
    NSCalendar *calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *date = [NSDate date];//datapicker date
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:date];
    
    NSInteger year = [dateComponents year];
    NSInteger month = [dateComponents month];
    NSInteger day = [dateComponents day];
    _dateLabel.text = [NSString stringWithFormat:@"%li. %02li. %02li",(long)year,(long)month, (long)day];
    NSMutableArray* storyArr = [[StoryManager sharedSingleton] getStorys];
    _etingCountLabel.text = [NSString stringWithFormat:@"%lu eting",(unsigned long)[storyArr count]];
    NSMutableArray* stampArr = [[StoryManager sharedSingleton] getStamps];
    _stampCountLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)[stampArr count]];
    
    [UIView animateWithDuration:0.5 animations:^{
        if ([stampArr count] != 0) {
            [_spaceShipView setAlpha:1.0f];
            [_spaceShipView setHidden:FALSE];
            [_starBtn setHidden:TRUE];
        }else{
            [_spaceShipView setAlpha:0.0f];
            [_starBtn setHidden:FALSE];
        }
    } completion:^(BOOL finished) {
        
    }];
    
}

- (IBAction)stampClick:(id)sender{
    NSMutableArray* stampArr = [[StoryManager sharedSingleton] getStamps];
    if ([stampArr count] != 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        StampViewController* viewCont = [storyboard instantiateViewControllerWithIdentifier:@"StampViewController"];
        //viewCont.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        viewCont.view.backgroundColor = [UIColor clearColor];
        self.parentViewCont.modalPresentationStyle = UIModalPresentationCurrentContext;
        viewCont.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.parentViewCont presentViewController:viewCont animated:YES completion:nil];
    }
    
}
- (IBAction)etingClick:(id)sender{
    if (!self.parentViewCont.scrollView.isDragging) {
        [self.parentViewCont.scrollView setContentOffset:CGPointMake(640, 0) animated:TRUE];
    }
    
}

- (IBAction)listClick:(id)sender{
    if (!self.parentViewCont.scrollView.isDragging) {
        [self.parentViewCont.scrollView setContentOffset:CGPointMake(0, 0) animated:TRUE];
    }
}
- (IBAction)settingClick:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UIViewController* viewCont = [storyboard instantiateViewControllerWithIdentifier:@"SettingViewController"];
    viewCont.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.parentViewCont presentViewController:viewCont animated:TRUE completion:NULL];
}
- (IBAction)starClick:(id)sender{
    NSString *uuidStr = [[AFAppDotNetAPIClient sharedClient] deviceUUID];
    
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:uuidStr,@"phone_id", nil];
    [MBProgressHUD showHUDAddedTo:self animated:YES];
    [[AFAppDotNetAPIClient sharedClient] postPath:@"eting/getRandomStory" parameters:parameters success:^(AFHTTPRequestOperation *response, id responseObject) {
        
        NSLog(@"eting/getRandomStory: %@",(NSDictionary *)responseObject);
        NSDictionary* saveReceiveDic = [responseObject objectForKey:@"recievedStory"];
        if (saveReceiveDic != NULL) {
            [[StoryManager sharedSingleton] saveStamp:saveReceiveDic];
        }
        [_starBtn setHidden:TRUE];
        [self refreshView];
        NSTimer *timer = [NSTimer timerWithTimeInterval:60*5 target:self selector:@selector(resetStarBtn:) userInfo:nil repeats:FALSE];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [MBProgressHUD hideHUDForView:self animated:YES];
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        [_starBtn setHidden:TRUE];
        NSTimer *timer = [NSTimer timerWithTimeInterval:60*5 target:self selector:@selector(resetStarBtn:) userInfo:nil repeats:FALSE];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [MBProgressHUD hideHUDForView:self animated:YES];
    }];

}
- (void)resetStarBtn:(id)sender{
    [_starBtn setHidden:FALSE];
}
#pragma mark BaseViewDelegate
- (void)viewDidSlide{
    NSMutableArray* stampArr = [[StoryManager sharedSingleton] getStamps];
    if ([stampArr count] != 0) {
        [_spaceShipView setHidden:FALSE];
    }else{
        [_spaceShipView setHidden:TRUE];
        [self earthquake:_spaceShipView];
    }
    [self.parentViewCont.writeView.textView resignFirstResponder];
    [self refreshView];
}

- (void)viewUnSilde{
    
}



- (void)earthquake:(UIView*)itemView
{
    CGFloat t = 1.0;
    
    CGAffineTransform leftQuake  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, -t);
    CGAffineTransform rightQuake = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, t);
    
    itemView.transform = leftQuake;  // starting point
    
    [UIView beginAnimations:@"earthquake" context:(__bridge void *)(itemView)];
    [UIView setAnimationRepeatAutoreverses:YES]; // important
    [UIView setAnimationRepeatCount:INFINITY];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(earthquakeEnded:finished:context:)];
    
    itemView.transform = rightQuake; // end here & auto-reverse
    
    [UIView commitAnimations];
}

- (void)earthquakeEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue])
    {
    	UIView* item = (__bridge UIView *)context;
    	item.transform = CGAffineTransformIdentity;
    }
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
- (void)flashOff:(UIView *)v
{
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = .01;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        [self flashOn:v];
    }];
}

- (void)flashOn:(UIView *)v
{
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = 1;
    } completion:^(BOOL finished) {
        [self flashOff:v];
    }];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self runAnimation];
    //[self flashOn:_starBtn];
    [self refreshView];
    
    
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    rotationTransform = CGAffineTransformRotate(rotationTransform, DEGREES_TO_RADIANS(30));
    _stampCountLabel.transform = rotationTransform;
    
    if ([[UIScreen mainScreen] bounds].size.height == 480) {
        int deltaY = 50;
        [_etingBtn setFrame:CGRectMake(_etingBtn.frame.origin.x, _etingBtn.frame.origin.y-deltaY, _etingBtn.frame.size.width, _etingBtn.frame.size.height)];
        [_etingTextImgView setFrame:CGRectMake(_etingTextImgView.frame.origin.x, _etingTextImgView.frame.origin.y-deltaY, _etingTextImgView.frame.size.width, _etingTextImgView.frame.size.height)];
        [_planetImgView setFrame:CGRectMake(_planetImgView.frame.origin.x, _planetImgView.frame.origin.y-deltaY, _planetImgView.frame.size.width, _planetImgView.frame.size.height)];
    }
}


@end
