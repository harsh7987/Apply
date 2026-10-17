//
//  Logger.swift
//  Apply
//
//  Created by Pranjal Verma on 19/03/26.
//

import Foundation

/// This globally overrides the default print() function across the entire app.
/// It ensures prints ONLY happen in Debug mode and are completely silenced in Release (TestFlight/App Store).
public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    let output = items.map { "\($0)" }.joined(separator: separator)
    Swift.print(output, terminator: terminator)
    #endif
}
