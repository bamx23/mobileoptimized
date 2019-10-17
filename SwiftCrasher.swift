//
//  SwiftCrasher.swift
//  MetricaSample
//
//  Created by Nikolay Volosatov on 10/14/19.
//  Copyright © 2019 Yandex, LLC. All rights reserved.
//

import Foundation

enum SomeError: Error {
    case someCase(message: String)
}

@objc class SwiftCrasher: NSObject {

    @objc static func fatal() {
        fatalError("[Message of swift fatal error]")
    }

    static func raiseError() throws {
        throw SomeError.someCase(message: "Some message")
    }

    @objc static func unhandledError() {
        try! raiseError()
    }

    @objc static func unwrappingNull() {
        let value = Double("not-a-double")
        print("Value is: \(value!)")
    }
}
