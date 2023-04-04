//
//  DataExtension.swift
//  SmartV3
//
//  Created by SMA on 2021/2/20.
//  Copyright © 2021 KingHuang. All rights reserved.
//

import Foundation
import UIKit

extension Data {
    mutating func extract(_ strat:Int = 0,_ end:Int = 0) -> Data? {
            
        guard self.count > 0 else {
            return nil
        }
        // Create a range based on the length of data to return
        let range:Range = strat ..< end
        // Get a new copy of data
        let subData = self.subdata(in: range)
        // Mutate data
        self.removeSubrange(range)
        // Return the new copy of data
        return subData
    }
    

    /// Create hexadecimal string representation of `Data` object.
    ///
    /// - returns: `String` representation of this `Data` object.
    func hexadecimal() -> String {
        return map { String(format: "%02x", $0) }
            .joined(separator: "")
    }

}
