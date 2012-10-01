//
//  R2RResultsViewController.m
//  R2RApp
//
//  Created by Ash Verdoorn on 6/09/12.
//  Copyright (c) 2012 Rome2Rio. All rights reserved.
//

#import "R2RResultsViewController.h"
#import "R2RDetailViewController.h"

#import "R2RStatusButton.h"
#import "R2RResultsCell.h"
#import "R2RStringFormatters.h"

#import "R2RAirport.h"
#import "R2RAirline.h"
#import "R2RRoute.h"
#import "R2RWalkDriveSegment.h"
#import "R2RTransitSegment.h"
#import "R2RTransitItinerary.h"
#import "R2RTransitLeg.h"
#import "R2RTransitHop.h"
#import "R2RFlightSegment.h"
#import "R2RFlightItinerary.h"
#import "R2RFlightLeg.h"
#import "R2RFlightHop.h"
#import "R2RFlightTicketSet.h"
#import "R2RFlightTicket.h"
#import "R2RPosition.h"

@interface R2RResultsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (strong, nonatomic) R2RStatusButton *statusButton;


enum {
    stateEmpty = 0,
    stateEditingDidBegin,
    stateEditingDidEnd,
    stateResolved,
    stateLocationNotFound,
    stateError
};

enum R2RState
{
    IDLE = 0,
    RESOLVING_FROM,
    RESOLVING_TO,
    SEARCHING,
};

@end

@implementation R2RResultsViewController
@synthesize searchLabel;

@synthesize dataController;
//@synthesize searchResponse, fromSearchPlace, toSearchPlace;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTitle:) name:@"refreshTitle" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshResults:) name:@"refreshResults" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatusMessage:) name:@"refreshStatusMessage" object:nil];
    
    [self refreshResultsViewTitle];
    
//    self.statusMessage = [[R2RStatusLabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height -100, self.view.bounds.size.width, 30.0)];
//    [self.view addSubview:self.statusMessage];

//    self.statusButton = [R2RStatusButton buttonWithType:UIButtonTypeCustom];
//    [self.statusButton addTarget:self action:@selector(statusButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:self.statusButton];
    
    self.statusButton = [[R2RStatusButton alloc] initWithFrame:CGRectMake(0.0, 360.0, 320.0, 30.0)];
    [self.statusButton addTarget:self action:@selector(statusButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.statusButton];
    
    [self setStatusMessage:self.dataController.statusMessage];

//    //retry search if search has failed
//    if (self.dataController.state == IDLE && self.dataController.search.responseCompletionState == stateError)
//    {
//        [self.dataController.search sendAsynchronousRequest];
//    }
    
    //[self configureResultsView];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    
    //here or dealloc???
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshTitle" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshResults" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"refreshStatusMessage" object:nil];
    
    [self setSearchLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
    
    //return [self.searchResponse.routes count];
    return [self.dataController.search.searchResponse.routes count]; //added plus one to temporarily include the message cell
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    static NSString *CellIdentifier = @"ResultsCell";
    R2RResultsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
//    static NSDateFormatter *formatter = nil;
//    if (formatter == nil)
//    {
//        formatter = [[NSDateFormatter alloc] init];
//        [formatter setDateStyle:NSDateFormatterMediumStyle];
//    }
    
//    NSInteger tempIndexRow = (indexPath.row % [self.searchResponse.routes count]);
//    R2RRoute *route = [self.searchResponse.routes objectAtIndex:tempIndexRow];
//    [[cell routeNumberLabel] setText : [NSString stringWithFormat:@"%d", indexPath.row]];
    
//    [cell setBackgroundColor:[UIColor greenColor]];
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 50, 50)];
//    [view setBackgroundColor:[UIColor blueColor]];
//    [cell addSubview:view];
    
    R2RRoute *route = [self.dataController.search.searchResponse.routes objectAtIndex:indexPath.row];
    
    char routeLabel = 'A';
    routeLabel = routeLabel + indexPath.row;
    [[cell routeNumberLabel] setText : [NSString stringWithFormat:@"%c", routeLabel]];
    
    
