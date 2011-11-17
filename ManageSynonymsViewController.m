//
//  ManageSynonymsViewController.m
//  LocNotes
//
//  Created by Chris Miles on 26/08/10.
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

#import "ManageSynonymsViewController.h"
#import <LocaytaSearch/LSLocaytaSearchThesaurus.h>

#import "AppDelegate_Shared.h"
#import "EditSynonymCell.h"
#import "ManageSynonymsTableViewController.h"


@implementation ManageSynonymsViewController

@synthesize synonymsTableViewContainerView;
@synthesize synonymsTableViewController;


- (void)saveSynonymsToSearchDatabase {
	NSString *databasePath = [[AppDelegate_Shared sharedAppDelegate] searchDatabasePath];
	LSLocaytaSearchThesaurus *thesaurus = [[LSLocaytaSearchThesaurus alloc] initWithDatabasePath:databasePath];
	[thesaurus clearSynonyms];
	[thesaurus addSynonymsFromArray:self.synonymsTableViewController.synonyms];
	[thesaurus release];
}

- (void)endCellTextEditing {
	for (EditSynonymCell *cell in [self.synonymsTableViewController.tableView visibleCells]) {
		[cell resignFirstResponder];
	}
}

- (IBAction)doneAction {
	for (EditSynonymCell *cell in [self.synonymsTableViewController.tableView visibleCells]) {
		[cell updateDelegate];
		[cell resignFirstResponder];
	}
	
	[self saveSynonymsToSearchDatabase];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelAction {
	[self endCellTextEditing];
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)addRowAction {
	[self endCellTextEditing];
	
	[self.synonymsTableViewController.synonyms addObject:[NSArray arrayWithObject:@""]];	// empty row
	
	NSIndexPath *bottomCellIndexPath = [NSIndexPath indexPathForRow:[self.synonymsTableViewController.synonyms count]-1 inSection:0];
	[self.synonymsTableViewController.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:bottomCellIndexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
	
	EditSynonymCell *cell = (EditSynonymCell *)[synonymsTableViewController.tableView cellForRowAtIndexPath:bottomCellIndexPath];
	[cell becomeFirstResponder];
}

- (void)loadSynonyms {
	
	NSString *databasePath = [[AppDelegate_Shared sharedAppDelegate] searchDatabasePath];
	LSLocaytaSearchThesaurus *thesaurus = [[LSLocaytaSearchThesaurus alloc] initWithDatabasePath:databasePath];
	NSDictionary *synonymsDict = [thesaurus getSynonyms];
	NSMutableArray *synonymsArray = [[NSMutableArray alloc] init];
	for (NSString *key in synonymsDict) {
		NSArray *row = [NSArray arrayWithObject:key];
		[synonymsArray addObject:[row arrayByAddingObjectsFromArray:[synonymsDict valueForKey:key]]];
	}
	int reverseSort = NO;
	[synonymsArray sortUsingFunction:customAlphabeticSort context:&reverseSort];
	self.synonymsTableViewController.synonyms = synonymsArray;
	[synonymsArray release];
	
	[thesaurus release];
}


#pragma mark -
#pragma mark UIViewController methods

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self loadSynonyms];
	[self.synonymsTableViewController.tableView setEditing:YES animated:NO];
	
	// Add table view directly on top of the container view (which is just used as a placeholder to simplify framing)
	self.synonymsTableViewController.tableView.frame = self.synonymsTableViewContainerView.frame;
	[self.view addSubview:self.synonymsTableViewController.tableView];
	self.synonymsTableViewContainerView.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.synonymsTableViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.synonymsTableViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self.synonymsTableViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	[self.synonymsTableViewController viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

	self.synonymsTableViewContainerView = nil;
	self.synonymsTableViewController = nil;
}


- (void)dealloc {
	[synonymsTableViewContainerView release];
	[synonymsTableViewController release];
	
    [super dealloc];
}


@end


NSInteger customAlphabeticSort(id array1, id array2, void *reverse) {
	NSString *string1 = [array1 objectAtIndex:0];
	NSString *string2 = [array2 objectAtIndex:0];
	
	if ((NSInteger *)reverse == NO) {
		return [string2 localizedCaseInsensitiveCompare:string1];
	}
	return [string1 localizedCaseInsensitiveCompare:string2];
}
