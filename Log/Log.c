//
//  Log.c
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#include "Log.h"

#include <stdio.h>
#import <os/log.h>

static os_log_t gLog;

void oslog(const char* fmt, ...) {
    if (gLog == NULL) {
        gLog = os_log_create("bamx23", "bamx23");
    }
    va_list args;
    va_start(args, fmt);
    char buffer[512];
    vsnprintf(buffer, sizeof(buffer), fmt, args);
    os_log_error(gLog, "%s", buffer);
    va_end(args);
}
