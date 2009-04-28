//
//  AppController.h
//  FMEngine
//
//  Created by Nicolas Haunold on 4/29/09.
//  Copyright 2009 Tapolicious Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMEngine.h"

@interface AppController : NSObject <FMEngineDelegate> {
	FMEngine *fmEngine;
}

@end
