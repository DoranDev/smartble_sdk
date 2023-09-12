//
// Created by Best Mafen on 2019/9/26.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleBleAddress: BleReadable {
    var mAddress = ""

    override func decode() {
        super.decode()
        mAddress = String(format: "%02X:%02X:%02X:%02X:%02X:%02X",
            readUInt8(), readUInt8(), readUInt8(), readUInt8(), readUInt8(), readUInt8())
    }
}
