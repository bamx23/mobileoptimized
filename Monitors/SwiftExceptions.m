//
//  SwiftExceptions.m
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/14/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#include "SwiftExceptions.h"

#include <stdlib.h>
#include <dlfcn.h>
#import <Foundation/Foundation.h>

extern NSError *_swift_stdlib_bridgeErrorToNSError(uintptr_t);

typedef void(*swift_unexpectedError_type)(uintptr_t, const char*, int, int, unsigned long);
void swift_unexpectedError(uintptr_t, const char*, int, int, unsigned long) __attribute__ ((weak));
void swift_unexpectedError(uintptr_t error, const char* filePath, int c, int d, unsigned long line) {
    NSError *some = _swift_stdlib_bridgeErrorToNSError(error);
    oslog("Swift error: %s (%s:%lu)", some.domain.UTF8String, filePath, line);

    swift_unexpectedError_type next = (swift_unexpectedError_type) dlsym(RTLD_NEXT, "swift_unexpectedError");
    next(error, filePath, c, d, line);
    __builtin_unreachable();
}

extern void setupSwiftException(void) {
    // Do nothing
}
