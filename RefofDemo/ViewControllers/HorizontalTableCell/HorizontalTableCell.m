//
//  HorizontalTableCell.m
//  Safahat Reader
//
//  Created by Marwa Aman on 8/22/13.
//  Copyright (c) 2013 Ahmed Aly. All rights reserved.
//

#import "HorizontalTableCell.h"
#import "IssueCell.h"
#import "UserDefaults.h"
#import "Constants.h"
#import "CacheManager.h"
#import "UIImageView+AFNetworking.h"
//#import "ArticleViewController.h"
#import "UIDevice.h"
#import "NetworkService.h"
#import "CustomWebView.h"
#import "UsageData.h"
#define degreesToRadians(x) (M_PI * (x) / 180.0)
#define kAnimationRotateDeg 0.5
#define kAnimationTranslateX 1
#define kAnimationTranslateY 1

@implementation HorizontalTableCell


@synthesize issuesContents,horizontalTableView,viewController,articlesArray, cellTitle; //articlesStillDownloading,
@synthesize delegate ;

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




- (id)initWithIsLastCategory:(BOOL)isLastCategory
{
    if ((self = [super init]))
    {
        
        
        if([UIDevice deviceType]==iPadRetina || [UIDevice deviceType] == iPad)
        {
            self.horizontalTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 240, 768)] autorelease];
            self.horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
            [self.horizontalTableView setFrame:CGRectMake(0, 0, 763, 240)];
            self.horizontalTableView.rowHeight = 162+24;
            self.horizontalTableView.sectionHeaderHeight = 10 ;
            [self.horizontalTableView setContentInset:UIEdgeInsetsMake(24, 0, 0, 0)] ;
            
            sectionSize = 4 ;
        }
        
        
        else
        {
            self.horizontalTableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 225, 320)] autorelease];
            self.horizontalTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
            [self.horizontalTableView setFrame:CGRectMake(0, 0, 315, 225)];
            self.horizontalTableView.rowHeight = 142+12;
            self.horizontalTableView.sectionHeaderHeight = 10 ;
            [self.horizontalTableView setContentInset:UIEdgeInsetsMake(12, 0, 0, 0)] ;
            
            sectionSize = 2 ;
        }
        
        
        self.horizontalTableView.showsVerticalScrollIndicator = NO;
        self.horizontalTableView.showsHorizontalScrollIndicator = NO;
        
        self.horizontalTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.horizontalTableView.separatorColor = [UIColor clearColor];
        
        self.horizontalTableView.backgroundColor=[UIColor clearColor];
        self.horizontalTableView.dataSource = self;
        self.horizontalTableView.delegate = self;
        
        self.horizontalTableView.scrollEnabled = false ;
        
        [self addSubview:self.horizontalTableView];
        shaking = NO ;
        isDeleted = NO ;
        
        // articlesStillDownloading = [[[NSMutableArray alloc] init] retain];
    }
    
    
    
    return self;
}


// --------------------------------------------------------------Shake Animation----------------------------------------------------------------------------------------------


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


-(IBAction)askForDeleteIssue:(UISwipeGestureRecognizer *)sender{
    
    IssueCell *cell =(IssueCell *)[sender view] ;
    NSIndexPath *indexPath = [self.horizontalTableView indexPathForCell:cell ];
    int index = sectionSize-1-indexPath.row;
    if(![self isIssueDownloaded:(NSString *)[[self.issuesContents objectAtIndex:index] objectForKey:@"issue.id"]])
        return ;
    
    [self.delegate shakeCell];
}



-(void)longPressAction:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        IssueCell *cell =(IssueCell *)[sender view]  ;
        NSIndexPath *indexPath = [self.horizontalTableView indexPathForCell:cell ];
        int index = sectionSize-1-indexPath.row;
        if(![self isIssueDownloaded:(NSString *)[[self.issuesContents objectAtIndex:index] objectForKey:@"issue.id"]])
            return ;
        [self.delegate shakeCell];
    }
}


-(void)deleteButtonPressed:(UIButton *)sender
{
    IssueCell *cell ;
    if([UsageData getiOSVersion] >= 7 )
       cell = (IssueCell *)[[[[sender superview] superview] superview] superview];
    
    else
        cell = (IssueCell *)[[[sender superview] superview] superview];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"هل ترغب في حذف هذا العدد" delegate:self cancelButtonTitle:@"لا" otherButtonTitles:@"نعم",nil];
    NSIndexPath *indexPath = [self.horizontalTableView indexPathForCell:cell ];
    
    alertView.tag=indexPath.row;
    [alertView show];
    [alertView release];
    isDeleted = YES ;
    //
    
}


-(void)shakeAnimation
{
    shaking = YES ;
    
    
    NSArray *cellArray =[self.horizontalTableView visibleCells] ;
    for(int i = 0 ; i < cellArray.count ; i++ )
    {
        IssueCell *cell = [cellArray objectAtIndex:i];
        if(cell.downloadedImage.hidden && cell.progressView.hidden)
        {
            int count = 1;
            cell.deleteButton.hidden = NO ;
            [cell.deleteButton setSelected:NO];
            
            [cell bringSubviewToFront:cell.deleteButton];
            cell.transform = CGAffineTransformMakeRotation(M_PI * 0.5 );
            
            CGAffineTransform leftWobble =  CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? 1 :-1 ) ));
            CGAffineTransform rightWobble = CGAffineTransformMakeRotation(degreesToRadians( kAnimationRotateDeg * (count%2 ? -1 : 1 ) ));
            CGAffineTransform moveTransform =  CGAffineTransformTranslate(rightWobble, -kAnimationTranslateX, -kAnimationTranslateY);
            CGAffineTransform conCatTransform =  CGAffineTransformConcat(rightWobble,moveTransform);
            
            cell.cellView.transform = CGAffineTransformIdentity ;
            [cell.cellView.layer removeAllAnimations];
            cell.cellView.transform = leftWobble  ;
            
            
            
            [UIView animateWithDuration:0.13
                                  delay:(count*i * 0.04)
                                options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionRepeat |UIViewAnimationOptionAutoreverse
                             animations:^{
                                 cell.cellView.transform = conCatTransform ;
                             }
                             completion:nil];
        }
        
    }
}


