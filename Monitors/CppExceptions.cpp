//
//  CppExceptions.cpp
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#include "CppExceptions.h"

#include <cxxabi.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <typeinfo>
#include <execinfo.h>
#include <string.h>

typedef void (*cxa_throw_type)(void*, std::type_info*, void (*)(void*));
extern "C"
{
    void __cxa_throw(void* thrown_exception, std::type_info* tinfo, void (*dest)(void*)) __attribute__ ((weak));
    void __cxa_throw(void* thrown_exception, std::type_info* tinfo, void (*dest)(void*))
    {
        const int size = 255;
        uintptr_t bt[size];
        int btSize = backtrace((void **)bt, size);
        char **symbols = backtrace_symbols((void * const*)bt, btSize);
        for (int i = 0; i < btSize; ++i) {
            oslog("%s", symbols[i]);
        }
        free(symbols);

        cxa_throw_type orig_cxa_throw = (cxa_throw_type) dlsym(RTLD_NEXT, "__cxa_throw");
        orig_cxa_throw(thrown_exception, tinfo, dest);
        __builtin_unreachable();
    }
}

static std::terminate_handler gOriginalTerminateHandler;

static void handleException() {
    std::type_info* tinfo = __cxxabiv1::__cxa_current_exception_type();
    const char* name = tinfo->name();
    if (name && strcmp(name, "NSException") == 0) {
        oslog("NSException skiped");
    }
    else {
        oslog("C++ exception: %s", name);
    }

    gOriginalTerminateHandler();
}

extern "C" void setupCppException() {
    gOriginalTerminateHandler = std::set_terminate(handleException);
}
