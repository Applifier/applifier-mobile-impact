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

#import "ApplifierImpactSBJsonStreamWriterState.h"
#import "ApplifierImpactSBJsonStreamWriter.h"

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


@implementation ApplifierImpactSBJsonStreamWriterState
+ (id)sharedInstance { return nil; }
- (BOOL)isInvalidState:(ApplifierImpactSBJsonStreamWriter*)writer { return NO; }
- (void)appendSeparator:(ApplifierImpactSBJsonStreamWriter*)writer {}
- (BOOL)expectingKey:(ApplifierImpactSBJsonStreamWriter*)writer { return NO; }
- (void)transitionState:(ApplifierImpactSBJsonStreamWriter *)writer {}
- (void)appendWhitespace:(ApplifierImpactSBJsonStreamWriter*)writer {
	[writer appendBytes:"\n" length:1];
	for (NSUInteger i = 0; i < writer.stateStack.count; i++)
	    [writer appendBytes:"  " length:2];
}
@end

@implementation ApplifierImpactSBJsonStreamWriterStateObjectStart

SINGLETON

- (void)transitionState:(ApplifierImpactSBJsonStreamWriter *)writer {
	writer.state = [ApplifierImpactSBJsonStreamWriterStateObjectValue sharedInstance];
}
- (BOOL)expectingKey:(ApplifierImpactSBJsonStreamWriter *)writer {
	writer.error = @"JSON object key must be string";
	return YES;
}
@end

@implementation ApplifierImpactSBJsonStreamWriterStateObjectKey

SINGLETON

- (void)appendSeparator:(ApplifierImpactSBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation ApplifierImpactSBJsonStreamWriterStateObjectValue

SINGLETON

- (void)appendSeparator:(ApplifierImpactSBJsonStreamWriter *)writer {
	[writer appendBytes:":" length:1];
}
- (void)transitionState:(ApplifierImpactSBJsonStreamWriter *)writer {
    writer.state = [ApplifierImpactSBJsonStreamWriterStateObjectKey sharedInstance];
}
- (void)appendWhitespace:(ApplifierImpactSBJsonStreamWriter *)writer {
	[writer appendBytes:" " length:1];
}
@end

@implementation ApplifierImpactSBJsonStreamWriterStateArrayStart

SINGLETON

- (void)transitionState:(ApplifierImpactSBJsonStreamWriter *)writer {
    writer.state = [ApplifierImpactSBJsonStreamWriterStateArrayValue sharedInstance];
}
@end

@implementation ApplifierImpactSBJsonStreamWriterStateArrayValue

SINGLETON

- (void)appendSeparator:(ApplifierImpactSBJsonStreamWriter *)writer {
	[writer appendBytes:"," length:1];
}
@end

@implementation ApplifierImpactSBJsonStreamWriterStateStart

SINGLETON


- (void)transitionState:(ApplifierImpactSBJsonStreamWriter *)writer {
    writer.state = [ApplifierImpactSBJsonStreamWriterStateComplete sharedInstance];
}
- (void)appendSeparator:(ApplifierImpactSBJsonStreamWriter *)writer {
}
@end

@implementation ApplifierImpactSBJsonStreamWriterStateComplete

SINGLETON

- (BOOL)isInvalidState:(ApplifierImpactSBJsonStreamWriter*)writer {
	writer.error = @"Stream is closed";
	return YES;
}
@end

@implementation ApplifierImpactSBJsonStreamWriterStateError

SINGLETON

@end