-(void)stopShaking
{
    shaking = NO ;
    NSArray *cellArray =[self.horizontalTableView visibleCells] ;
    
    for(int i = 0 ; i < cellArray.count ; i++ )
    {
        IssueCell *cell = [cellArray objectAtIndex:i];
        [cell.cellView.layer removeAllAnimations];
        cell.cellView.transform = CGAffineTransformIdentity;
        cell.deleteButton.hidden = YES ;
    }
}




#pragma tableView setup

// --------------------------------------------------------------TableView SetUp----------------------------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.issuesContents count]< sectionSize) {
        isLessThan4=YES;
        tableView.scrollEnabled=NO;
        return sectionSize;
    }
    return [self.issuesContents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookCell";
    
    IssueCell *cell = (IssueCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[IssueCell alloc] init] autorelease];
        
    }
    
    if(sectionSize-indexPath.row <=[self.issuesContents count])
    {
        dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(concurrentQueue, ^{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.downloadedImage.hidden=YES;
                cell.progressView.hidden=YES;
                cell.userInteractionEnabled=YES;
                cell.indicatorView.hidden=YES;
                
                
                
                int cellIndex = sectionSize-1-indexPath.row ;
                
                cell.cellTitle.text = [[issuesContents objectAtIndex:cellIndex] valueForKey:@"name"];
                [cell.thumbnail setImage:[UIImage imageNamed:[[issuesContents objectAtIndex:cellIndex] valueForKey:@"image"]]];
                /*NSString *thumbName=[NSString stringWithFormat:@"%@",[[self.issuesFileNamesArray objectAtIndex:cellIndex] objectForKey:@"issue.thumb.url"]];
                NSData *thumbImg=[CacheManager getDataWithName:[NSString stringWithFormat:@"%@t%@",[[self.issuesFileNamesArray objectAtIndex:cellIndex] objectForKey:@"image.lastmodified.date"],[[thumbName componentsSeparatedByString:@"/"] lastObject]] inRelativePath:@"Thumbnail"];
                if (thumbImg) {
                    [cell.thumbnail setImage:[UIImage imageWithData:thumbImg]];
                }
                else
                    [cell.thumbnail setImageWithURL:[NSURL URLWithString:thumbName] Date:[[self.issuesFileNamesArray objectAtIndex:cellIndex] objectForKey:@"image.lastmodified.date"]];
                
                cell.cellTitle = self.cellTitle;
                
                [cell.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                
               
               
                
                if([UsageData getiOSVersion] >= 7)
                {
                      // cell.progressView.frame = CGRectMake(cell.progressView.frame.origin.x, cell.progressView.frame.origin.y + 7, cell.progressView.frame.size.width, cell.progressView.frame.size.height);
                    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.5f);
                    cell.progressView.transform = CGAffineTransformRotate(transform, 3.14);
                 

                }
                
                else
                 cell.progressView.transform =  CGAffineTransformMakeRotation(3.14);
                
                                NSString *issueNumber = [[self.issuesFileNamesArray objectAtIndex:cellIndex] objectForKey:@"issue.id"];
                BOOL isDownloading=NO;
                float progressRate=0.0;
               
                
  
                if (!isDownloading) {
                    
                    if([self isIssueDownloaded:issueNumber])
                    {
                        cell.downloadedImage.hidden = YES ;
                    }
                    else
                    {
                        cell.downloadedImage.hidden = NO ;
                    }
                    cell.progressView.hidden = YES ;
                    
                }
                
                else{
                    [cell.progressView setProgress:progressRate];
                    cell.downloadedImage.hidden = YES ;
                    cell.downloadedImage.hidden = NO ;
                    
                }*/
                
            });
        });
         
    }
    else
        cell.hidden=YES;
    
    
    UISwipeGestureRecognizer* rightSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(askForDeleteIssue:)] autorelease];
    [rightSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    
    UISwipeGestureRecognizer* leftSwipeRecognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(askForDeleteIssue:)] autorelease];
    [leftSwipeRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    
    UILongPressGestureRecognizer *tapRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)];
    tapRecognizer.delegate = self;
    
    
    [cell addGestureRecognizer:rightSwipeRecognizer];
    [cell addGestureRecognizer:leftSwipeRecognizer];
    [cell addGestureRecognizer:tapRecognizer];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if(shaking)
    {
        shaking = NO ;
        [self.delegate stopShake];
        return ;
    }
    IssueCell *cell = (IssueCell *)[horizontalTableView cellForRowAtIndexPath:indexPath];
    [cell.deleteButton setSelected:NO];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *currentIssue=nil;
    
    currentIssue = [self.issuesContents objectAtIndex:sectionSize-1-indexPath.row];
    
    
    
    int cellIndex= sectionSize-1-indexPath.row;
    NSString *issueNumber = [[self.issuesContents objectAtIndex:cellIndex] objectForKey:@"issue.id"];
    if([self isIssueDownloaded:issueNumber])
    {
        [self read:indexPath];
    }
    
    
    
    else
    {
        if (cell.progressView.hidden == YES)
            [self DownloadBookAlert:indexPath];
    }
    
    
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor blackColor]];
    
}

// --------------------------------------------------------------Issue----------------------------------------------------------------------------------------------


-(BOOL)isIssueDownloaded:(NSString *)issueId{
    NSString *key=[NSString stringWithFormat:@"%@",issueId];
    NSDictionary *dictionaryThatCached=[UserDefaults getDictionaryWithKey:key];
    if (dictionaryThatCached) {
        NSString *isDownloaded=[dictionaryThatCached objectForKey:IS_DOWNLOADED];
        if ([isDownloaded isEqual:@"1"]) {
            return YES;
        }
    }
    return NO;
}




