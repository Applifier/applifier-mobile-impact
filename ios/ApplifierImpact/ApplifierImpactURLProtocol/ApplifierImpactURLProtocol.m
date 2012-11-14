//
//  ApplifierImpactURLProtocol.m
//  ApplifierImpact
//
//  Created by bluesun on 10/10/12.
//  Copyright (c) 2012 Applifier. All rights reserved.
//

#import "ApplifierImpactURLProtocol.h"
#import "../ApplifierImpactWebView/ApplifierImpactWebAppController.h"

static const NSString *kApplifierImpactURLProtocolHostname = @"client.impact.applifier.com";

@implementation ApplifierImpactURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  NSURL *url = [request URL];
  
  if ([[url scheme] isEqualToString:@"http"]) {
    if ([[request HTTPMethod] isEqualToString:@"POST"]) {
      if ([[url host] isEqualToString:(NSString *)kApplifierImpactURLProtocolHostname]) {
        return TRUE;
      }
    }
  }
  
  return FALSE;
}

+ (NSString *)stringWithUriEncoding:(NSString *)string;
{
  NSString *result = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                  (__bridge CFStringRef)string, NULL,(CFStringRef)@":/?#[]@!$&’()*+,;=", kCFStringEncodingUTF8);
  return result;
}

+ (NSString *)stringWithoutUriEncoding:(NSString *)string;
{
  NSString *result = (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)string, CFSTR(""), kCFStringEncodingUTF8);
  return result;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
  return request;
}

- (void)startLoading
{
  NSURLRequest *request = [self request];
  NSData *reqData = [request HTTPBody];
  
  [self actOnJSONResults: reqData];
  
  // Create the response
  NSData *responseData = [@"status: ok" dataUsingEncoding:NSUTF8StringEncoding];
	NSURLResponse *response =
  [[NSURLResponse alloc] initWithURL:[request URL]
                            MIMEType:@"application/json"
               expectedContentLength:-1
                    textEncodingName:nil];
  
  // get a reference to the client so we can hand off the data
  id<NSURLProtocolClient> client = [self client];
  
  // turn off caching for this response data
	[client URLProtocol:self didReceiveResponse:response
   cacheStoragePolicy:NSURLCacheStorageNotAllowed];
  
  // set the data in the response to our response data
	[client URLProtocol:self didLoadData:responseData];
  
  // notify that we completed loading
	[client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
}

- (void)actOnJSONResults:(NSData *)jsonData
{
  NSError *myError = nil;
  NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&myError];
  
  __block NSString *type = [results objectForKey:@"type"];
  __block NSDictionary *dictData = nil;

  id data = [results objectForKey:@"data"];
  if ([data isKindOfClass:[NSDictionary class]]) {
    dictData = (NSDictionary *)data;
  }
  
  if (dictData != nil) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [[ApplifierImpactWebAppController sharedInstance] handleWebEvent:type data:dictData];
    });
  }
}

@end
