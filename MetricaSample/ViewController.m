//
//  ViewController.m
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/11/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

#import "ViewController.h"
#import "Crasher.h"

static NSString *const kSectionName = @"section-name";
static NSString *const kSectionItems = @"section-items";
static NSString *const kItemName = @"item-name";
static NSString *const kItemBlock = @"item-block";

static NSString *const kCellIdentifier = @"cell-id";

@implementation ViewController

- (NSArray *)data
{
    static NSArray *data = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = @[
            @{
                kSectionName: @"NSException",
                kSectionItems: @[
                        @{
                            kItemName: @"Unknown Selector",
                            kItemBlock: ^{
                                [Crasher crashWithUnknownSelector];
                            },
                        },
                ],
            },
            @{
                kSectionName: @"C++ Exception",
                kSectionItems: @[
                        @{
                            kItemName: @"deque out of bounds",
                            kItemBlock: ^{
                                [Crasher crashWithCPPOutOfBounds];
                            },
                        },
                        @{
                            kItemName: @"STL exception",
                            kItemBlock: ^{
                                [Crasher crashWithCPPThrowSTLException];
                            },
                        },
                        @{
                            kItemName: @"Custom exception",
                            kItemBlock: ^{
                                [Crasher crashWithCPPThrowCustomException];
                            },
                        },
                ],
            },
            @{
                kSectionName: @"Signal / Mach Exception",
                kSectionItems: @[
                        @{
                            kItemName: @"42 / 0 (SIGFPE)",
                            kItemBlock: ^{
                                [Crasher crashWithSIGFPE];
                            },
                        },
                        @{
                            kItemName: @"abort() (SIGABRT)",
                            kItemBlock: ^{
                                [Crasher crashWithSIGABRT];
                            },
                        },
                        @{
                            kItemName: @"dereference NULL (SIGSEGV)",
                            kItemBlock: ^{
                                [Crasher crashWithNullPointerDereferenceSIGSEGV];
                            },
                        },
                        @{
                            kItemName: @"access 0x8badf00d (SIGSEGV)",
                            kItemBlock: ^{
                                [Crasher crashWithBadFoodSIGSEGV];
                            },
                        },
                        @{
                            kItemName: @"access deallocated object (SIGSEGV)",
                            kItemBlock: ^{
                                [Crasher crashWithSIGSEGVFromObjC];
                            },
                        },
                        @{
                            kItemName: @"function on stack (EXC_BAD_ACCESS)",
                            kItemBlock: ^{
                                [Crasher crashWithSIGBUSWithoutSignal];
                            },
                        },
                        @{
                            kItemName: @"fuction on heap (SIGBUS)",
                            kItemBlock: ^{
                                [Crasher crashWithSIGBUS];
                            },
                        },
                        @{
                            kItemName: @"sync main queue (SIGILL/SIGTRAP)",
                            kItemBlock: ^{
                                [Crasher crashByDispatchingOnMainQueue];
                            },
                        },
                ],
            },
            @{
                kSectionName: @"Swift",
                kSectionItems: @[
                        @{
                            kItemName: @"fatalError",
                            kItemBlock: ^{
                                [Crasher crashWithSwiftFatalError];
                            },
                        },
                        @{
                            kItemName: @"unhandled error (try!)",
                            kItemBlock: ^{
                                [Crasher crashWithSwiftUnhandledError];
                            },
                        },
                        @{
                            kItemName: @"unwrapping null (value!)",
                            kItemBlock: ^{
                                [Crasher crashWithSwiftUnwrappingNull];
                            },
                        },
                ],
            },
        ];
    });
    return data;
}

#pragma mark - Table View Stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.data.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.data[section][kSectionName];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data[section][kSectionItems] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.data[section][kSectionItems][item][kItemName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger item = indexPath.row;
    dispatch_block_t block = self.data[section][kSectionItems][item][kItemBlock];
    block();
}

@end