-(void)read:(NSIndexPath *)indexPath{
    
  /*  issueName = [[self.issuesFileNamesArray objectAtIndex:sectionSize-1-indexPath.row] objectForKey:@"issue.id"];
    NSString *issueNumnber = [[self.issuesFileNamesArray objectAtIndex:sectionSize-1-indexPath.row] objectForKey:@"issue.id"];
    
    
    NSDictionary *lastDict=[UserDefaults getDictionaryWithKey:issueNumnber];
    NSMutableArray *lastArray=[NSMutableArray arrayWithArray:[lastDict objectForKey:ARTICLES]];
    NSDictionary *cachedDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"1",IS_DOWNLOADED,lastArray,ARTICLES,@"1",IS_READ ,nil];
    
    [UserDefaults addObject:cachedDictionary withKey:[NSString stringWithFormat:@"%@",issueNumnber] ifKeyNotExists:NO];
    if([self isIssueDownloaded:issueNumnber])
    {
        NSString *plistPath = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@""] stringByAppendingPathComponent:issueNumnber ] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",issueNumnber]] ;
        
        self.articlesArray = [NSArray arrayWithContentsOfFile:plistPath];
        
    }
    
    
    ArticleViewController *AVC = [[ArticleViewController alloc]initWithNibName:@"ArticleViewController" bundle:[NSBundle mainBundle]];
    
    AVC.categoryArray = self.articlesArray ;
    AVC.issueName = issueName ;
    AVC.issueTitle= [[self.issuesFileNamesArray objectAtIndex:sectionSize-1-indexPath.row] objectForKey:@"issue.name"];
    [self.viewController.navigationController pushViewController:AVC animated:YES];
    [AVC release];*/
    
}

-(IBAction)DownloadBookAlert:(NSIndexPath *)indexPath
{
    isDeleted=NO;
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"هل ترغب في تحميل هذا العدد؟" delegate:self cancelButtonTitle:@"لا" otherButtonTitles:@"نعم",nil];
    [alertView show];
    alertView.tag=indexPath.row;
    [alertView release];
    
}

// ------------------------------------------------------------------------------------------------------------------------------------------------------------

