//
//  EditSynonymCell.m
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

#import "EditSynonymCell.h"

#define kTermTextFieldTag		1
#define kSynonymsTextFieldTag	2


@implementation EditSynonymCell

@synthesize delegate;
@synthesize synonymsTextField, termTextField;

- (void)updateDelegate {
	NSString *term = self.termTextField.text;
	NSMutableArray *synonyms = [NSMutableArray array];
	for (NSString *syn in [self.synonymsTextField.text componentsSeparatedByString:@","]) {
		if ([syn length] > 0) {
			[synonyms addObject:[syn stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
		}
	}
	
	//DLog(@"\"%@\" = \"%@\"", term, synonyms);
	
	[delegate editSynonymCell:self newSynonyms:synonyms forTerm:term];
}

- (IBAction)valueChanged {
	[self updateDelegate];
}

- (BOOL)becomeFirstResponder {
	[self.termTextField becomeFirstResponder];
	
	return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	[self.termTextField resignFirstResponder];
	[self.synonymsTextField resignFirstResponder];
	
	return [super resignFirstResponder];
}

- (void)configureForTerm:(NSString *)term synonyms:(NSArray *)synonyms {
	self.termTextField.text = term;
	self.synonymsTextField.text = [synonyms componentsJoinedByString:@", "];
}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField.tag == kTermTextFieldTag) {
		[textField resignFirstResponder];
		[synonymsTextField becomeFirstResponder];
	}
	else if (textField.tag == kSynonymsTextFieldTag) {
		[textField resignFirstResponder];
	}
	
	return YES;
}


#pragma mark -
#pragma mark UITableViewCell methods

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
	[synonymsTextField release];
	[termTextField release];
	
    [super dealloc];
}


@end
