//
//  NotesBrowserViewController.m
//  LocNotes
//
//  Created by Chris Miles on 13/07/10.
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

#import <objc/message.h>

#import "NotesBrowserViewController.h"

#import "AppDelegate_Pad.h"
#import "EditNoteViewController.h"
#import "InfoViewController.h"
#import "Note+Management.h"
#import "SearchDatabaseUpdater.h"
#import "SettingsTableViewController.h"

@implementation NotesBrowserViewController

@synthesize bottomToolbar;
@synthesize currentSearchResult;
@synthesize editNoteBarButtonItem;
@synthesize editNoteDoneBarButtonItem;
@synthesize notesBrowserTableViewController;
@synthesize searchSummaryLabel;
@synthesize searchSummaryView;

- (void)settingsDoneAction {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)settingsButtonAction {
	SettingsTableViewController *settingsTableViewController = [[SettingsTableViewController alloc] initWithNibName:@"SettingsTableViewController" bundle:nil];
	settingsTableViewController.delegate = self;
	
	// Replace header view with a toolbar and done button, for iPhone mode
	UIToolbar *toolbar = [[UIToolbar alloc] init];
	toolbar.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 44.0);
	UIBarButtonItem *flexibleBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	UIBarButtonItem *doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(settingsDoneAction)];
	[toolbar setItems:[NSArray arrayWithObjects:flexibleBarButtonItem, doneBarButtonItem, nil]];
	[toolbar addSubview:settingsTableViewController.tableView.tableHeaderView];
	settingsTableViewController.tableView.tableHeaderView = toolbar;
	[flexibleBarButtonItem release];
	[doneBarButtonItem release];
	[toolbar release];
	
	[self presentModalViewController:settingsTableViewController animated:YES];
	[settingsTableViewController release];
}

- (void)infoButtonAction {
	InfoViewController *infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
	[self presentModalViewController:infoViewController animated:YES];
	[infoViewController release];
}

- (void)updateSearchSummary:(LSLocaytaSearchResult *)searchResult {
	self.searchDisplayController.searchResultsTableView.tableHeaderView = searchSummaryView;
	
	NSString *spellCorrectedText = @"";
	if (searchResult.wasAutoSpellCorrected) {
		spellCorrectedText = [NSString stringWithFormat:@"Auto corrected to \"%@\". ", searchResult.correctedQueryString];
	}
	NSString *notesString;
	if (searchResult.matchCount == 1) {
		notesString = @"note";
	}
	else {
		notesString = @"notes";
	}

	NSString *searchSummaryText = [NSString stringWithFormat:@"%@%d %@ found.", spellCorrectedText, searchResult.matchCount, notesString];
	self.searchSummaryLabel.text = searchSummaryText;
}

- (void)searchWithText:(NSString *)searchText sortBy:(SearchSortBy)sortBy {
	if ([searchText isEqualToString:@""]) {
		self.currentSearchResult = nil;
		[self.searchDisplayController.searchResultsTableView reloadData];
	}
	else {
		AppDelegate_Pad *appDelegate = [[UIApplication sharedApplication] delegate];
		
		appDelegate.searchDatabaseRequester.delegate = self;
		[appDelegate.searchDatabaseRequester searchWithText:searchText sortBy:sortBy];
	}
}

- (void)searchIndexDidUpdate {
	if (currentSearchResult) {
		// Refresh search results
		[self searchWithText:self.searchDisplayController.searchBar.text sortBy:self.searchDisplayController.searchBar.selectedScopeButtonIndex];
	}
}

- (void)displayNoteEditorWithNote:(Note *)note {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		AppDelegate_Pad *appDelegate = [[UIApplication sharedApplication] delegate];
		if (note) {
			[appDelegate.editNoteViewController changeNoteBeingEdited:note];
		}
		else {
			[appDelegate.editNoteViewController clear];
			[appDelegate.editNoteViewController.contentTextView resignFirstResponder];
		}
		
	}
	else {
		// iPhone
		if (note) {
			EditNoteViewController *editNoteViewController = [[EditNoteViewController alloc] initWithNibName:@"EditNoteViewController" bundle:nil];
			editNoteViewController.note = note;
			[self.navigationController pushViewController:editNoteViewController animated:YES];
			[editNoteViewController release];
		}
	}
}

- (IBAction)editNotesButtonPressed {
	[self.notesBrowserTableViewController.tableView setEditing:(!self.notesBrowserTableViewController.tableView.editing) animated:YES];
	
	if (self.notesBrowserTableViewController.tableView.editing) {
		self.navigationItem.leftBarButtonItem = self.editNoteDoneBarButtonItem;
		self.navigationItem.rightBarButtonItem.enabled = NO;	// Disable "Add"
		self.searchDisplayController.searchBar.userInteractionEnabled = NO;		// enable Search bar
		self.searchDisplayController.searchBar.alpha = 0.8;
		if ([self respondsToSelector:@selector(setModalInPopover:)]) {
			// prevent closing the popover in edit mode
			[self setModalInPopover:YES];
		}
	}
	else {
		self.navigationItem.leftBarButtonItem = self.editNoteBarButtonItem;
		self.navigationItem.rightBarButtonItem.enabled = YES;	// enable "Add"
		self.searchDisplayController.searchBar.userInteractionEnabled = YES;	// disable Search bar
		self.searchDisplayController.searchBar.alpha = 1.0;
		if ([self respondsToSelector:@selector(setModalInPopover:)]) {
			// prevent closing the popover in edit mode
			[self setModalInPopover:NO];
		}
	}
}