- (void)downloadDidFinish:(ASIHTTPRequest *)request
{
    NSLog(@"eshta");
    
   // [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
}
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setTitle:@"Error"];
    [alert setMessage:@"An error occurred while downloading file, please make sure your iPad is connected to the Internet click and try again."];
    [alert setDelegate:self];
    [alert addButtonWithTitle:@"Try Again"];
    
    [alert setTag:1];
    
    [alert show];
    
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==-2) {
        if (buttonIndex == 1) {
            NSDictionary *versionDict=[UserDefaults getDictionaryWithKey:APP_STATUS];
            NSString *updatedVersionUrl=[[versionDict objectForKey:@"validation"] objectForKey:@"update.url"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updatedVersionUrl]];
        }
    }else{
        if (!isDeleted) {
            if (buttonIndex == 1){
                if ([[NetworkService getObject] checkInternetWithData])
                {
                    //       [self.articlesStillDownloading addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",[[self.issuesFileNamesArray objectAtIndex:alertView.tag] objectForKey:@"issue.id"]],@"issue.id",@"0.0",@"progress", nil]];
                    
                    //     NSLog(@"articles still downloaing %@",articlesStillDownloading);
                    
                  /*  NSIndexPath *indexPath=[NSIndexPath indexPathForRow:alertView.tag inSection:0];
                    IssueCell *cell = (IssueCell *)[horizontalTableView cellForRowAtIndexPath:indexPath];
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        
                        
                        cell.downloadedImage.hidden = YES ;
                        cell.progressView.hidden = NO ;
                        [cell.progressView setProgress:0];
                    });
                    
                    
                    NSString *downloadCount = [UserDefaults getStringWithKey:Downlaod_Count] ;
                    
                    int downloadCountNO = [downloadCount integerValue ];
                    downloadCountNO ++;
                    [UserDefaults  addObject:[NSString stringWithFormat:@"%d",downloadCountNO] withKey:Downlaod_Count ifKeyNotExists:NO];
                    
                    
                    
                    [NSThread detachNewThreadSelector:@selector(downloadIssueWithId:) toTarget:self withObject:[NSString stringWithFormat:@"%d",sectionSize-1-alertView.tag]];*/
                    
                    
                    
                    
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:alertView.tag inSection:0];
                    IssueCell *cell=(IssueCell *)[self.horizontalTableView cellForRowAtIndexPath:indexPath];
                    
                    cell.userInteractionEnabled=NO;
                    cell.progressView.hidden=NO;
                    
                    
                    
                    ASIHTTPRequest *request;
                   /* UIProgressView *theProgressView;
                    progressAlert = [[UIAlertView alloc] initWithTitle:nil  message: @"Please wait..." delegate: self cancelButtonTitle: nil otherButtonTitles: nil];
                    theProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20.0f, 100.0f, 220.0f, 9.0f)];
                    
                    [progressAlert addSubview:theProgressView];
                    [progressAlert show];
                    
                    [theProgressView setProgressViewStyle: UIProgressViewStyleBar];
                    
                    [progressAlert show];*/
                    
                    
                    
                   // NSURL *theURL;
                    
                    
                   // theURL= [NSURL URLWithString:[[issuesContents objectAtIndex:indexPath.row] valueForKey:@"url"]];
                    request = [ASIHTTPRequest requestWithURL:[[issuesContents objectAtIndex:indexPath.row-1] valueForKey:@"url"]];
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSError *error;
                    NSArray *paths = NSSearchPathForDirectoriesInDomains
                    (NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *documentsDir = [paths objectAtIndex:0];
                    NSString *tempPath = [documentsDir stringByAppendingPathComponent:@"Temp"];
                    
                    BOOL isDir;
                    
                    BOOL success;
                    
                    if (![fileManager fileExistsAtPath: tempPath isDirectory:&isDir])
                    {
                        success =  [fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:Nil error:&error];
                        if (success) {
                            NSLog(@"Success  %@",tempPath);
                            
                        }
                        else
                        {
                            
                            NSLog(@"Error   %@    %@",tempPath, [error description]);
                            
                            return;
                        }
                        
                        
                    }
                    
                    
                    
                    
                    NSString *destination = [tempPath stringByAppendingPathComponent:[[issuesContents objectAtIndex:indexPath.row-1] valueForKey:@"name"]];
                    NSString *   temporaryFileDownloadPath=[tempPath stringByAppendingPathComponent:@"myFile.pdf.download"];
                    [UIApplication sharedApplication].idleTimerDisabled=YES;
                    [request setDownloadDestinationPath:destination];
                    [request setDownloadProgressDelegate:cell.progressView];
                    
                    [request setTemporaryFileDownloadPath:temporaryFileDownloadPath];
                    [request setAllowResumeForFileDownloads:YES];
                    
                    
                    
                    
                    //  NSLog (@"dddddddd     %@" ,destination);
                    //   NSLog (@"tttttt       %@" ,temporaryFileDownloadPath);
                    
                    
                    if ([fileManager fileExistsAtPath:temporaryFileDownloadPath]) {
                        //     NSLog (@"tttttt tttttttt      %@" ,temporaryFileDownloadPath);
                        
                    }
                    
                    
                    //  [CallingIrevoColtroller.view addSubview:progressAlert];
                    
                    
                    
                   /////// [request setDownloadProgressDelegate:theProgressView];
                    
                    //   [request setStartedBlock:^{[progressAlert show];}];
                    request.showAccurateProgress=YES;
                    [request setDelegate:self];
                    
                    [request setDidFailSelector:@selector(requestFailed:)];
                    [request setDidFinishSelector:@selector(downloadDidFinish:)];
                    //  [request setDidStartSelector:@selector(downloadDidStart:)];
                    
                    
                    
                    
                    
                    [request setRequestMethod:@"GET"];
                    [request startAsynchronous];
                    
                    
                }else{
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"معذرة لا يمكنك تحميل العدد في الوقت الحالي؛ نظرًا لتعذر الاتصال بالإنترنت" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil];
                    [alertView show];
                    [alertView release];
                    // [self.horizontalTableView reloadData];
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:alertView.tag inSection:0];
                    IssueCell *cell = (IssueCell *)[horizontalTableView cellForRowAtIndexPath:indexPath];
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        
                        cell.downloadedImage.hidden = NO ;
                        cell.progressView.hidden = YES ;
                        
                        [cell.progressView setProgress:0];
                    });
                    
                    int downloadCountNO = [[UserDefaults getStringWithKey:Downlaod_Count ]  integerValue ];
                    downloadCountNO --;
                    [UserDefaults  addObject:[NSString stringWithFormat:@"%d",downloadCountNO] withKey:Downlaod_Count ifKeyNotExists:NO];
                    
                    if(downloadCountNO == 0 )
                        [self.delegate updateListDelegate];
                }
                
            }else{
                //  [self.horizontalTableView reloadData];
                
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:alertView.tag inSection:0];
                IssueCell *cell = (IssueCell *)[horizontalTableView cellForRowAtIndexPath:indexPath];
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    
                    cell.downloadedImage.hidden = NO ;
                    cell.progressView.hidden = YES ;
                    
                    [cell.progressView setProgress:0];
                });
            }
        }else{
            if (buttonIndex == 1){
                
                [NSThread detachNewThreadSelector:@selector(deleteIssueWithId:) toTarget:self withObject:[NSString stringWithFormat:@"%d",sectionSize-1-alertView.tag]];
                
                
                
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:alertView.tag inSection:0];
                IssueCell *cell = (IssueCell *)[horizontalTableView cellForRowAtIndexPath:indexPath];
                
                
                cell.deleteButton.hidden = YES ;
                // UIImageView *stateImg = (UIImageView *)[cell viewWithTag:2];
                cell.downloadedImage.hidden = NO ;
                
                [cell.cellView.layer removeAllAnimations];
                cell.cellView.transform = CGAffineTransformIdentity;
            }else{
                // [self reloadCollection];
            }
            
        }
    }
}

// --------------------------------------------------------------Delete Issue----------------------------------------------------------------------------------------------




-(void)deleteIssueWithId:(NSString *)issueId{
    
    [CacheManager deleteItemsAtPath:[NSString stringWithFormat:@"%@",[[self.issuesContents objectAtIndex:issueId.intValue] objectForKey:@"issue.id"]]];
    NSString *key=[NSString stringWithFormat:@"%@",[[self.issuesContents objectAtIndex:issueId.intValue] objectForKey:@"issue.id"]];
    [UserDefaults addObject:nil withKey:key ifKeyNotExists:NO];
    
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"deletedIssues.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *deleteBookArray ;
    
    if (![fileManager fileExistsAtPath: path])
    {
        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"deletedIssues.plist"] ];
        deleteBookArray = [[NSMutableArray alloc] init];
    }
    
    else
        deleteBookArray = [[NSMutableArray alloc] initWithContentsOfFile: path];
    //
    NSDictionary *deletedBook = [NSDictionary dictionaryWithObjectsAndKeys:[[self.issuesContents objectAtIndex:issueId.intValue] objectForKey:@"issue.id"],@"issueID",[NSDate date] ,@"Time", nil];
    [deleteBookArray addObject:deletedBook];
    [deleteBookArray writeToFile:path atomically:YES];
    [deleteBookArray release];
    
    isDeleted = NO ;
    
    
    //[self.horizontalTableView reloadData];
    
    //[self reloadCollection];
    
    
}


