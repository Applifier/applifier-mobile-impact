/*
 Copyright (c) 2010, Stig Brautaset.
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:

   Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   Neither the name of the the author nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ApplifierImpactSBJsonStreamParserState.h"
#import "ApplifierImpactSBJsonStreamParser.h"

#define SINGLETON \
+ (id)sharedInstance { \
    static id state = nil; \
    if (!state) { \
        @synchronized(self) { \
            if (!state) state = [[self alloc] init]; \
        } \
    } \
    return state; \
}

@implementation ApplifierImpactSBJsonStreamParserState

+ (id)sharedInstance { return nil; }

- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return NO;
}

- (ApplifierImpactSBJsonStreamParserStatus)parserShouldReturn:(ApplifierImpactSBJsonStreamParser*)parser {
	return ApplifierImpactSBJsonStreamParserWaitingForData;
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {}

- (BOOL)needKey {
	return NO;
}

- (NSString*)name {
	return @"<aaiie!>";
}

- (BOOL)isError {
    return NO;
}

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateStart

SINGLETON

- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_array_start || token == sbjson_token_object_start;
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {

	ApplifierImpactSBJsonStreamParserState *state = nil;
	switch (tok) {
		case sbjson_token_array_start:
			state = [ApplifierImpactSBJsonStreamParserStateArrayStart sharedInstance];
			break;

		case sbjson_token_object_start:
			state = [ApplifierImpactSBJsonStreamParserStateObjectStart sharedInstance];
			break;

		case sbjson_token_array_end:
		case sbjson_token_object_end:
			if (parser.supportMultipleDocuments)
				state = parser.state;
			else
				state = [ApplifierImpactSBJsonStreamParserStateComplete sharedInstance];
			break;

		case sbjson_token_eof:
			return;

		default:
			state = [ApplifierImpactSBJsonStreamParserStateError sharedInstance];
			break;
	}


	parser.state = state;
}

- (NSString*)name { return @"before outer-most array or object"; }

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateComplete

SINGLETON

- (NSString*)name { return @"after outer-most array or object"; }

- (ApplifierImpactSBJsonStreamParserStatus)parserShouldReturn:(ApplifierImpactSBJsonStreamParser*)parser {
	return ApplifierImpactSBJsonStreamParserComplete;
}

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateError

SINGLETON

- (NSString*)name { return @"in error"; }

- (ApplifierImpactSBJsonStreamParserStatus)parserShouldReturn:(ApplifierImpactSBJsonStreamParser*)parser {
	return ApplifierImpactSBJsonStreamParserError;
}

- (BOOL)isError {
    return YES;
}

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateObjectStart

SINGLETON

- (NSString*)name { return @"at beginning of object"; }

- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_string:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [ApplifierImpactSBJsonStreamParserStateObjectGotKey sharedInstance];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateObjectGotKey

SINGLETON

- (NSString*)name { return @"after object key"; }

- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_keyval_separator;
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [ApplifierImpactSBJsonStreamParserStateObjectSeparator sharedInstance];
}

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateObjectSeparator

SINGLETON

- (NSString*)name { return @"as object value"; }

- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_start:
		case sbjson_token_array_start:
		case sbjson_token_true:
		case sbjson_token_false:
		case sbjson_token_null:
		case sbjson_token_number:
		case sbjson_token_string:
			return YES;
			break;

		default:
			return NO;
			break;
	}
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [ApplifierImpactSBJsonStreamParserStateObjectGotValue sharedInstance];
}

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateObjectGotValue

SINGLETON

- (NSString*)name { return @"after object value"; }

- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_separator:
			return YES;
			break;
		default:
			return NO;
			break;
	}
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [ApplifierImpactSBJsonStreamParserStateObjectNeedKey sharedInstance];
}


@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateObjectNeedKey

SINGLETON

- (NSString*)name { return @"in place of object key"; }

- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
    return sbjson_token_string == token;
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [ApplifierImpactSBJsonStreamParserStateObjectGotKey sharedInstance];
}

- (BOOL)needKey {
	return YES;
}

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateArrayStart

SINGLETON

- (NSString*)name { return @"at array start"; }

- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_object_end:
		case sbjson_token_keyval_separator:
		case sbjson_token_separator:
			return NO;
			break;

		default:
			return YES;
			break;
	}
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [ApplifierImpactSBJsonStreamParserStateArrayGotValue sharedInstance];
}

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateArrayGotValue

SINGLETON

- (NSString*)name { return @"after array value"; }


- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	return token == sbjson_token_array_end || token == sbjson_token_separator;
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	if (tok == sbjson_token_separator)
		parser.state = [ApplifierImpactSBJsonStreamParserStateArrayNeedValue sharedInstance];
}

@end

#pragma mark -

@implementation ApplifierImpactSBJsonStreamParserStateArrayNeedValue

SINGLETON

- (NSString*)name { return @"as array value"; }


- (BOOL)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldAcceptToken:(sbjson_token_t)token {
	switch (token) {
		case sbjson_token_array_end:
		case sbjson_token_keyval_separator:
		case sbjson_token_object_end:
		case sbjson_token_separator:
			return NO;
			break;

		default:
			return YES;
			break;
	}
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser shouldTransitionTo:(sbjson_token_t)tok {
	parser.state = [ApplifierImpactSBJsonStreamParserStateArrayGotValue sharedInstance];
}

@end

