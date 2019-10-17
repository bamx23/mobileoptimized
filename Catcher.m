//
//  Catcher.m
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#import "Catcher.h"
#import "NSExceptions.h"
#import "CppExceptions.h"
#import "Signals.h"
#import "SwiftExceptions.h"
#import "MachExceptions.h"

#include <sys/sysctl.h>

@implementation Catcher

- (void)setup
{
    setupNSException();
    setupCppException();
    setupSignal();
    setupSwiftException();
    if ([self debuggerAttached] == NO) {
        setupMach();
    }
}

- (BOOL)debuggerAttached
{
    struct kinfo_proc info;
    size_t info_size = sizeof(info);
    int name[] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()};
    if (sysctl(name, sizeof(name) / sizeof(*name), &info, &info_size, NULL, 0) != -1) {
        return (info.kp_proc.p_flag & P_TRACED) != 0;
    }
    return NO;
}

@end
