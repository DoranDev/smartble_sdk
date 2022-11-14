package com.szabh.smable3.component

import com.bestmafen.baseble.messenger.BleMessage

interface BleMessengerCallback {

    fun onRetry()

    fun onTimeout(message: BleMessage)
}