// --------------------------------------------------------------Downlaod Issue----------------------------------------------------------------------------------------------




-(void)downloadIssueWithId:(NSString *)issueId{
    
    
  /*  int issueNo = issueId.intValue ;
    issueId=[[self.issuesContents objectAtIndex:issueId.intValue] objectForKey:@"issue.id"];  //http://api.hindawi.org/v1/safahat/list/issue/1/articles/  best.cover.5x5/
    
    
    [UserDefaults saveData:nil withName:@"aa" inRelativePath:[NSString stringWithFormat:@"/%@",issueId] inDocument:YES];
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *folder = [[documentPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",issueId]];
    NSURL *pathURL= [NSURL fileURLWithPath:folder];
    [self addSkipBackupAttributeToItemAtURL:pathURL];
    
    BOOL isArticleDownloaded=YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    
    NSDictionary *issuedDict=nil;
    if([UIDevice deviceType]== iPad)
        issuedDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"list/issue/%@/articles/fields/title,authors,best.cover.768x1024,style.ipad/",issueId]];
    else if ([UIDevice deviceType]== iPadRetina)
        issuedDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"list/issue/%@/articles/fields/title,authors,best.cover.1536x2048,style.ipad/",issueId]];
    
    else if ([UIDevice deviceType]== iPhone)
        issuedDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"list/issue/%@/articles/fields/title,authors,best.cover.320x480,style.iphone/",issueId]];
    
    else if ([UIDevice deviceType]== iPhoneRetina)
        issuedDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"list/issue/%@/articles/fields/title,authors,best.cover.640x960,style.iphone/",issueId]];
    
    else
        issuedDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"list/issue/%@/articles/fields/title,authors,best.cover.640x1136,style.iphone/",issueId]];
    
    
    
    NSString *key=[NSString stringWithFormat:@"%@",issueId];
    
    
    NSMutableArray *articlesArrayThatCached=nil;
    NSDictionary *dictionaryThatCached=[UserDefaults getDictionaryWithKey:key];   // get issue that be saved in general plist- key& articles Array
    NSMutableArray *finalArticlesArray=[NSMutableArray array];
    id object=[[[issuedDict objectForKey:@"list"] objectForKey:@"articles"] objectForKey:@"article"];
    NSArray *currentArticlesArray=nil;
    
    if(!issuedDict)
    {
        [self downloadErrorWithIssue:issueId issueNumber:issueNo];
        return;
    }
    if ([object isKindOfClass:[NSArray class]]) {
        currentArticlesArray=[NSArray arrayWithArray:object];
    }else
        
        currentArticlesArray=[NSArray arrayWithObject:object];
    
    if ([currentArticlesArray count]==0) {
   
        //    [self.horizontalTableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            
            
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:sectionSize-1-issueNo  inSection:0];
            IssueCell *cell = (IssueCell *)[horizontalTableView cellForRowAtIndexPath:indexPath];
            
            cell.progressView.hidden = YES ;
            cell.downloadedImage.hidden = NO;
            
        });
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"عفوا" message:@"هذا العدد لا يوجد به مقالات" delegate:self cancelButtonTitle:@"إلغاء" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    
    if (dictionaryThatCached)
    {
        finalArticlesArray=[NSMutableArray arrayWithArray:[CacheManager getArraywithName:[NSString stringWithFormat:@"%@.plist",issueId] inRelativePath:[NSString stringWithFormat:@"%@",issueId]]];
        if ([dictionaryThatCached objectForKey:ARTICLES]) {
            articlesArrayThatCached=[NSMutableArray arrayWithArray:[dictionaryThatCached objectForKey:ARTICLES]];  // get article array that be downloaded
        }
    }
    else{
        
        // download best cover, ornament_transparent and bullet
        
        NSString *coverUrl=[NSString stringWithFormat:@"%@",[[issuedDict objectForKey:@"list"] objectForKey:@"best.cover.url"]];
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[coverUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding ]]];
        NSData *coverImg=[NSData dataWithContentsOfURL:url];
        
        NSString *coverCSSUrl=[NSString stringWithFormat:@"%@",[[issuedDict objectForKey:@"list"] objectForKey:@"cover.style.url"]];
        url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",coverCSSUrl]];
        NSData *coverCssData=[NSData dataWithContentsOfURL:url];
        
        if (coverImg && coverCssData) {
            [CacheManager saveData:coverImg withName:[NSString stringWithFormat:@"coverc.jpg"] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
            NSString *coverCSS=[[NSString alloc] initWithData:coverCssData encoding:NSUTF8StringEncoding];
            NSDictionary *cachedDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"0",IS_DOWNLOADED,nil,ARTICLES,@"0",IS_READ ,nil];
            
            NSString *ornamentImg = [[NSBundle mainBundle] pathForResource:@"ornament_transparent_small" ofType:@"png"];
            NSData *ornamentData=[NSData dataWithContentsOfFile:ornamentImg];
            [CacheManager saveData:ornamentData withName:[NSString stringWithFormat:@"ornament_transparent_small.png"] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
            
            if([UIDevice deviceType]== iPad || [UIDevice deviceType]== iPadRetina)
                ornamentImg = [[NSBundle mainBundle] pathForResource:@"ornament" ofType:@"svg"];
            else
                ornamentImg = [[NSBundle mainBundle] pathForResource:@"ornament-iPhone" ofType:@"svg"];
            ornamentData=[NSData dataWithContentsOfFile:ornamentImg];
            [CacheManager saveData:ornamentData withName:[NSString stringWithFormat:@"ornament.svg"] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
            
            NSString *bulletImg = [[NSBundle mainBundle] pathForResource:@"bullet_small" ofType:@"png"];
            NSData *bulletData=[NSData dataWithContentsOfFile:bulletImg];
            [CacheManager saveData:bulletData withName:[NSString stringWithFormat:@"bullet_small.png"] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
            
            
            NSDictionary *coverDict=[self createIndexPage:currentArticlesArray withStyle:coverCSS];
            [coverCSS release];
            [finalArticlesArray addObject:coverDict];
            [UserDefaults addObject:cachedDictionary withKey:key ifKeyNotExists:NO];
            [CacheManager saveArray:finalArticlesArray withName:[NSString stringWithFormat:@"%@.plist",issueId] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
        }else
        {
            [self downloadErrorWithIssue:issueId issueNumber:issueNo];
            return;
        }
        
        NSString *articleCSSUrl=[NSString stringWithFormat:@"%@",[[issuedDict objectForKey:@"list"] objectForKey:@"style.url"]];
        url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",articleCSSUrl]];
        NSData *articleCssData=[NSData dataWithContentsOfURL:url];
        if (articleCssData) {
            [CacheManager saveData:articleCssData withName:[NSString stringWithFormat:@"style.css"] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
        }else
        {
            [self downloadErrorWithIssue:issueId issueNumber:issueNo];
            return;
        }
        
        
        
    }
    
    float rate = 1.0/(float)currentArticlesArray.count ;
    int tryAgain=0;
    for (int index=0; index<[currentArticlesArray count]; index++) {
        isArticleDownloaded=YES;
        NSString *articleId=[NSString stringWithFormat:@"%@",[[currentArticlesArray objectAtIndex:index] objectForKey:@"item.number"]];
        if (articlesArrayThatCached) {
            BOOL isExist=NO;
            for (int i=0; i<[articlesArrayThatCached count]; i++) {
                if ([[articlesArrayThatCached objectAtIndex:i] isEqual:articleId]) {
                    isExist=YES;
                    break;
                }
            }
            if (isExist) {
                continue;
            }
            
            
        }
        
        NSDictionary *articleDict ;
        
        if([UIDevice deviceType]== iPad)
            articleDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"get/article/%@/fields/cover.768x1024/",articleId]];
        else if ([UIDevice deviceType]== iPadRetina)
            articleDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"get/article/%@/fields/cover.1536x2048/",articleId]];
        
        else if ([UIDevice deviceType]== iPhone)
            articleDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"get/article/%@/fields/cover.320x480/",articleId]];
        
        else if ([UIDevice deviceType]== iPhoneRetina)
            articleDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"get/article/%@/fields/cover.640x960/",articleId]];
        
        else
            articleDict=[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"get/article/%@/fields/cover.640x1136/",articleId]];
        
        
        if (!articleDict) {
            tryAgain++;
            if (tryAgain<=3) {
                index--;
                continue;
            }else{
                [self downloadErrorWithIssue:issueId issueNumber:issueNo];
                return;
            }
        }
        NSString *imageUrl=[NSString stringWithFormat:@"%@",[[articleDict objectForKey:@"article"] objectForKey:@"cover.url"]];
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[imageUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding ]]];
        NSData *coverImg=[NSData dataWithContentsOfURL:url];
        if (coverImg) {
            [CacheManager saveData:coverImg withName:[NSString stringWithFormat:@"%@c.jpg",articleId] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
        }else
        {
            tryAgain++;
            if (tryAgain<=3) {
                index--;
                continue;
            }else{
                [self downloadErrorWithIssue:issueId issueNumber:issueNo];
                return;
            }
        }
        
        BOOL htmlResourcesDownloaded=[self downloadHtmlResourcesWithArticleID:articleId withIssueID:issueId];
        if (!htmlResourcesDownloaded)
        {
            tryAgain++;
            if (tryAgain<=3) {
                index--;
                continue;
            }else{
                [self downloadErrorWithIssue:issueId issueNumber:issueNo];
                return;
            }
        }
        [finalArticlesArray addObject:articleDict];
        //  if (isArticleDownloaded) {
        
        NSDictionary *lastDict=[UserDefaults getDictionaryWithKey:key];
        if (lastDict) {
            NSMutableArray *lastArray=[NSMutableArray array];
            if ([lastDict objectForKey:ARTICLES]) {
                lastArray=[NSMutableArray arrayWithArray:[lastDict objectForKey:ARTICLES]];
            }
            [lastArray addObject:articleId];
            NSDictionary *cachedDictionary=nil;
            cachedDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"0",IS_DOWNLOADED,lastArray,ARTICLES, @"0",IS_READ,nil];
            
            [UserDefaults addObject:cachedDictionary withKey:key ifKeyNotExists:NO];
            [CacheManager saveArray:finalArticlesArray withName:[NSString stringWithFormat:@"%@.plist",issueId] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
            
            if (index == [currentArticlesArray count]-1) {
                NSDictionary *lastPageDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:@"",@"html",@"last",@"item.number", nil],@"article",@"1004",@"bodyHeight",@"1004",@"headerHeight", nil];
                [finalArticlesArray addObject:lastPageDict];
                [CacheManager saveArray:finalArticlesArray withName:[NSString stringWithFormat:@"%@.plist",issueId] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
                NSString *lastImg;
                
                if([UIDevice deviceType]== iPhone5)
                    lastImg = [[NSBundle mainBundle] pathForResource:@"last_page-iPhone5" ofType:@"png"];
                else
                    lastImg = [[NSBundle mainBundle] pathForResource:@"last_page" ofType:@"png"];
                NSData *lastData=[NSData dataWithContentsOfFile:lastImg];
                [CacheManager saveData:lastData withName:[NSString stringWithFormat:@"lastc.jpg"] inRelativePath:[NSString stringWithFormat:@"%@",issueId]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            
            
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:sectionSize-1-issueNo  inSection:0];
            IssueCell *cell = (IssueCell *)[horizontalTableView cellForRowAtIndexPath:indexPath];
            
            cell.progressView.hidden = NO ;
            [cell.progressView setProgress:rate*index];
            
   
            
        });
        tryAgain=0;
        
    }
    
    [self performSelectorOnMainThread:@selector(calculateArtcileHtmlInputsWithDictionary:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:finalArticlesArray,@"array",issueId,@"issue",[NSString stringWithFormat:@"%d",issueNo],@"cellIndex", nil] waitUntilDone:NO];
    
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
   */
}

