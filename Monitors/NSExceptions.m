//
//  NSExceptions.m
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#import "NSExceptions.h"

#import <Foundation/Foundation.h>

static NSUncaughtExceptionHandler *gOriginalHandler = NULL;

static void handleUncaughtException(NSException *exception) {
    oslog("Exception: %s", exception.description.UTF8String);
    for (NSString *symbol in exception.callStackSymbols) {
        oslog("%s", symbol.UTF8String);
    }
    if (gOriginalHandler != NULL) {
        gOriginalHandler(exception);
    }
}

void setupNSException() {
    gOriginalHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(handleUncaughtException);
}
