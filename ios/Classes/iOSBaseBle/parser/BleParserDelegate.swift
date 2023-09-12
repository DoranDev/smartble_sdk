//
// Created by Best Mafen on 2019/9/20.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

/**
 * 消息解析器，用于把设备返回的流数据，拼装成完整的协议层面的消息。
 */
protocol BleParserDelegate {

    func onReceive(_ data: Data) -> Data?

    func reset()
}
