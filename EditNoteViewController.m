//
//  EditNoteViewController.m
//  LocNotes
//
//  Created by Chris Miles on 24/05/10.
//
//  Copyright (c) Locayta Limited 2010.
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

#import "EditNoteViewController.h"
#import "InfoViewController.h"
#import "Note+Management.h"
#import "SettingsTableViewController.h"
#import "ShareViewTableController.h"

#define kTitleLength 50


@implementation EditNoteViewController

@synthesize contentTextView;
@synthesize currentPopoverController;
@synthesize ipadToolbar;
@synthesize note;
@synthesize splitViewPopoverController;


- (void)addShareButtonToNavbar {
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				 target:self
																				 action:@selector(shareButtonAction:)];
	self.navigationItem.rightBarButtonItem = shareButton;
	[shareButton release];
}

- (void)dismissSplitViewPopoverController {
	[self.splitViewPopoverController dismissPopoverAnimated:YES];
	self.splitViewPopoverController = nil;
}

- (void)dismissCurrentPopover {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad UI
		[self.currentPopoverController dismissPopoverAnimated:YES];
		self.currentPopoverController = nil;
	}
}

- (void)settingsButtonAction:(UIBarButtonItem *)button {
	SettingsTableViewController *settingsTableViewController = [[SettingsTableViewController alloc] initWithNibName:@"SettingsTableViewController" bundle:nil];
	settingsTableViewController.delegate = self;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad UI
		[self dismissSplitViewPopoverController];
		
		BOOL dismissOnly = NO;
		if (self.currentPopoverController != nil) {
			if ([self.currentPopoverController.contentViewController isKindOfClass:[settingsTableViewController class]]) {
				dismissOnly = YES;
			}
			[self dismissCurrentPopover];
		}
		
		if (!dismissOnly) {
			Class classPopoverController = NSClassFromString(@"UIPopoverController");
			if (classPopoverController) {
				UIPopoverController *popoverController = [[classPopoverController alloc] initWithContentViewController:settingsTableViewController];
				popoverController.delegate = self;
				popoverController.popoverContentSize = CGSizeMake(320.0, 160.0);
				[popoverController presentPopoverFromBarButtonItem:button
										  permittedArrowDirections:UIPopoverArrowDirectionAny
														  animated:YES];
				
				self.currentPopoverController = popoverController;
				
				[popoverController release];
			}
		}
	}
	else {
		// iPhone UI
		ALog(@"TODO");
		
//		UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share note"
//																	  delegate:self
//															 cancelButtonTitle:@"Cancel"
//														destructiveButtonTitle:nil
//															 otherButtonTitles:@"Email to someone", nil];
//		[shareActionSheet showInView:self.view];
//		[shareActionSheet release];
	}
	
	[settingsTableViewController release];
}

- (void)shareButtonAction:(UIBarButtonItem *)button {
	if (nil == self.note) {
		return;
	}
	
	ShareViewTableController *shareViewTableController = [[ShareViewTableController alloc] initWithNibName:@"ShareViewTableController" bundle:nil];
	shareViewTableController.note = self.note;
	shareViewTableController.delegate = self;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad UI
		[self dismissSplitViewPopoverController];
		
		BOOL dismissOnly = NO;
		if (self.currentPopoverController != nil) {
			if ([self.currentPopoverController.contentViewController isKindOfClass:[shareViewTableController class]]) {
				dismissOnly = YES;
			}
			[self dismissCurrentPopover];
		}
		
		if (!dismissOnly) {
			Class classPopoverController = NSClassFromString(@"UIPopoverController");
			if (classPopoverController) {
				UIPopoverController *popoverController = [[classPopoverController alloc] initWithContentViewController:shareViewTableController];
				popoverController.delegate = self;
				popoverController.popoverContentSize = CGSizeMake(320.0, 120.0);
				[popoverController presentPopoverFromBarButtonItem:button
										  permittedArrowDirections:UIPopoverArrowDirectionAny
														  animated:YES];
				
				self.currentPopoverController = popoverController;
				
				[popoverController release];
			}
		}
	}
	else {
		// iPhone UI
		
		UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share note"
																	  delegate:self
															 cancelButtonTitle:@"Cancel"
														destructiveButtonTitle:nil
															 otherButtonTitles:@"Email to someone", nil];
		[shareActionSheet showInView:self.view];
		[shareActionSheet release];
	}

	[shareViewTableController release];
	
}

