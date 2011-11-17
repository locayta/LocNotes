//
//  NotesBrowserViewController.h
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

#import <UIKit/UIKit.h>
#import "NotesBrowserTableViewController.h"
#import "SearchDatabaseRequester.h"

@class LSLocaytaSearchResult;
@class NotesBrowserTableViewController;

@interface NotesBrowserViewController : UIViewController <NotesBrowserTableViewControllerDelegate, UISearchDisplayDelegate, SearchDatabaseRequesterDelegate> {
	UIToolbar							*bottomToolbar;
	LSLocaytaSearchResult				*currentSearchResult;
	UIBarButtonItem						*editNoteBarButtonItem;
	UIBarButtonItem						*editNoteDoneBarButtonItem;
	NotesBrowserTableViewController		*notesBrowserTableViewController;
	UILabel								*searchSummaryLabel;
	UIView								*searchSummaryView;
}

@property (nonatomic, retain)	IBOutlet	UIToolbar							*bottomToolbar;
@property (nonatomic, retain)				LSLocaytaSearchResult				*currentSearchResult;
@property (nonatomic, retain)	IBOutlet	UIBarButtonItem						*editNoteBarButtonItem;
@property (nonatomic, retain)	IBOutlet	UIBarButtonItem						*editNoteDoneBarButtonItem;
@property (nonatomic, retain)	IBOutlet	NotesBrowserTableViewController		*notesBrowserTableViewController;
@property (nonatomic, retain)	IBOutlet	UILabel								*searchSummaryLabel;
@property (nonatomic, retain)	IBOutlet	UIView								*searchSummaryView;

- (IBAction)editNotesButtonPressed;
- (IBAction)addNoteButtonPressed;

@end
