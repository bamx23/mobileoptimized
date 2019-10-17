//
//  MachExceptions.c
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#import "MachExceptions.h"

#include <mach/mach.h>
#include <mach/kern_return.h>
#include <pthread.h>

static const char *const kMachTypeNames[] = {
    "", // 0
    "EXC_BAD_ACCESS", // 1
    "EXC_BAD_INSTRUCTION", // 2
    "EXC_ARITHMETIC", // 3
    "", // 4
    "EXC_SOFTWARE", // 5
    "EXC_BREAKPOINT", // 6
};

#pragma pack(4)
typedef struct
{
    mach_msg_header_t          header;
    mach_msg_body_t            body;
    mach_msg_port_descriptor_t thread;
    mach_msg_port_descriptor_t task;
    NDR_record_t               NDR;
    exception_type_t           exception;
    mach_msg_type_number_t     codeCount;
    mach_exception_data_type_t code[0];
    char                       padding[512];
} MachExceptionMessage;
typedef struct
{
    mach_msg_header_t header;
    NDR_record_t      NDR;
    kern_return_t     returnCode;
} MachReplyMessage;
#pragma pack()

static mach_port_t gExceptionPort = MACH_PORT_NULL;

static void receiveMessage(MachExceptionMessage *exceptionMessage) {
    kern_return_t kr;
    do {
        kr = mach_msg(&exceptionMessage->header,
                      MACH_RCV_MSG,
                      0,
                      sizeof(*exceptionMessage),
                      gExceptionPort,
                      MACH_MSG_TIMEOUT_NONE,
                      MACH_PORT_NULL);
    } while (kr != KERN_SUCCESS);
}

static void replyToMessage(MachExceptionMessage *exceptionMessage) {
    MachReplyMessage replyMessage = {{0}};
    replyMessage.header = exceptionMessage->header;
    replyMessage.NDR = exceptionMessage->NDR;
    replyMessage.returnCode = KERN_FAILURE;

    mach_msg(&replyMessage.header,
             MACH_SEND_MSG,
             sizeof(replyMessage),
             0,
             MACH_PORT_NULL,
             MACH_MSG_TIMEOUT_NONE,
             MACH_PORT_NULL);
}

static void *handleExceptions(void *const userData) {
    MachExceptionMessage exceptionMessage = {{0}};
    receiveMessage(&exceptionMessage);

    oslog("Mach exception: %s(%d), %llu, %llu",
          kMachTypeNames[exceptionMessage.exception],
          exceptionMessage.exception,
          exceptionMessage.code[0],
          exceptionMessage.code[1]);
    
    replyToMessage(&exceptionMessage);
    return NULL;
}

void setupMach() {
    const task_t thisTask = mach_task_self();
    mach_port_allocate(thisTask,
                       MACH_PORT_RIGHT_RECEIVE,
                       &gExceptionPort);
    mach_port_insert_right(thisTask,
                           gExceptionPort,
                           gExceptionPort,
                           MACH_MSG_TYPE_MAKE_SEND);
    exception_mask_t mask = EXC_MASK_BAD_ACCESS |
                            EXC_MASK_BAD_INSTRUCTION |
                            EXC_MASK_ARITHMETIC |
                            EXC_MASK_SOFTWARE |
                            EXC_MASK_BREAKPOINT;
    task_set_exception_ports(thisTask,
                             mask,
                             gExceptionPort,
                             (int)(EXCEPTION_DEFAULT | MACH_EXCEPTION_CODES),
                             THREAD_STATE_NONE);

    pthread_attr_t attr;
    pthread_attr_init(&attr);
    pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
    pthread_t thread;
    pthread_create(&thread, &attr, &handleExceptions, "Mach Monitor");
}
