//
//  FMEngineURLConnection.h
//  LastFMAPI
//
//  Created by Nicolas Haunold on 4/28/09.
//  Copyright 2009 Tapolicious Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+FMEngine.h"

@interface FMEngineURLConnection : NSURLConnection {
	NSString *_id;
	NSMutableData *_receivedData;
	id _target;
	SEL _selector;
}

@property (nonatomic, assign) id _target;
@property (nonatomic, assign) SEL _selector;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate;
- (id)initWithRequest:(NSURLRequest *)request;
- (void)appendData:(NSData *)moreData;
- (NSData *)data;
- (NSString *)identifier;

@end