-(NSDictionary *)createIndexPage:(NSArray *)articlesArr withStyle:(NSString *)indexStyle {
    // NSString *CSSfilePath=nil;
    
    NSMutableString *coverStyle=[NSMutableString stringWithFormat:@"<html><head><script>function testSp(){window.location.href = \"finish\";}window.onload=testSp;</script><style>%@</style></head><body><div class=\"container\"><div class=\"inner_container\"><h1>محتويات العدد</h1><ul>",indexStyle];
    for (int i=0; i<[articlesArr count]; i++) {
        [coverStyle appendFormat:@"<li>%@<span>، ",[[articlesArr objectAtIndex:i] objectForKey:@"title"]];
        id authors=[[[articlesArr objectAtIndex:i]  objectForKey:@"authors"] objectForKey:@"author"];
        if ([authors isKindOfClass:[NSArray class]]) {
            for (int index=0; index<[authors count]; index++) {
                if (index == [authors count]-1)
                    [coverStyle appendFormat:@"%@",[[authors objectAtIndex:index] objectForKey:@"name"]];
                else
                    [coverStyle appendFormat:@"%@ و",[[authors objectAtIndex:index] objectForKey:@"name"]];
            }
            [coverStyle appendFormat:@"</span></li>"];
        }else if([authors isKindOfClass:[NSDictionary class]]){
            [coverStyle appendFormat:@"%@</span></li>",[authors objectForKey:@"name"]];
        }
    }
    [coverStyle appendFormat:@"</ul> <div></div></div></div></body></html>"];
    NSDictionary *coverDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObjectsAndKeys:coverStyle,@"html",@"cover",@"item.number", nil],@"article",@"1004",@"bodyHeight",@"1004",@"headerHeight", nil];
    return coverDict;
}

