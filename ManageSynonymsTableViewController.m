//
//  ManageSynonymsTableViewController.m
//  LocNotes
//
//  Created by Chris Miles on 30/09/10.
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

#import "ManageSynonymsTableViewController.h"

@implementation ManageSynonymsTableViewController

@synthesize editSynonymCell;
@synthesize sectionFooteriPadView, sectionFooteriPhoneView;
@synthesize synonyms;


#pragma mark -
#pragma mark Initialization

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if ((self = [super initWithStyle:style])) {
    }
    return self;
}
*/


#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
#pragma mark EditSynonymCellDelegate methods

- (void)editSynonymCell:(EditSynonymCell *)cell newSynonyms:(NSArray *)newSynonyms forTerm:(NSString *)term {
	//DLog(@"%@: %@ = %@", cell, term, newSynonyms);
	
	if ([term length] > 0 && [newSynonyms count] > 0) {
		NSArray *newRow = [NSArray arrayWithObject:term];
		newRow = [newRow arrayByAddingObjectsFromArray:newSynonyms];
		
		NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
		[self.synonyms replaceObjectAtIndex:indexPath.row withObject:newRow];
		
		DLog(@"synonyms = %@", self.synonyms);
	}
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.synonyms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"ManageSynonymsTableViewCell";
    
    EditSynonymCell *cell = (EditSynonymCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		
		// Create an instance of StatsTableCell by loading it from the NIB
		[[NSBundle mainBundle] loadNibNamed:@"EditSynonymCell" owner:self options:nil];
		cell = self.editSynonymCell;
		cell.delegate = self;
    }
	
    // Configure the cell...
	NSArray *row = [self.synonyms objectAtIndex:indexPath.row];
	[cell configureForTerm:[row objectAtIndex:0] synonyms:[row subarrayWithRange:NSMakeRange(1, [row count]-1)]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"editingStyle: %d forRowAtIndexPath: %@", editingStyle, indexPath);
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[self.synonyms removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
		DLog(@"synonyms = %@", self.synonyms);
	}
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	CGFloat height = 0.0;
	
	if (section == 0) {
		height = 44.0;
	}
	
	return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *footerView = nil;
	
	if (section == 0) {
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			footerView = self.sectionFooteriPadView;
		}
		else {
			footerView = self.sectionFooteriPhoneView;
		}
		
		footerView.frame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	}
	
	return footerView;
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	
	self.sectionFooteriPadView = nil;
	self.sectionFooteriPhoneView = nil;
}


- (void)dealloc {
	[editSynonymCell release];
	[synonyms release];

    [super dealloc];
}


@end

