//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleVersion: BleReadable {
    var mVersion = ""

    override func decode() {
        super.decode()
        if let data = mData {
            mVersion = data.map({
                if $0 > 9 {
                    return "0"
                } else {
                    return "\($0)"
                }
            }).joined(separator: ".")
        }
    }
}