- (void)doneButtonAction {
	// Hide the keyboard
	[self.contentTextView resignFirstResponder];
}

- (void)infoButtonAction {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// iPad UI
		[self dismissSplitViewPopoverController];
		if (self.currentPopoverController != nil) {
			[self dismissCurrentPopover];
		}
	}
	
	InfoViewController *infoViewController = [[InfoViewController alloc] initWithNibName:@"InfoViewController" bundle:nil];
	infoViewController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentModalViewController:infoViewController animated:YES];
	[infoViewController release];
}

- (void)saveNote {
	if (![self.contentTextView.text isEqualToString:self.note.content]) {
		self.note.content = self.contentTextView.text;
		if (![self.contentTextView.text isEqualToString:@""]) {
            NSString *trimmedContent = [self.contentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			self.note.title = [[trimmedContent substringToIndex:([trimmedContent length] < kTitleLength ? [trimmedContent length] : kTitleLength)] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
		}
		[self.note saveNote];
	}
}

- (void)updateViewForNote {
	if (self.note) {
		contentTextView.hidden = NO;
				
		// Show keyboard & start editing immediately if no content (i.e. new note)
		if ([self.note.content length] == 0) {
			[self.contentTextView becomeFirstResponder];
		}
		else {
			// Otherwise default to keyboard hidden
			[self.contentTextView resignFirstResponder];
		}
		
		self.contentTextView.text = self.note.content;
	}
	else {
		contentTextView.hidden = YES;
	}
}

- (void)changeNoteBeingEdited:(Note *)aNote {
	[self saveNote];
	
	self.note = aNote;
	[self updateViewForNote];
	
	[self dismissSplitViewPopoverController];
}

- (void)clear {
	self.note = nil;
	self.contentTextView.text = nil;
	
	[self.contentTextView resignFirstResponder];
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
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// Size and add a navigation bar
		CGRect frame = self.ipadToolbar.frame;
		frame.size.width = self.view.bounds.size.width;
		self.ipadToolbar.frame = frame;
		
		[self.view addSubview:self.ipadToolbar];
		
		// Set up toolbar buttons
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																					   target:nil
																					   action:nil];
		UIBarButtonItem *fixedSpace1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																					   target:nil
																					   action:nil];
		fixedSpace1.width = 20.0;
		UIBarButtonItem *fixedSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
																					target:nil
																					action:nil];
		fixedSpace2.width = 15.0;
		
		UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings_icon.png"]
																							   style:UIBarButtonItemStylePlain
																							  target:self
																							  action:@selector(settingsButtonAction:)];
		
		UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																					 target:self
																					 action:@selector(shareButtonAction:)];
		
		UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
		infoButton.bounds = CGRectMake(0, 0, 35.0, 45.0);
        [infoButton addTarget:self action:@selector(infoButtonAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
		
		ipadToolbar.items = [NSArray arrayWithObjects:flexibleSpace, settingsButton, fixedSpace1, shareButton, fixedSpace2, infoBarButtonItem, nil];
		
        [infoBarButtonItem release];
		[settingsButton release];
		[shareButton release];
		[fixedSpace1 release];
		[fixedSpace2 release];
		[flexibleSpace release];
		
		// Shift & resize text view to fit beneath nav bar
		frame = self.contentTextView.frame;
		frame.origin.y = self.ipadToolbar.bounds.size.height;
		frame.size.height -= self.ipadToolbar.bounds.size.height;
		self.contentTextView.frame = frame;
	}
	else {
		// iPhone UI
		[self addShareButtonToNavbar];
	}


	// Subscribe to keyboard visible notifications (so we can adjust
	//	visible scroll view appropriately
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardDidShow:)
												 name:UIKeyboardDidShowNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
	
	[self updateViewForNote];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self saveNote];
	
    [super viewWillDisappear:animated];
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark UITextViewDelegate methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	DLog(@"replacementText: \"%@\"", text);
	
	// Cancel any pending delayed saves.
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveNote) object:nil];
	
	NSRange alphaNumericRange = [text rangeOfCharacterFromSet:[NSCharacterSet alphanumericCharacterSet]];
	if (![text isEqualToString:@""] && alphaNumericRange.location == NSNotFound) {
		// Save note (and update search index) whenever a non-alphanumeric key is typed
		[self saveNote];
	}
	else {
		// Otherwise schedule a delayed save.
		[self performSelector:@selector(saveNote) withObject:nil afterDelay:1.0];
	}

	
	return YES;
}



