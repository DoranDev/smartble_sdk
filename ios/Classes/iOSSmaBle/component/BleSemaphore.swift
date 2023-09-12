//
// Created by Best Mafen on 2019/9/19.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

class BleSemaphore {
    let mDispatchSemaphore: DispatchSemaphore
    var mAvailablePermits: Int

    init(_ permits: Int) {
        self.mDispatchSemaphore = DispatchSemaphore(value: permits)
        mAvailablePermits = permits
    }

    func acquire() {
        mDispatchSemaphore.wait()
        mAvailablePermits -= 1
    }

    func acquire(_ timeout: DispatchTime) {
        _ = mDispatchSemaphore.wait(timeout: timeout)
        mAvailablePermits -= 1
    }

    func release() {
        mDispatchSemaphore.signal()
        mAvailablePermits += 1
    }

    func reset() {
        if mAvailablePermits > 1 {
            for _ in 0..<mAvailablePermits - 1 {
                acquire()
            }
        } else if mAvailablePermits < 1 {
            for _ in 0..<1 - mAvailablePermits {
                release()
            }
        }
    }
}
