//
//  NotesBrowserTableViewController.m
//  LocNotes
//
//  Created by Chris Miles on 24/05/10.
//
//  Copyright (c) Locayta Limited 2010-2011.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NotesBrowserTableViewController.h"
#import "EditNoteViewController.h"
#import "AppDelegate_Shared.h"
#import "AppDelegate_Pad.h"
#import "Note+Management.h"

@implementation NotesBrowserTableViewController

@synthesize delegate;
@synthesize localDateFormatter;
@synthesize noteFetchedResultsController;
@synthesize selectedNoteID;


- (NSIndexPath *)indexPathForSelectedNote {
	NSUInteger row = -1;
	for (Note *note in [self.noteFetchedResultsController fetchedObjects]) {
		row++;
		NSString *objectID = [[[note objectID] URIRepresentation] absoluteString];
		if ([objectID isEqualToString:self.selectedNoteID]) {
			break;
		}
	}
	
	NSIndexPath *indexPath = nil;
	if (row != -1) {
		indexPath = [NSIndexPath indexPathForRow:row inSection:0];
	}
	
	return indexPath;
}

- (void)selectSelectedNote {
	NSIndexPath *indexPath = [self indexPathForSelectedNote];
	if (indexPath) {
		[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	}
}

- (NSString *)formattedStringForDate:(NSDate *)date {
	NSString *formattedDate = nil;
	
	NSTimeInterval timeIntervalSinceNow = fabs([date timeIntervalSinceNow]);
	double days = timeIntervalSinceNow / 60.0 / 60.0 / 24.0;
	if (timeIntervalSinceNow < 120.0) {
		formattedDate = @"Now";
	}
	else if (days < 2.0) {
		NSCalendar *gregorian = [NSCalendar currentCalendar];
		NSInteger timestampDay = [[gregorian components:NSDayCalendarUnit fromDate:date] day];
		NSInteger currentDay = [[gregorian components:NSDayCalendarUnit fromDate:[NSDate date]] day];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"HH:mm"];
		[formatter setTimeZone:[NSTimeZone localTimeZone]];
		
		if (timestampDay == currentDay) {
			formattedDate = [NSString stringWithFormat:@"Today %@", [formatter stringFromDate:date]];
		}
		else if (currentDay-timestampDay == 1) {
			formattedDate = [NSString stringWithFormat:@"Yesterday %@", [formatter stringFromDate:date]];
		}
		
		[formatter release];
	}
	
	if (nil == formattedDate) {
		// Otherwise, format as full date
		formattedDate = [self.localDateFormatter stringFromDate:date];
	}
	
	return formattedDate;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	Note *note = [self.noteFetchedResultsController objectAtIndexPath:indexPath];
	cell.textLabel.text = note.title;
	cell.detailTextLabel.text = [self formattedStringForDate:note.lastUpdated];
	
	[cell setNeedsLayout];	// force labels to be resized to fit new text
}

- (void)createDateFormatter {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"dd MMM yyyy"];
	[formatter setTimeZone:[NSTimeZone localTimeZone]];
	self.localDateFormatter = formatter;
	[formatter release];
}

- (NSFetchedResultsController *)fetchedResultsControllerForNoteWithDelegate:(id)controllerDelegate {
	AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
	
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription
							 entityForName:@"Note" inManagedObjectContext:appDelegate.managedObjectContext]];
	
    // Add a sort descriptor. Mandatory.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"lastUpdated" ascending:NO selector:nil];
    NSArray *descriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:descriptors];
    [sortDescriptor release];
	
    // Init the fetched results controller
    NSError *error;
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc]
															initWithFetchRequest:fetchRequest
															managedObjectContext:appDelegate.managedObjectContext
															sectionNameKeyPath:nil
															cacheName:@"Note"];
	fetchedResultsController.delegate = controllerDelegate;
	
    if (![fetchedResultsController performFetch:&error])
        DLog(@"Error %@", [error localizedDescription]);
	
    [fetchRequest release];
	
	return [fetchedResultsController autorelease];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	NSInteger sectionCount;
	
	sectionCount = [[self.noteFetchedResultsController sections] count];

    return sectionCount;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	NSInteger rowCount;
	
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.noteFetchedResultsController sections] objectAtIndex:section];
	rowCount = [sectionInfo numberOfObjects];

	return rowCount;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"NotesBrowserTableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		Note *note = [self.noteFetchedResultsController objectAtIndexPath:indexPath];
		if (![Note deleteNote:note error:nil]) {
			ALog(@"Delete note failed.");
		}
		[delegate didSelectNote:nil];
    }   
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Note *note = [self.noteFetchedResultsController objectAtIndexPath:indexPath];
	self.selectedNoteID = [[[note objectID] URIRepresentation] absoluteString];
	
	ZAssert(note, @"note should not be nil");
	
	[delegate didSelectNote:note];
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//	[(UITableView *)self.view deselectRowAtIndexPath:[(UITableView *)self.view indexPathForSelectedRow] animated:NO];
	
	[(UITableView *)self.view beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[(UITableView *)self.view insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
									withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[(UITableView *)self.view deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
									withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {

	UITableView *tableView = (UITableView *)self.view;
	
	switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
			
		case NSFetchedResultsChangeUpdate:
			[self configureCell:[tableView cellForRowAtIndexPath:indexPath]
					atIndexPath:indexPath];
			break;
			
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
							 withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView	endUpdates];
	
//	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
	[self selectSelectedNote];
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	[self createDateFormatter];
	
	self.noteFetchedResultsController = [self fetchedResultsControllerForNoteWithDelegate:self];
	DLog(@"self.noteFetchedResultsController created: %@", self.noteFetchedResultsController);
}


- (void)viewWillAppear:(BOOL)animated {
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		// iPhone UI only
		NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
		if (indexPath) {
			[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
	
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	DLog(@"viewDidUnload");
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc {
	[localDateFormatter release];
	[noteFetchedResultsController release];
	[selectedNoteID release];
	
    [super dealloc];
}


@end