- (IBAction)addNoteButtonPressed {
	Note *newNote = [Note createAndSaveNewEmptyNote];
	self.notesBrowserTableViewController.selectedNoteID = [[[newNote objectID] URIRepresentation] absoluteString];
	[self.notesBrowserTableViewController selectSelectedNote];
	
	[self displayNoteEditorWithNote:newNote];
}


#pragma mark -
#pragma mark NotesBrowserTableViewControllerDelegate methods

- (void)didSelectNote:(Note *)note {
	[self displayNoteEditorWithNote:note];
}


#pragma mark -
#pragma mark SearchDatabaseRequesterDelegate methods

- (void)searchCompleteWithResult:(LSLocaytaSearchResult *)searchResult {
	DLog(@"searchResult: %@", searchResult);
	self.currentSearchResult = searchResult;
	
	[self updateSearchSummary:searchResult];
	[self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
	[aSearchBar resignFirstResponder];
}


#pragma mark -
#pragma mark UISearchDisplayDelegate methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	DLog(@"shouldReloadTableForSearchString: \"%@\"", searchString);
	
	[self searchWithText:searchString sortBy:controller.searchBar.selectedScopeButtonIndex];
	
	return NO; // search is async
}


#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	DLog(@"selectedScope = %d", selectedScope);
	[self searchWithText:self.searchDisplayController.searchBar.text sortBy:selectedScope];
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.currentSearchResult.results count];
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	
	static NSString *CellIdentifier = @"SearchQueryResultCell";
	
	cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)  {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSDictionary *result = [self.currentSearchResult.results objectAtIndex:indexPath.row];
	NSDictionary *fields = [result valueForKey:@"fields"];
	
	cell.textLabel.text = [[fields valueForKey:@"title"] objectAtIndex:0];
	NSDate *lastUpdated = [NSDate dateWithTimeIntervalSinceReferenceDate:[[[fields valueForKey:@"lastUpdated"] objectAtIndex:0] doubleValue]];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", lastUpdated];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (currentSearchResult) {
		NSDictionary *result = [currentSearchResult.results objectAtIndex:indexPath.row];
		NSDictionary *fields = [result valueForKey:@"fields"];
		NSString *objectID = [[fields valueForKey:@"id"] objectAtIndex:0];
		
		ZAssert(objectID != nil, @"Result contains no 'id' field");
		
		Note *note = [Note noteForObjectID:objectID];
		[self displayNoteEditorWithNote:note];
		
		self.notesBrowserTableViewController.selectedNoteID = objectID;
		[self.notesBrowserTableViewController selectSelectedNote];
	}
}


#pragma mark -
#pragma mark View Management

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
	
	double tableHeight = self.view.frame.size.height - 44.0;
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		// iPhone UI
		
		tableHeight -= 44.0;
		bottomToolbar.hidden = NO;
		
		// Populate bottom toolbar with buttons
		UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
		
		UIBarButtonItem *flexibleBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																							   target:nil
																							   action:nil];
		UIBarButtonItem *settingsBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_icon.png"]
																				  style:UIBarButtonItemStylePlain
																				 target:self
																				 action:@selector(settingsButtonAction)];
		bottomToolbar.items = [NSArray arrayWithObjects:infoBarButtonItem, flexibleBarButtonItem, settingsBarButtonItem, nil];
		[settingsBarButtonItem release];
		[flexibleBarButtonItem release];
        [infoBarButtonItem release];
		
		double labelWidth = bottomToolbar.frame.size.width - 100.0;
		CGRect frame = CGRectMake(50.0, 0.0, labelWidth, bottomToolbar.frame.size.height);
		UILabel *versionLabel = [[UILabel alloc] initWithFrame:frame];
		versionLabel.text = [NSString stringWithFormat:@"version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
		versionLabel.font = [UIFont systemFontOfSize:11.0];
		versionLabel.textColor = [UIColor lightTextColor];
		versionLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];	// transparent
		versionLabel.textAlignment = UITextAlignmentCenter;
		versionLabel.shadowColor = [UIColor darkTextColor];
		versionLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[bottomToolbar addSubview:versionLabel];
		[versionLabel release];
	}
	else {
		// iPad UI
		
		// Force search scope bar to be always below the search bar
		// This is a private API so might be rejected...
		if ([self.searchDisplayController.searchBar respondsToSelector:@selector(setCombinesLandscapeBars:)]) {
			objc_msgSend(self.searchDisplayController.searchBar, @selector(setCombinesLandscapeBars:), NO);
		}
	}

	
	self.notesBrowserTableViewController.view.frame = CGRectMake(0.0,
																 44.0,
																 self.view.frame.size.width,
																 tableHeight);
	[self.view addSubview:self.notesBrowserTableViewController.view];
	[self.view sendSubviewToBack:self.notesBrowserTableViewController.view];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchIndexDidUpdate) name:kSearchDatabaseDidUpdateNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[notesBrowserTableViewController viewWillAppear:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[notesBrowserTableViewController viewDidAppear:animated];
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[notesBrowserTableViewController viewWillDisappear:animated];
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[notesBrowserTableViewController viewDidDisappear:animated];
    [super viewDidDisappear:animated];
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
}


- (void)dealloc {
	[bottomToolbar release];
	[currentSearchResult release];
	[editNoteBarButtonItem release];
	[editNoteDoneBarButtonItem release];
	[notesBrowserTableViewController release];
	[searchSummaryLabel release];
	[searchSummaryView release];
	
    [super dealloc];
}


@end
