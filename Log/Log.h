//
//  Log.h
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#ifndef Log_h
#define Log_h

#ifdef __cplusplus
extern "C" {
#endif

void oslog(const char* fmt, ...) __attribute__((format(printf, 1, 2)));

#ifdef __cplusplus
}
#endif

#endif /* Log_h */