//    
//    //NSString *kindString = [[NSString alloc] init];
//    NSMutableString *kindString = [[NSMutableString alloc] init];
//    float totalDuration;
//    int count = 0;
//    for (id segment in route.segments)
//    {
//        
//        /////////  REDO THIS SECTION
//        if([segment isKindOfClass:[R2RWalkDriveSegment class]])
//        {
//            R2RWalkDriveSegment *currentSegment = segment;
//            [kindString appendString:currentSegment.kind];
//            totalDuration += currentSegment.duration;
//        }
//        else if([segment isKindOfClass:[R2RTransitSegment class]])
//        {
//            R2RTransitSegment *currentSegment = segment;
//            [kindString appendString:currentSegment.kind];
//            totalDuration += currentSegment.duration;
//        }
//        else if([segment isKindOfClass:[R2RFlightSegment class]])
//        {
//            R2RFlightSegment *currentSegment = segment;
//            [kindString appendString:currentSegment.kind];
//            totalDuration += currentSegment.duration;
//        }
//        
//        count++;
//        
//        if (count < [route.segments count])
//        {
//            [kindString appendString:@","];
//        }
//
//    }
    
//    NSDate *duration = [[NSDate alloc] init];
//    
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    [components setMinute:route.duration];
//    
//    NSLog(@"hour %d", [components hour]);
//    
//    NSTimeInterval 
    
    [[cell routeKindLabel] setText:route.name];
    
    R2RStringFormatters *formatter = [[R2RStringFormatters alloc] init];
    
    [[cell routeDurationLabel] setText:[formatter formatDuration:route.duration]];
    
    //[[cell routeDurationLabel] setText:[NSString stringWithFormat:@"%f", route.duration]];
    
    return cell;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

//-(void) refreshView:(NSNotification *) notification
//{
//    if ([notification.name isEqualToString:@"refreshTitle"])
//    {
//        [self refreshResultsViewTitle];
//        return;
//    }
//    if ([notification.name isEqualToString:@"refreshResults"])
//    {
//        [self refreshResults];
//    }
//    
//}

//-(void) configureResultsView
//{
//    self.searchLabel.text = [NSString stringWithFormat:@"%@ to %@", self.dataController.geoCoderFrom.geoCodeResponse.place.shortName, self.dataController.geoCoderTo.geoCodeResponse.place.shortName];
//
//    NSLog(@"%@", @"results view");
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showRouteDetails"])
    {
        R2RDetailViewController *detailsViewController = [segue destinationViewController];
        detailsViewController.route = [self.dataController.search.searchResponse.routes objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        detailsViewController.airlines = self.dataController.search.searchResponse.airlines;
        detailsViewController.airports = self.dataController.search.searchResponse.airports;
    }
}

-(void) statusButtonClicked
{
    [self.navigationController popViewControllerAnimated:true];
}

-(void) refreshResultsViewTitle
{
    NSString *from = self.dataController.fromText;
    if (self.dataController.geoCoderFrom.responseCompletionState == stateResolved)
    {
        from = [[NSString alloc] initWithString:self.dataController.geoCoderFrom.geoCodeResponse.place.shortName];
    }
    
    NSString *to = self.dataController.toText;
    if (self.dataController.geoCoderTo.responseCompletionState == stateResolved)
    {
        to = [[NSString alloc] initWithString:self.dataController.geoCoderTo.geoCodeResponse.place.shortName];
    }
    
    self.searchLabel.text = [NSString stringWithFormat:@"%@ to %@", from, to];
    
}

-(void) refreshTitle:(NSNotification *) notification
{
    [self refreshResultsViewTitle];
}

-(void) refreshResults:(NSNotification *) notification
{
    
    //[self configureResultsView];
    
    [self.tableView reloadData];
    
}

-(void) refreshStatusMessage:(NSNotification *) notification
{
    [self setStatusMessage:self.dataController.statusMessage];
    
//    [self.statusButton setTitle:self.dataController.statusMessage forState:UIControlStateNormal];
//    
//    if ([self.dataController.statusMessage length] == 0)
//    {
//        [self.statusButton setHidden:true];
//    }
//    else
//    {
//        [self.statusButton setHidden:false];
//    }
}

-(void) setStatusMessage: (NSString *) message
{
    [self.statusButton setTitle:message forState:UIControlStateNormal];
}

@end