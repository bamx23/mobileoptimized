//
//  Crasher.h
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Crasher : NSObject

+ (void)crashWithUnknownSelector;

+ (void)crashWithCPPOutOfBounds;
+ (void)crashWithCPPThrowSTLException;
+ (void)crashWithCPPThrowCustomException;

+ (void)crashWithSIGFPE;
+ (void)crashWithSIGABRT;
+ (void)crashWithNullPointerDereferenceSIGSEGV;
+ (void)crashWithBadFoodSIGSEGV;
+ (void)crashWithSIGSEGVFromObjC;
+ (void)crashWithSIGBUS;
+ (void)crashWithSIGBUSWithoutSignal;
+ (void)crashByDispatchingOnMainQueue;

+ (void)crashWithSwiftFatalError;
+ (void)crashWithSwiftUnhandledError;
+ (void)crashWithSwiftUnwrappingNull;

@end
