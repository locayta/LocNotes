//
//  SearchDatabaseUpdater.m
//  LocNotes
//
//  Created by Chris Miles on 26/05/10.
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

#import <LocaytaSearch/LSLocaytaSearchIndexableRecord.h>

#import "SearchDatabaseUpdater.h"
#import "AppDelegate_Shared.h"
#import "Note.h"

#define SCHEMA_PLIST_FILENAME @"notes_search_schema.plist"


@implementation SearchDatabaseUpdater

@synthesize databasePath;
@synthesize notesSearchIndexer;
@synthesize notesSearchSchema;

+ (NSString *)schemaFile {
	return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:SCHEMA_PLIST_FILENAME];

}

- (void)deleteNoteWithID:(NSString *)noteID {
	LSLocaytaSearchIndexableRecord *indexableRecord = [[LSLocaytaSearchIndexableRecord alloc] initWithSchema:self.notesSearchSchema];
	NSError *error = nil;
	if (![indexableRecord addValue:noteID forField:@"id" error:&error]) {
		@throw(error);
	}
	
	[self.notesSearchIndexer deleteRecord:indexableRecord];
	
	[indexableRecord release];
}

- (void)updateSearchDatabaseForNote:(Note *)note {
	
	LSLocaytaSearchIndexableRecord *indexableRecord = [[LSLocaytaSearchIndexableRecord alloc] initWithSchema:self.notesSearchSchema];
	NSString *objectID = [[[note objectID] URIRepresentation] absoluteString];
	NSError *error = nil;
	if (![indexableRecord addValue:objectID forField:@"id" error:&error]) {
		@throw(error);
	}
	if (![indexableRecord addValue:note.title forField:@"title" error:&error]) {
		@throw(error);
	}
	if (![indexableRecord addValue:note.content forField:@"content" error:&error]) {
		@throw(error);
	}
	NSNumber *lastUpdated = [NSNumber numberWithDouble:[note.lastUpdated timeIntervalSinceReferenceDate]];
	if (![indexableRecord addValue:lastUpdated forField:@"lastUpdated" error:&error]) {
		@throw(error);
	}

	[self.notesSearchIndexer addOrReplaceRecord:indexableRecord];
	
	[indexableRecord release];
}

- (id)initWithDatabasePath:(NSString *)aDatabasePath {
    if ((self = [super init])) {
		self.databasePath = aDatabasePath;

		LSLocaytaSearchIndexer *searchIndexer = [[LSLocaytaSearchIndexer alloc] initWithDatabasePath:self.databasePath delegate:self];
		self.notesSearchIndexer = searchIndexer;
		[searchIndexer release];
		
		NSString *schemaFile = [SearchDatabaseUpdater schemaFile];
		NSDictionary *searchSchema = [[NSDictionary alloc] initWithContentsOfFile:schemaFile];
		self.notesSearchSchema = searchSchema;
		[searchSchema release];
	}
	return self;
}

- (void)dealloc {
	[databasePath release];
	[notesSearchIndexer release];
	[notesSearchSchema release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark LSLocaytaSearchIndexerDelegate methods

- (void)locaytaSearchIndexer:(LSLocaytaSearchIndexer *)searchIndexer didUpdateWithIndexableRecords:(NSArray *)indexableRecords {
	DLog(@"successfullyIndexedRecords: %@", indexableRecords);
	[[NSNotificationCenter defaultCenter] postNotificationName:kSearchDatabaseDidUpdateNotification object:nil];
}

- (void)locaytaSearchIndexer:(LSLocaytaSearchIndexer *)searchIndexer didFailToUpdateWithIndexableRecords:(NSArray *)indexableRecords error:(NSError *)error {
	DLog(@"failedToIndexedRecords: %@ : %@", indexableRecords, error);
}

@end

