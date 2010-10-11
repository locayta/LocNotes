//
//  EditNoteViewController.h
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

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Note;

@interface EditNoteViewController : UIViewController <UISplitViewControllerDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate> {
	Note					*note;
	
	UITextView				*contentTextView;
	UIPopoverController		*currentPopoverController;
	UIToolbar				*ipadToolbar;
	UIPopoverController		*splitViewPopoverController;
	
@private
	CGFloat					contentTextViewOriginalHeight;
}

@property (nonatomic, retain)	Note					*note;

@property (nonatomic, retain)	IBOutlet	UITextView				*contentTextView;
@property (nonatomic, retain)				UIPopoverController		*currentPopoverController;
@property (nonatomic, retain)	IBOutlet	UIToolbar				*ipadToolbar;
@property (nonatomic, retain)				UIPopoverController		*splitViewPopoverController;

- (void)changeNoteBeingEdited:(Note *)aNote;
- (void)clear;

@end
