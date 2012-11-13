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

#import "ApplifierImpactSBJsonStreamParserAdapter.h"

@interface ApplifierImpactSBJsonStreamParserAdapter ()

- (void)pop;
- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser found:(id)obj;

@end



@implementation ApplifierImpactSBJsonStreamParserAdapter

@synthesize delegate;
@synthesize levelsToSkip;

#pragma mark Housekeeping

- (id)init {
	self = [super init];
	if (self) {
		keyStack = [[NSMutableArray alloc] initWithCapacity:32];
		stack = [[NSMutableArray alloc] initWithCapacity:32];
		
		currentType = ApplifierImpactSBJsonStreamParserAdapterNone;
	}
	return self;
}	


#pragma mark Private methods

- (void)pop {
	[stack removeLastObject];
	array = nil;
	dict = nil;
	currentType = ApplifierImpactSBJsonStreamParserAdapterNone;
	
	id value = [stack lastObject];
	
	if ([value isKindOfClass:[NSArray class]]) {
		array = value;
		currentType = ApplifierImpactSBJsonStreamParserAdapterArray;
	} else if ([value isKindOfClass:[NSDictionary class]]) {
		dict = value;
		currentType = ApplifierImpactSBJsonStreamParserAdapterObject;
	}
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser found:(id)obj {
	NSParameterAssert(obj);
	
	switch (currentType) {
		case ApplifierImpactSBJsonStreamParserAdapterArray:
			[array addObject:obj];
			break;

		case ApplifierImpactSBJsonStreamParserAdapterObject:
			NSParameterAssert(keyStack.count);
			[dict setObject:obj forKey:[keyStack lastObject]];
			[keyStack removeLastObject];
			break;
			
		case ApplifierImpactSBJsonStreamParserAdapterNone:
			if ([obj isKindOfClass:[NSArray class]]) {
				[delegate parser:parser foundArray:obj];
			} else {
				[delegate parser:parser foundObject:obj];
			}				
			break;

		default:
			break;
	}
}


#pragma mark Delegate methods

- (void)parserFoundObjectStart:(ApplifierImpactSBJsonStreamParser*)parser {
	if (++depth > self.levelsToSkip) {
		dict = [NSMutableDictionary new];
		[stack addObject:dict];
		currentType = ApplifierImpactSBJsonStreamParserAdapterObject;
	}
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser foundObjectKey:(NSString*)key_ {
	[keyStack addObject:key_];
}

- (void)parserFoundObjectEnd:(ApplifierImpactSBJsonStreamParser*)parser {
	if (depth-- > self.levelsToSkip) {
		id value = dict;
		[self pop];
		[self parser:parser found:value];
	}
}

- (void)parserFoundArrayStart:(ApplifierImpactSBJsonStreamParser*)parser {
	if (++depth > self.levelsToSkip) {
		array = [NSMutableArray new];
		[stack addObject:array];
		currentType = ApplifierImpactSBJsonStreamParserAdapterArray;
	}
}

- (void)parserFoundArrayEnd:(ApplifierImpactSBJsonStreamParser*)parser {
	if (depth-- > self.levelsToSkip) {
		id value = array;
		[self pop];
		[self parser:parser found:value];
	}
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser foundBoolean:(BOOL)x {
	[self parser:parser found:[NSNumber numberWithBool:x]];
}

- (void)parserFoundNull:(ApplifierImpactSBJsonStreamParser*)parser {
	[self parser:parser found:[NSNull null]];
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser foundNumber:(NSNumber*)num {
	[self parser:parser found:num];
}

- (void)parser:(ApplifierImpactSBJsonStreamParser*)parser foundString:(NSString*)string {
	[self parser:parser found:string];
}

@end
