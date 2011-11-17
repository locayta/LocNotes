//
//  AppDelegate_Pad.h
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
#import "AppDelegate_Shared.h"

@class EditNoteViewController;
@class NotesBrowserTableViewController;

@interface AppDelegate_Pad : AppDelegate_Shared {
	EditNoteViewController			*editNoteViewController;
	UISplitViewController			*mainSplitViewController;
	NotesBrowserTableViewController	*notesBrowserTableViewController;
}

@property (nonatomic, retain)	IBOutlet	EditNoteViewController			*editNoteViewController;
@property (nonatomic, retain)	IBOutlet	UISplitViewController			*mainSplitViewController;
@property (nonatomic, retain)	IBOutlet	NotesBrowserTableViewController	*notesBrowserTableViewController;

@end