-(void)downloadErrorWithIssue:(NSString *)issueId  issueNumber:(int)issueNumber {
    /*for (int i=0; i<[self.articlesStillDownloading count]; i++) {
     NSDictionary *dict=[self.articlesStillDownloading objectAtIndex:i];
     if ([[dict objectForKey:@"issue.id"] isEqual:[NSString stringWithFormat:@"%@",issueId]]) {
     [self.articlesStillDownloading removeObjectAtIndex:i];
     break;
     }
     }*/
    //[self.horizontalTableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:sectionSize-1-issueNumber  inSection:0];
        
        IssueCell *cell = (IssueCell *)[horizontalTableView cellForRowAtIndexPath:indexPath];
        
        cell.progressView.hidden = YES ;
        cell.downloadedImage.hidden = NO ;
        
    });
    
    
    [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:NO];
    
}

-(void)showAlert{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"معذرة، حدث خطأ في تحميل العدد، برجاء إعادة التحميل في وقت أخر" delegate:nil cancelButtonTitle:@"إلغاء" otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    
    
    
    int downloadCountNO = [[UserDefaults getStringWithKey:Downlaod_Count ]  integerValue ];
    downloadCountNO --;
    [UserDefaults  addObject:[NSString stringWithFormat:@"%d",downloadCountNO] withKey:Downlaod_Count ifKeyNotExists:NO];
    
    if(downloadCountNO == 0 )
        [self.delegate updateListDelegate];
}

