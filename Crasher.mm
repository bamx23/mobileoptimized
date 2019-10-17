//
//  Crasher.m
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#import "Crasher.h"
#import "MetricaSample-Swift.h"

#include <deque>

@interface MyClass: NSObject

@property (nonatomic, copy) NSString *info;

@end

@implementation MyClass

- (void)executeWithCallback:(dispatch_block_t)block
{
    block();
    NSLog(@"Executed. Info: %@", self.info);
}

@end

class CustomCPPException: public std::exception
{
public:
    virtual const char* what() const noexcept;
};

const char* CustomCPPException::what() const noexcept
{
    return "Something bad happened...";
}

@implementation Crasher

#pragma mark - NSException

+ (void)processResponse:(NSData *)responseData
{
    NSDictionary *responseDictionary =
        [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    NSString *actionName = responseDictionary[@"action"];
    NSString *message = responseDictionary[@"message"];
    NSLog(@"The result for '%@' is '%@'", actionName, message);
}

+ (void)crashWithUnknownSelector
{
    NSData *response = [@"[\"not-a-dictionary\"]" dataUsingEncoding:NSUTF8StringEncoding];
    [self processResponse:response];
}

#pragma mark - C++ Exception

int processNext(std::deque<int> &values) {
    int value = values.at(0);
    oslog("Next is: %d", value);
    values.pop_front();
    return value;
}

+ (void)crashWithCPPOutOfBounds
{
    std::deque<int> noValues;
    processNext(noValues);
}

+ (void)crashWithCPPThrowSTLException
{
    throw std::exception();
}

+ (void)crashWithCPPThrowCustomException
{
    throw CustomCPPException();
}

#pragma mark - SIGNAL / Mach Exception

// SIGFPE
+ (NSInteger)groupsCountWithTotal:(NSInteger)total sizeLimit:(NSInteger)limit
{
    NSInteger result = total / limit;
    if (total % limit != 0) {
        ++result;
    }
    return result;
}

+ (void)crashWithSIGFPE
{
    NSInteger groupsCount = [self groupsCountWithTotal:42 sizeLimit:0];
    oslog("Groups count: %ld", (long)groupsCount);
}

// SIGABRT
void doAssert() {
    assert(false);
}

+ (void)crashWithSIGABRT
{
    doAssert();
}

// SIGSEGV

void dereferenceNull() {
    unsigned int *data = NULL;
    oslog("%d", *data);
}

+ (void)crashWithNullPointerDereferenceSIGSEGV
{
    accessAteBadFoodPointer();
}

void accessAteBadFoodPointer() {
    unsigned int *data = (unsigned int *)0x8badf00d;
    oslog("%d", *data);
}

+ (void)crashWithBadFoodSIGSEGV
{
    accessAteBadFoodPointer();
}

static void accessDeallocatedObject() {
    MyClass *__block obj = [[MyClass alloc] init];
    obj.info = @"Some info";
    [obj executeWithCallback:^{
        NSLog(@"Complete");
        obj = nil;
    }];
}

+ (void)crashWithSIGSEGVFromObjC
{
    accessDeallocatedObject();
}

// SIGBUS
void callFunctionFromHeap() {
    unsigned int *data = (unsigned int *)malloc(100);
    void (*foo)() = (void (*)())data;
    foo();
}

+ (void)crashWithSIGBUS
{
    callFunctionFromHeap();
}

void callFunctionFromStack() {
    unsigned int data[] = {1, 2, 3};
    void (*foo)() = (void (*)())data;
    foo();
}

+ (void)crashWithSIGBUSWithoutSignal
{
    callFunctionFromStack();
}

// SIGILL / SIGTRAP
void syncCallOnMainQueue() {
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"On main queue");
    });
}

+ (void)crashByDispatchingOnMainQueue
{
    syncCallOnMainQueue();
}

#pragma mark - Swift Exception

+ (void)crashWithSwiftFatalError
{
    [SwiftCrasher fatal];
}

+ (void)crashWithSwiftUnhandledError
{
    [SwiftCrasher unhandledError];
}

+ (void)crashWithSwiftUnwrappingNull
{
    [SwiftCrasher unwrappingNull];
}

@end
