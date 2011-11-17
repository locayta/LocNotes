//
//  Note+Management.m
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

#import "Note+Management.h"
#import "AppDelegate_Shared.h"
#import "SearchDatabaseUpdater.h"

@implementation Note ( Management )

+ (id)createAndSaveNewEmptyNote {
	AppDelegate_Shared *appDelegate = [[UIApplication sharedApplication] delegate];
	
	Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note"
													   inManagedObjectContext:appDelegate.managedObjectContext];
	note.title = @"Untitled";
	note.content = @"";
	
	[note saveNote];
	
	return note;
}

+ (Note *)noteForObjectID:(NSString *)objectIDString {
	NSManagedObjectID *objectID = [[[AppDelegate_Shared sharedAppDelegate] persistentStoreCoordinator]
								   managedObjectIDForURIRepresentation:[NSURL URLWithString:objectIDString]];
//	Note *note = (Note *)[[[AppDelegate_Shared sharedAppDelegate] managedObjectContext] objectWithID:objectID];
	Note *note = (Note *)[[[AppDelegate_Shared sharedAppDelegate] managedObjectContext] objectRegisteredForID:objectID];
	return note;
}

+ (BOOL)deleteNote:(Note *)note error:(NSError **)anError {
	AppDelegate_Shared *appDelegate = [[UIApplication sharedApplication] delegate];
	NSString *noteObjectID = [[[note objectID] URIRepresentation] absoluteString];
	
	[appDelegate.managedObjectContext deleteObject:note];
	
	if (![appDelegate.managedObjectContext save:anError]) {
		// Save failed
		ALog(@"Error %@", [*anError localizedDescription]);
		return NO;
	}
	else {
		// Save succeeded, so update search database
		[appDelegate.searchDatabaseUpdater deleteNoteWithID:noteObjectID];
	}
	
	return YES;
}

- (void)saveNote {
	// Save out to the persistent store
	self.lastUpdated = [NSDate date];
	
	// Save to core data
	AppDelegate_Shared *appDelegate = [[UIApplication sharedApplication] delegate];
	NSError *error = nil;
	if (![appDelegate.managedObjectContext save:&error]) {
		// Save failed
		ALog(@"Error %@", [error localizedDescription]);
	}
	else {
		// Save succeeded, so update search database
		[appDelegate.searchDatabaseUpdater updateSearchDatabaseForNote:self];
	}
}

@end
