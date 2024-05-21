package com.szabh.androidblesdk3.tools

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import com.blankj.utilcode.util.FileIOUtils
import com.blankj.utilcode.util.LogUtils

object PcmPlayer {
    private val TAG = "PcmPlayer"
    private var mAudioTrack: AudioTrack? = null

    fun play(path: String) {
        LogUtils.e("$TAG play -> $path")
        val data = FileIOUtils.readFile2BytesByChannel(path)
        if (data == null || data.size < 1024) return
        if (mAudioTrack == null) {
            mAudioTrack = AudioTrack(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build(),
                AudioFormat.Builder()
                    .setSampleRate(16000)
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build(),
                data.size,
                AudioTrack.MODE_STATIC,
                AudioManager.AUDIO_SESSION_ID_GENERATE
            )
        }
        if (mAudioTrack?.state == AudioTrack.STATE_UNINITIALIZED) {
            LogUtils.e("$TAG AudioTrack 初始化失败")
            release()
            return
        }
        stop()
        mAudioTrack?.write(data, 0, data.size)
        mAudioTrack?.play()
    }

    private fun isPlay(): Boolean {
        return mAudioTrack != null && mAudioTrack?.playState == AudioTrack.PLAYSTATE_PLAYING
    }

    private fun stop() {
        if (isPlay()) {
            mAudioTrack?.stop()
        }
    }

    private fun release() {
        if (mAudioTrack != null) {
            stop()
            mAudioTrack?.release()
            mAudioTrack = null
        }
    }
}