-(BOOL)downloadHtmlResourcesWithArticleID:(NSString *)articleID withIssueID:(NSString *)issueID{
    id articleImages=[[[NetworkService getDataInDictionaryWithBody:nil methodIsPost:NO andBaseURL:[NSString stringWithFormat:@"list/article/%@/images/",articleID]] objectForKey:@"urls"] objectForKey:@"string"];
    if (articleImages && [articleImages isKindOfClass:[NSArray class]]) {
        for (int i=0; i<[articleImages count]; i++) {
            NSString *imageUrl=[NSString stringWithFormat:@"%@",[articleImages objectAtIndex:i]];
            NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[imageUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding ]]];
            NSData *img=[NSData dataWithContentsOfURL:url];
            if (img) {
                NSArray *parts = [imageUrl componentsSeparatedByString:@"/"];
                [CacheManager saveData:img withName:[NSString stringWithFormat:@"%@",[parts objectAtIndex:parts.count-2]] inRelativePath:[NSString stringWithFormat:@"%@/images/",issueID]];
            }else{
                return NO;
            }
        }
    }else if(articleImages && [articleImages isKindOfClass:[NSString class]]){
        NSString *imageUrl=[NSString stringWithFormat:@"%@",articleImages ];
        NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[imageUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding ]]];
        NSData *img=[NSData dataWithContentsOfURL:url];
        if (img) {
            NSArray *parts = [imageUrl componentsSeparatedByString:@"/"];
            [CacheManager saveData:img withName:[NSString stringWithFormat:@"%@",[parts objectAtIndex:parts.count-2]] inRelativePath:[NSString stringWithFormat:@"%@/images/",issueID]];
        }else{
            return NO;
        }
    }
    return YES;
}
-(void)calculateArtcileHtmlInputsWithDictionary:(NSDictionary *)content{
    NSArray *currentArticlesArray=[content objectForKey:@"array"];
    
    int issueId=[[content objectForKey:@"issue"] intValue];
    NSString *articleCSS=[[NSString alloc] initWithData:[CacheManager getDataWithName:@"style.css" inRelativePath:[content objectForKey:@"issue"]] encoding:NSUTF8StringEncoding];
    for (int index=1; index<[currentArticlesArray count]-1; index++)
    {
        
        CustomWebView *articleWebView=nil;
        if([UIDevice deviceType]== iPad || [UIDevice deviceType] == iPadRetina){
            
            articleWebView=[[CustomWebView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
        }
        else{
            
            articleWebView=[[CustomWebView alloc] initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height)];
        }
        
        NSString *articleHtml=[NSString stringWithFormat:@"<html><head><style>%@</style></head><body>%@</body></html>",articleCSS,[[[currentArticlesArray objectAtIndex:index] objectForKey:@"article"] objectForKey:@"html"]];
        
        articleWebView.delegate=self;
        articleWebView.articleIndex=index;
        articleWebView.issueId=issueId;
        articleWebView.articlesCount=[currentArticlesArray count]-2;
        [articleWebView loadHTMLString:articleHtml baseURL:nil];
        articleWebView.cellIndex  = [[content objectForKey:@"cellIndex"] integerValue];
    }
    [articleCSS release];
}

- (void) webViewDidFinishLoad:(UIWebView*)webView{
    
    NSString *height = [NSString stringWithFormat:@"document.getElementById('article_basic_info').clientHeight;"];
    int headerHieght=0;
    int bodyHieght=0;
    if([UIDevice deviceType]== iPad || [UIDevice deviceType] == iPadRetina){
        headerHieght = [[webView stringByEvaluatingJavaScriptFromString:height] intValue]+24;
    }else
        headerHieght = [[webView stringByEvaluatingJavaScriptFromString:height] intValue]+6;
    
    height = [NSString stringWithFormat:@"Math.max( document.body.scrollHeight, document.body.offsetHeight,document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight );"];
    
    if([UIDevice deviceType]== iPad || [UIDevice deviceType] == iPadRetina)
        bodyHieght = [[webView stringByEvaluatingJavaScriptFromString:height] intValue]+24;
    else
        bodyHieght = [[webView stringByEvaluatingJavaScriptFromString:height] intValue]+6;
    
    
    CustomWebView *currentWebView=(CustomWebView *)webView;
    
    NSMutableArray *issueArray=[NSMutableArray arrayWithArray:[CacheManager getArraywithName:[NSString stringWithFormat:@"%d.plist",currentWebView.issueId] inRelativePath:[NSString stringWithFormat:@"%d",currentWebView.issueId]]];
    
    NSMutableDictionary *currentArticle=[NSMutableDictionary dictionaryWithDictionary:[issueArray objectAtIndex:currentWebView.articleIndex]];
    [currentArticle addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",headerHieght],@"headerHeight",[NSString stringWithFormat:@"%d",bodyHieght],@"bodyHeight", nil]];
    
    [issueArray replaceObjectAtIndex:currentWebView.articleIndex withObject:currentArticle];
    [CacheManager saveArray:issueArray withName:[NSString stringWithFormat:@"%d.plist",currentWebView.issueId] inRelativePath:[NSString stringWithFormat:@"%d",currentWebView.issueId]];
    
    if (currentWebView.articleIndex==currentWebView.articlesCount) {
        
        /*  for (int i=0; i<[self.articlesStillDownloading count]; i++) {
         NSDictionary *dict=[self.articlesStillDownloading objectAtIndex:i];
         if ([[dict objectForKey:@"issue.id"] isEqual:[NSString stringWithFormat:@"%d",currentWebView.issueId]]) {
         [self.articlesStillDownloading removeObjectAtIndex:i];
         break;
         }
         }*/
        
        
        
        
        NSDictionary *lastDict=[UserDefaults getDictionaryWithKey:[NSString stringWithFormat:@"%d",currentWebView.issueId]];
        NSMutableArray *lastArray=[NSMutableArray array];
        if ([lastDict objectForKey:ARTICLES]) {
            lastArray=[NSMutableArray arrayWithArray:[lastDict objectForKey:ARTICLES]];
        }
        
        NSDictionary *cachedDictionary=[NSDictionary dictionaryWithObjectsAndKeys:@"1",IS_DOWNLOADED,lastArray,ARTICLES,@"0",IS_READ ,nil];
        [UserDefaults addObject:cachedDictionary withKey:[NSString stringWithFormat:@"%d",currentWebView.issueId] ifKeyNotExists:NO];
        [self saveDownloadUsageIWthIssuesID:currentWebView.issueId];
        //  [self.horizontalTableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:sectionSize-1-currentWebView.cellIndex  inSection:0];
            
            IssueCell *cell = (IssueCell *)[horizontalTableView cellForRowAtIndexPath:indexPath];
            
            cell.progressView.hidden = YES ;
            cell.downloadedImage.hidden = YES ;
            
        });
        
        
        int downloadCountNO = [[UserDefaults getStringWithKey:Downlaod_Count ]  integerValue ];
        downloadCountNO --;
        [UserDefaults  addObject:[NSString stringWithFormat:@"%d",downloadCountNO] withKey:Downlaod_Count ifKeyNotExists:NO];
        
        if(downloadCountNO == 0 )
            [self.delegate updateListDelegate];
    }
    [webView release];
}


//--------------------------------------------------------------Download Usage----------------------------------------------------------------------------------------------


-(void)saveDownloadUsageIWthIssuesID:(int)issueID{
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"downloadedIssues.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *downloadedIssueArray ;
    
    if (![fileManager fileExistsAtPath: path])
    {
        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"downloadedIssues.plist"] ];
        downloadedIssueArray = [[NSMutableArray alloc] init];
    }
    
    else
        downloadedIssueArray = [[NSMutableArray alloc] initWithContentsOfFile: path];
    //
    NSDictionary *downloadIssueDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",issueID],@"issueID",[NSDate date] ,@"Time", nil];
    [downloadedIssueArray addObject:downloadIssueDict];
    [downloadedIssueArray writeToFile:path atomically:YES];
    [downloadedIssueArray release];
    
}


//--------------------------------------------------------------iCloud Backup----------------------------------------------------------------------------------------------

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success)
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    
    return success;
}

@end
