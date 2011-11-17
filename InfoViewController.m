//
//  InfoViewController.m
//  LocNotes
//
//  Created by Chris Miles on 14/07/10.
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

#import "InfoViewController.h"

#define kLocaytaWebsiteURL @"http://www.locayta.com/iOS-search-engine/locayta-search-mobile/locayta-search-mobile"
#define kOpenWebBrowserSection 1
#define kOpenWebBrowserRow 0


@implementation InfoViewController

@synthesize cell1;
@synthesize copyrightCell;
@synthesize infoTableView;
@synthesize tableSections;
@synthesize titleLabel;
@synthesize versionLabel;
@synthesize websiteCell;

- (IBAction)doneButtonAction {
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tableSections count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSArray *sectionRows = [self.tableSections objectAtIndex:section];
	return [sectionRows count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
	
	NSArray *sectionRows = [self.tableSections objectAtIndex:indexPath.section];
	cell = [sectionRows objectAtIndex:indexPath.row];
	
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *sectionRows = [self.tableSections objectAtIndex:indexPath.section];
	UITableViewCell *cell = [sectionRows objectAtIndex:indexPath.row];
	
	CGFloat height = cell.bounds.size.height;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if (cell == cell1) {
			// Reduce cell1 height on iPad - fits a bit nicer
			height = height * 0.85;
		}
	}

	return height;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == kOpenWebBrowserSection && indexPath.row == kOpenWebBrowserRow) {
		return indexPath;
	}
	
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.infoTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == kOpenWebBrowserSection && indexPath.row == kOpenWebBrowserRow) {
		NSString *encodedURL = [kLocaytaWebsiteURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodedURL]];
	}
}


#pragma mark -
#pragma mark Memory Management

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
	
	NSArray *tableLayout = [NSArray arrayWithObjects:
							[NSArray arrayWithObjects:self.cell1, nil],
							[NSArray arrayWithObjects:self.websiteCell, nil],
							[NSArray arrayWithObjects:self.copyrightCell, nil],
							nil];
	self.tableSections = tableLayout;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		self.titleLabel.textColor = [UIColor grayColor];
		self.titleLabel.shadowColor = [UIColor whiteColor];
		self.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
	}
	
	versionLabel.text = [NSString stringWithFormat:@"Version %@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[infoTableView flashScrollIndicators];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
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
}


- (void)dealloc {
	[cell1 release];
	[copyrightCell release];
	[infoTableView release];
	[tableSections release];
	[titleLabel release];
	[versionLabel release];
	[websiteCell release];
	
    [super dealloc];
}


@end
