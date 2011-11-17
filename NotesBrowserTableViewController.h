//
//  NotesBrowserTableViewController.h
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

#import <UIKit/UIKit.h>
#import "Note.h"

@protocol NotesBrowserTableViewControllerDelegate;


@interface NotesBrowserTableViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
	id<NotesBrowserTableViewControllerDelegate> delegate;
	NSDateFormatter						*localDateFormatter;
	NSFetchedResultsController			*noteFetchedResultsController;
	NSString							*selectedNoteID;
}

@property (nonatomic, assign)	IBOutlet	id<NotesBrowserTableViewControllerDelegate> delegate;
@property (nonatomic, retain)				NSDateFormatter					*localDateFormatter;
@property (nonatomic, retain)				NSFetchedResultsController		*noteFetchedResultsController;
@property (nonatomic, retain)				NSString						*selectedNoteID;

- (void)selectSelectedNote;
- (NSFetchedResultsController *)fetchedResultsControllerForNoteWithDelegate:(id)controllerDelegate;

@end


@protocol NotesBrowserTableViewControllerDelegate
- (void)didSelectNote:(Note *)note;
@end
