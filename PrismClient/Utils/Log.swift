//
//  Log.swift
//  PrismKit
//
//  Created by Erik Bautista on 8/6/21.
//

import Foundation
import OSLog

final class Log {
    static func debug(_ message: String,
                      fileName: String = #file,
                      functionName: String = #function,
                      lineNumber: Int = #line) {
        os_log("%{public}@", type: .info, "\((fileName as NSString).lastPathComponent) - " +
                                                     "\(functionName) at line \(lineNumber): \(message)")
    }

    static func error(_ message: String,
                      fileName: String = #file,
                      functionName: String = #function,
                      lineNumber: Int = #line) {
        os_log("%{public}@", type: .error, "\((fileName as NSString).lastPathComponent) - " +
                                                      "\(functionName) at line \(lineNumber): \(message)")
    }
}
