#import "LocalViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "PlayRootViewController.h"
#import "CMConstants.h"
#import <QuartzCore/QuartzCore.h>

@interface LocalViewController(){
    WaterflowView *flowView;
    NSMutableArray *imageUrls;
    int currentPage;
    int tempCount;
}
- (void)addContentView;
@end

@implementation LocalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    imageUrls = [NSMutableArray arrayWithObjects:@"http://img5.douban.com/view/photo/thumb/public/p1686249659.jpg",@"http://img1.douban.com/lpic/s11184513.jpg",@"http://img1.douban.com/lpic/s9127643.jpg",@"http://img3.douban.com/lpic/s6781186.jpg",@"http://img1.douban.com/mpic/s9039761.jpg",nil];
    tempCount = imageUrls.count;
    [self addContentView];
}

- (void)addContentView
{
    if(flowView != nil){
        [flowView removeFromSuperview];
    }
    flowView = [[WaterflowView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSString *flag = @"0";
    if(appDelegate.userLoggedIn){
        flag = @"1";
    }
    flowView.cellSelectedNotificationName = [NSString stringWithFormat:@"%@%@", @"localSelected",flag];
    [flowView showsVerticalScrollIndicator];
    flowView.flowdatasource = self;
    flowView.flowdelegate = self;
    [self.view addSubview:flowView];
    
    currentPage = 1;
    [flowView reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark-
#pragma mark- WaterflowDataSource

- (NSInteger)numberOfColumnsInFlowView:(WaterflowView *)flowView
{
    return NUMBER_OF_COLUMNS;
}

- (NSInteger)flowView:(WaterflowView *)flowView numberOfRowsInColumn:(NSInteger)column
{
    return 10;
}

- (WaterFlowCell*)flowView:(WaterflowView *)flowView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";
	WaterFlowCell *cell = [[WaterFlowCell alloc] initWithReuseIdentifier:CellIdentifier];
    cell.cellSelectedNotificationName = flowView.cellSelectedNotificationName;
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    if(indexPath.section == 0){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP, 0, VIDEO_LOGO_WIDTH, VIDEO_LOGO_HEIGHT);
    } else if(indexPath.section == NUMBER_OF_COLUMNS - 1){
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, VIDEO_LOGO_WIDTH, VIDEO_LOGO_HEIGHT);
    } else {        
        imageView.frame = CGRectMake(MOVIE_LOGO_WIDTH_GAP/2, 0, VIDEO_LOGO_WIDTH, VIDEO_LOGO_HEIGHT);
    }
    [imageView setImageWithURL:[NSURL URLWithString:[imageUrls objectAtIndex:(indexPath.row + indexPath.section) % tempCount]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    imageView.layer.borderWidth = 1;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(1, 1);
    imageView.layer.shadowOpacity = 1;
    [cell addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(MOVIE_LOGO_WIDTH_GAP, VIDEO_LOGO_HEIGHT + 5, MOVE_NAME_LABEL_WIDTH, MOVE_NAME_LABEL_HEIGHT)];
    titleLabel.text = @"2012-09-10";
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor colorWithRed:252/255.0 green:252/255.0 blue:252/255.0 alpha:1];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = CMConstants.titleFont;
    [cell addSubview:titleLabel];
    return cell;
    
}

#pragma mark-
#pragma mark- WaterflowDelegate
-(CGFloat)flowView:(WaterflowView *)flowView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	return VIDEO_LOGO_HEIGHT + MOVE_NAME_LABEL_HEIGHT + 5 + 10;
    
}

- (void)flowView:(WaterflowView *)flowView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"did select at %i %i in %@",indexPath.row, indexPath.section, self.class);
    PlayRootViewController *viewController = [[PlayRootViewController alloc]init];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:viewController];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController presentModalViewController:navController animated:YES];
}

- (void)flowView:(WaterflowView *)_flowView willLoadData:(int)page
{
    [imageUrls addObject:@"http://img5.douban.com/mpic/s10389149.jpg"];
    tempCount = imageUrls.count;
    [flowView reloadData];
}

@end
