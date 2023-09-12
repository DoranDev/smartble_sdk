//
// Created by Best Mafen on 2019/9/19.
// Copyright (c) 2019 szabh. All rights reserved.
//

import Foundation

/**
 * 发送端的消息队列，当一条WriteMessage的长度超过mPacketSize，会被拆分成多条消息包。
 */
class BaseBleMessenger {
    /**
     * 默认消息包的长度。
     */
    static let DEFAULT_PACKET_SIZE = 20

    var mBaseBleConnector: BaseBleConnector!

    // 一次传输的字节数，在获取maximumWriteValueLength之后会修改该值
    var mPacketSize = DEFAULT_PACKET_SIZE

    func setTargetConnector(_ baseBleConnector: BaseBleConnector) {
        mBaseBleConnector = baseBleConnector
    }

    /**
     * 入队一条消息。
     */
    func enqueueMessage(_ bleMessage: BleMessage) {

    }

    /**
     * 出队一条消息。
     */
    func dequeueMessage() {

    }

    /**
     * 出队一个消息包。
     */
    func dequeueWritePacket() {

    }

    /**
     * 重置消息队列，会清空所有消息。
     */
    func reset() {

    }
}
