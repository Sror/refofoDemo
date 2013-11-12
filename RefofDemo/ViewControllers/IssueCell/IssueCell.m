//
//  IssueCell.m
//  Safahat Reader
//
//  Created by Marwa Aman on 8/22/13.
//  Copyright (c) 2013 Ahmed Aly. All rights reserved.
//

#import "IssueCell.h"
#import "UIDevice.h"
#import "UsageData.h"


@implementation IssueCell




@synthesize thumbnail;
@synthesize progressView,downloadedImage,indicatorView,deleteButton,cellView, cellTitle;
#pragma mark - View Lifecycle

- (NSString *)reuseIdentifier
{
    return @"IssueCell";
}
- (id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateHighlighted];
    
    
    if([UIDevice deviceType] == iPad || [UIDevice deviceType]==iPadRetina)
    {
        
        self.cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 172, 216)];
        self.indicatorView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(71, 91, 20, 20)];
        self.thumbnail = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 162, 216)] autorelease];
        
        self.cellTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 200, 150, 50)];
        self.cellTitle.textAlignment = NSTextAlignmentCenter;
        self.cellTitle.backgroundColor = [UIColor clearColor];
        self.cellTitle.textColor = [UIColor whiteColor];

        self.downloadedImage = [[[UIImageView alloc] initWithFrame:CGRectMake(9, 4, 32, 22)] autorelease];
        if([UsageData getiOSVersion] >= 7)
           self.progressView=[[UIProgressView alloc] initWithFrame:CGRectMake(17, 202, 138, 9)];
        else
            self.progressView=[[UIProgressView alloc] initWithFrame:CGRectMake(17, 197, 138, 9)];

        deleteButton.frame = CGRectMake(1, -4, 42, 42);
    }
    
    else
    {
        self.cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 152, 213)];
        self.indicatorView=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(71, 91, 20, 20)];
        self.thumbnail = [[[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 142, 213)] autorelease];
        self.downloadedImage = [[[UIImageView alloc] initWithFrame:CGRectMake(9, 4, 32, 22)] autorelease];
            if([UsageData getiOSVersion] >= 7)
        self.progressView=[[UIProgressView alloc] initWithFrame:CGRectMake(17, 199, 118, 9)];
        else
            self.progressView=[[UIProgressView alloc] initWithFrame:CGRectMake(17, 194, 118, 9)];
        deleteButton.frame = CGRectMake(1, -4, 42, 42);
        [deleteButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
    }
     
     indicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleWhiteLarge;
     indicatorView.color=[UIColor blackColor];
     [self.indicatorView stopAnimating];
     self.indicatorView.hidden=YES;
     
     
     
     self.thumbnail.opaque = YES;
     
     
     [self.downloadedImage setImage:[UIImage imageNamed:@"Cloud@2x~ipad.png"]];
     self.downloadedImage.opaque = YES;
     self.downloadedImage.hidden=YES;
     self.downloadedImage.tag=1;
     
     
     // [self.progressView set]
  
     
     // progressView.transform =  CGAffineTransformMakeRotation(3.14);
    

    
     self.progressView.tag=2;
     self.progressView.hidden=YES;
     
     
     
     self.deleteButton.tag = 4 ;
     [deleteButton setImage:[UIImage imageNamed:@"Delete.png"] forState:UIControlStateNormal];
     deleteButton.hidden = YES ;
     
     [self.contentView addSubview:self.cellView];
     
     [self.cellView addSubview:self.indicatorView];
     [self.cellView addSubview:self.thumbnail];
     [self.cellView addSubview:self.cellTitle];
     [self.cellView addSubview:self.progressView];
     [self.cellView addSubview:self.downloadedImage];
     [self.cellView addSubview:self.indicatorView];
    
     
     [self.thumbnail release];
     [self.cellTitle release];
     [self.downloadedImage release];
     [self.progressView release];
     //[self.deleteButton release];
     [self.cellView release];
     [self.indicatorView release];
     
     [self.cellView addSubview:self.deleteButton];
     self.backgroundColor = [UIColor colorWithRed:0 green:0.40784314 blue:0.21568627 alpha:1.0];
     self.selectedBackgroundView = [[[UIView alloc] initWithFrame:self.thumbnail.frame] autorelease];
     
     self.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
     
     
     [self bringSubviewToFront:deleteButton];
     [deleteButton becomeFirstResponder];
    
    
    if([UsageData getiOSVersion] >= 7)
    {
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.44f);
        self.progressView.transform = CGAffineTransformRotate(transform, 3.14);
    }
    
    else
        self.progressView.transform = CGAffineTransformMakeScale(1.0f, 3.5f);
    
     return self;
}


#pragma mark - Memory Management

- (void)dealloc
{
    self.thumbnail = nil;
    self.downloadedImage=nil;
    self.progressView=nil;
    self.deleteButton = nil ;
    self.cellView =nil;
    [super dealloc];
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
