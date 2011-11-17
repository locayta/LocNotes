//
//  SearchDatabaseRequester.m
//  LocNotes
//
//  Created by Chris Miles on 8/06/10.
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

#import "SearchDatabaseRequester.h"

#import "AppDelegate_Shared.h"

@implementation SearchDatabaseRequester

@synthesize currentSearchQuery;
@synthesize currentSearchRequest;
@synthesize databasePath;
@synthesize delegate;

- (void)searchWithText:(NSString *)searchText sortBy:(SearchSortBy)sortBy {
	DLog(@"searchText: \"%@\"  sortBy:%d", searchText, sortBy);
	
	[self cancel];
	
	NSString *trimmed = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ([trimmed length] == 0) {
		return;
	}
	
	LSLocaytaSearchRequest *searchRequest = [[LSLocaytaSearchRequest alloc] initWithDatabasePath:self.databasePath
																						delegate:self];
	self.currentSearchRequest = searchRequest;
	[searchRequest release];

	// Set the sort order
	NSArray *sortOrderArray = nil;		// default to sort by relevance
	if (sortBy == SearchSortByTitle) {
		// Sort by title field (textslot=1) ascending
		sortOrderArray = [NSArray arrayWithObject:@"+1"];
	}
	else if (sortBy == SearchSortByDate) {
		// Sort by lastUpdated field (numericslot=2) descending
		sortOrderArray = [NSArray arrayWithObject:@"-2"];
	}
	self.currentSearchRequest.sortOrder = sortOrderArray;
	
	BOOL enableAutoSpellCorrection = [[AppDelegate_Shared sharedAppDelegate] enableAutoSpellCorrection];
	if (enableAutoSpellCorrection) {
		[self.currentSearchRequest setSpellCorrectionMethod:LSLocaytaSearchRequestSpellCorrectionMethodAuto];
	}
	else {
		[self.currentSearchRequest setSpellCorrectionMethod:LSLocaytaSearchRequestSpellCorrectionMethodNone];
	}
	
	LSLocaytaSearchQuery *searchQuery = [LSLocaytaSearchQuery queryWithQueryString:trimmed];
	self.currentSearchQuery = searchQuery;
	
	NSInteger docsPerPage = 20;
	[self.currentSearchRequest searchWithQuery:searchQuery topDocIndex:0 docsPerPage:docsPerPage];
}

- (void)cancel {
	if (self.currentSearchRequest) {
		[self.currentSearchRequest cancel];
		self.currentSearchRequest = nil;
		self.currentSearchQuery = nil;
	}
}

- (id)initWithDatabasePath:(NSString *)aDatabasePath {
    if ((self = [super init])) {
		self.databasePath = aDatabasePath;
		
	}
	return self;
}

- (void)dealloc {
	[currentSearchQuery release];
	[currentSearchRequest release];
	[databasePath release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark LSLocaytaSearchRequestDelegate methods

- (void)locaytaSearchRequest:(LSLocaytaSearchRequest *)searchRequest didCompleteWithResult:(LSLocaytaSearchResult *)searchResult {
	DLog(@"searchResult: %@", searchResult);
	
	DLog(@" * documentCount: %d", [searchRequest documentCount]);
	DLog(@" * requestedQueryString: \"%@\"", searchResult.requestedQueryString);
	DLog(@" * wasAutoSpellCorrected: \"%@\"", (searchResult.wasAutoSpellCorrected ? @"YES" : @"NO"));
	DLog(@" * correctedQueryString: \"%@\"", searchResult.correctedQueryString);
	DLog(@" * suggestedQueryString: \"%@\"", searchResult.suggestedQueryString);
	DLog(@" * itemCount: %d", searchResult.itemCount);
	DLog(@" * matchCount (exact=%@): %d", (searchResult.matchCountExact ? @"YES" : @"NO"), searchResult.matchCount);
	DLog(@" * results: %@", searchResult.results);
	
	DLog(@"documents searchQuery: %@", [self.currentSearchQuery queryDescription]);
	
	[delegate searchCompleteWithResult:searchResult];
}

- (void)locaytaSearchRequest:(LSLocaytaSearchRequest *)searchRequest didFailWithError:(NSError *)error {
	DLog(@"error: %@", error);
	
	[delegate searchCompleteWithResult:nil];
}

@end
