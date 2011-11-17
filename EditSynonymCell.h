//
//  EditSynonymCell.h
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

#import <UIKit/UIKit.h>

@class EditSynonymCell;

@protocol EditSynonymCellDelegate
- (void)editSynonymCell:(EditSynonymCell *)editSynonymCell newSynonyms:(NSArray *)synonyms forTerm:(NSString *)term;
@end


@interface EditSynonymCell : UITableViewCell <UITextFieldDelegate> {
	id<EditSynonymCellDelegate>		delegate;
}

@property (nonatomic, assign)	id<EditSynonymCellDelegate>	delegate;

@property (nonatomic, retain)	IBOutlet	UITextField		*synonymsTextField;
@property (nonatomic, retain)	IBOutlet	UITextField		*termTextField;

- (void)updateDelegate;
- (IBAction)valueChanged;
- (BOOL)becomeFirstResponder;
- (BOOL)resignFirstResponder;
- (void)configureForTerm:(NSString *)term synonyms:(NSArray *)synonyms;

@end
