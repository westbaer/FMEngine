//
//  FMEngine.m
//  LastFMAPI
//
//  Created by Nicolas Haunold on 4/26/09.
//  Copyright 2009 Tapolicious Software. All rights reserved.
//

#import "FMEngine.h"
#import "FMEngineURLConnection.h"

@implementation FMEngine
@synthesize delegate = _delegate;

static NSInteger sortAlpha(NSString *n1, NSString *n2, void *context) {
	return [n1 caseInsensitiveCompare:n2];
}

- (id)initWithDelegate:(id<FMEngineDelegate>)theDelegate {
	if (self = [super init]) {
		_delegate = [theDelegate retain];
		connections = [[NSMutableDictionary alloc] init];
	}
	return self;	
}

- (NSString *)generateAuthTokenFromUsername:(NSString *)username password:(NSString *)password {
	NSString *unencryptedToken = [NSString stringWithFormat:@"%@%@", username, [password md5sum]];
	return [unencryptedToken md5sum];
}

- (void)performMethod:(NSString *)method withTarget:(id)target withParameters:(NSDictionary *)params andAction:(SEL)callback useSignature:(BOOL)useSig httpMethod:(NSString *)httpMethod {
	NSString *dataSig;
	NSMutableURLRequest *request;
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:params];
	
	if(useSig == TRUE) {
		dataSig = [self generateSignatureFromDictionary:params];
		
		[tempDict setObject:dataSig forKey:@"api_sig"];
	}
	
	#ifdef _USE_JSON_
	if(![httpMethod isPOST]) {
		[tempDict setObject:@"json" forKey:@"format"];
	}

	#endif
	
	[tempDict setObject:method forKey:@"method"];
	params = [NSDictionary dictionaryWithDictionary:tempDict];
	[tempDict release];

	if(![httpMethod isPOST]) {
		NSURL *dataURL = [self generateURLFromDictionary:params];
		request = [NSURLRequest requestWithURL:dataURL];
	} else {
		request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_LASTFM_BASEURL_ stringByAppendingString:@"?format=json"]]];
		[request setHTTPMethod:httpMethod];
		[request setHTTPBody:[[self generatePOSTBodyFromDictionary:params] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	FMEngineURLConnection *connection = [[FMEngineURLConnection alloc] initWithRequest:request];
	connection._target = target;
	connection._selector = callback;
	
	if(connection) {
		[connections setObject:connection forKey:[connection identifier]];
		[connection release];
	}

}

- (NSData *)dataForMethod:(NSString *)method withParameters:(NSDictionary *)params useSignature:(BOOL)useSig httpMethod:(NSString *)httpMethod {
	NSString *dataSig;
	NSMutableURLRequest *request;
	NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:params];
	
	if(useSig == TRUE) {
		dataSig = [self generateSignatureFromDictionary:params];
		
		[tempDict setObject:dataSig forKey:@"api_sig"];
	}
	
	#ifdef _USE_JSON_
	if(![httpMethod isPOST]) {
		[tempDict setObject:@"json" forKey:@"format"];
	}
	#endif
	
	[tempDict setObject:method forKey:@"method"];
	params = [NSDictionary dictionaryWithDictionary:tempDict];
	[tempDict release];
	
	if(![httpMethod isPOST]) {
		NSURL *dataURL = [self generateURLFromDictionary:params];
		request = [NSURLRequest requestWithURL:dataURL];
	} else {
		request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[_LASTFM_BASEURL_ stringByAppendingString:@"?format=json"]]];
		[request setHTTPMethod:httpMethod];
		[request setHTTPBody:[[self generatePOSTBodyFromDictionary:params] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	return returnData;
}

- (NSString *)generatePOSTBodyFromDictionary:(NSDictionary *)dict {
	NSMutableString *rawBody = [[NSMutableString alloc] init];
	NSMutableArray *aMutableArray = [[NSMutableArray alloc] initWithArray:[dict allKeys]];
	[aMutableArray sortUsingFunction:sortAlpha context:self];
	
	for(NSString *key in aMutableArray) {
		[rawBody appendString:[NSString stringWithFormat:@"&%@=%@", key, [dict objectForKey:key]]];
	}	
	
	
	NSString *body = [NSString stringWithString:rawBody];
	[rawBody release];
	[aMutableArray release];
	
	return body;
}

- (NSURL *)generateURLFromDictionary:(NSDictionary *)dict {
	NSMutableArray *aMutableArray = [[NSMutableArray alloc] initWithArray:[dict allKeys]];
	NSMutableString *rawURL = [[NSMutableString alloc] init];
	[aMutableArray sortUsingFunction:sortAlpha context:self];
	[rawURL appendString:_LASTFM_BASEURL_];
	
	int i;
	
	for(i = 0; i < [aMutableArray count]; i++) {
		NSString *key = [aMutableArray objectAtIndex:i];
		if(i == 0) {
			[rawURL appendString:[NSString stringWithFormat:@"?%@=%@", key, [dict objectForKey:key]]];
		} else {
			[rawURL appendString:[NSString stringWithFormat:@"&%@=%@", key, [dict objectForKey:key]]];
		}
	}
	
	
	NSURL *url = [NSURL URLWithString:rawURL];
	[rawURL release];
	[aMutableArray release];
	
	return url;
}

- (NSString *)generateSignatureFromDictionary:(NSDictionary *)dict {
	NSMutableArray *aMutableArray = [[NSMutableArray alloc] initWithArray:[dict allKeys]];
	NSMutableString *rawSignature = [[NSMutableString alloc] init];
	[aMutableArray sortUsingFunction:sortAlpha context:self];
	
	for(NSString *key in aMutableArray) {
		[rawSignature appendString:[NSString stringWithFormat:@"%@%@", key, [dict objectForKey:key]]];
	}
	
	[rawSignature appendString:_LASTFM_SECRETK_];
	
	NSString *signature = [rawSignature md5sum];
	[rawSignature release];
	[aMutableArray release];
	
	return signature;
}

- (void)dealloc {
	[_delegate release];
	_delegate = nil;
	[[connections allValues] makeObjectsPerformSelector:@selector(cancel)];
    [connections release];
	[super dealloc];
}

@end