#pragma mark -
#pragma mark UISplitViewControllerDelegate methods

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc {
	barButtonItem.title = @"Notes";

    NSMutableArray *items = [[self.ipadToolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [ipadToolbar setItems:items animated:YES];
    [items release];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button {
    NSMutableArray *items = [[ipadToolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [ipadToolbar setItems:items animated:YES];
    [items release];
}

- (void)splitViewController:(UISplitViewController *)svc popoverController:(UIPopoverController *)pc willPresentViewController:(UIViewController *)aViewController {
	[self dismissCurrentPopover];
	if (pc.popoverVisible) {
		[pc dismissPopoverAnimated:YES];
		self.splitViewPopoverController = nil;
	}
	else {
		self.splitViewPopoverController = pc;
	}
}


#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send.
// Shows alert dialog if there was an error.
- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error
{
	if (error) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Error"
														message:[error localizedDescription]
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	else switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
			//break;
			
		default:
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Error"
															message:@"Sending Failed – Unknown Error  "
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
			
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark UIPopoverControllerDelegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.currentPopoverController = nil;
}


#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {		// "Email to someone"
		// We can use the ShareViewTableController to display the picker and
		// send the message, although we don't actually need to display it.
		ShareViewTableController *shareViewTableController = [[ShareViewTableController alloc] initWithNibName:@"ShareViewTableController" bundle:nil];
		shareViewTableController.delegate = self;
		shareViewTableController.note = self.note;
		[shareViewTableController sendNoteByEmail];
		[shareViewTableController release];
	}
}


#pragma mark -
#pragma mark Keyboard Notifications

- (void)keyboardDidShow:(NSNotification *) notification {
	// Correct the scroll area to take keyboard into account
	CGRect keyboardBounds = [[[notification userInfo] objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue];
	
	// Resize text view
	CGRect frame = self.contentTextView.frame;
	contentTextViewOriginalHeight = frame.size.height;
	frame.size.height -= keyboardBounds.size.height;
	
	[UIView beginAnimations:nil context:nil];
	self.contentTextView.frame = frame;
	[UIView commitAnimations];
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		// iPhone UI mode - show a Done button, used to dismiss the keyboard
		UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																						target:self
																						action:@selector(doneButtonAction)];
		[self.navigationItem setRightBarButtonItem:doneButtonItem animated:YES];
		[doneButtonItem release];
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	// Resize text view back to original height
	if (contentTextViewOriginalHeight > 0.0) {
		CGRect frame = self.contentTextView.frame;
		frame.size.height = contentTextViewOriginalHeight;
		self.contentTextView.frame = frame;
	}
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		// iPhone UI mode - remove Done button
		[self addShareButtonToNavbar];
	}
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	[contentTextView release];
	[currentPopoverController release];
	[ipadToolbar release];
	[note release];
	[splitViewPopoverController release];
	
    [super dealloc];
}


@end
