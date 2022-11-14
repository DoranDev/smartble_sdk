package com.szabh.smable3.music

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.service.notification.NotificationListenerService
import androidx.annotation.CallSuper
import com.blankj.utilcode.util.LogUtils

open class MusicControllerCompat {
    var mAudioManager: AudioManager? = null

    protected var mContext: NotificationListenerService? = null
    private val mReceiver: BroadcastReceiver by lazy {
        object : BroadcastReceiver() {

            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    VOLUME_CHANGED_ACTION -> updateVolume(intent.getIntExtra(EXTRA_VOLUME_STREAM_TYPE, -1))
                }
            }
        }
    }

    fun getStreamVolume(streamType: Int): Int {
        return mAudioManager?.getStreamVolume(streamType) ?: -1
    }

    fun getStreamMaxVolume(streamType: Int): Int {
        return mAudioManager?.getStreamMaxVolume(streamType) ?: 15
    }

    /**
     * [NotificationListenerService.onCreate]时调用。
     */
    @CallSuper
    open fun launch(context: NotificationListenerService) {
        mContext = context
        context.registerReceiver(mReceiver, IntentFilter(VOLUME_CHANGED_ACTION))
        mAudioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    }

    /**
     * [NotificationListenerService.onDestroy]时调用。
     */
    @CallSuper
    open fun exit() {
        mContext?.unregisterReceiver(mReceiver)
        mContext = null
    }

    open fun updateVolume(streamType: Int) {

    }

    companion object {
        private const val VOLUME_CHANGED_ACTION = "android.media.VOLUME_CHANGED_ACTION"
        private const val EXTRA_VOLUME_STREAM_TYPE = "android.media.EXTRA_VOLUME_STREAM_TYPE"

        fun newInstance(): MusicControllerCompat = MusicController()
    }
}