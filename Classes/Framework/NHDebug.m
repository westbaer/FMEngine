//
//  NHDebug.m
//  NHToolkit
//
//  Created by Nicolas Haunold on 3/30/09.
//  Copyright 2009 Tapolicious Software. All rights reserved.
//

#import "NHDebug.h"

@implementation NHDebug

+ (BOOL)isValidDelegate:(id)_delegate forSelector:(SEL)aSelector {
	return (_delegate && [_delegate respondsToSelector:aSelector]);
}

@end
