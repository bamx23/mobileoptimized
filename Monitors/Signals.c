//
//  Signals.c
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#import "Signals.h"

#include <signal.h>

static const char *const kSignalNames[] = {
    "", // 0
    "", // 1
    "", // 2
    "", // 3
    "SIGILL", // 4
    "SIGTRAP", // 5
    "SIGABRT", // 6
    "", // 7
    "SIGFPE", // 8
    "", // 9
    "SIGBUS", // 10
    "SIGSEGV", // 11
    "SIGSYS", // 12
    "SIGPIPE", // 13
};

static int const kSignals[] = {
    SIGILL,
    SIGTRAP,
    SIGABRT,
    SIGBUS,
    SIGFPE,
    SIGSEGV,
    SIGSYS,
    SIGPIPE,
};
static int const kSignalsCount = sizeof(kSignals) / sizeof(*kSignals);

static struct sigaction gOriginalHandlers[kSignalsCount] = {{0}};

static void handleSignal(int sigNum, siginfo_t* signalInfo, void* userContext) {
    oslog("Signal: %s(%d), address: 0x%lx",
          kSignalNames[sigNum],
          sigNum,
          (unsigned long)signalInfo->si_addr);

    for (int i = 0; i < kSignalsCount; ++i) {
        sigaction(kSignals[i], &gOriginalHandlers[i], NULL);
    }
    raise(sigNum);
}

void setupSignal() {
    struct sigaction action = {{0}};
    action.sa_flags = SA_SIGINFO;
    sigemptyset(&action.sa_mask);
    action.sa_sigaction = &handleSignal;
    for (int i = 0; i < kSignalsCount; ++i) {
        sigaction(kSignals[i], &action, &gOriginalHandlers[i]);
    }
}
