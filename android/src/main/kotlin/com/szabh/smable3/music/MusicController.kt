package com.szabh.smable3.music

import android.content.ComponentName
import android.content.Context
import android.media.AudioManager
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.media.session.PlaybackState
import android.service.notification.NotificationListenerService
import android.support.v4.media.MediaMetadataCompat
import android.support.v4.media.session.MediaControllerCompat
import android.support.v4.media.session.MediaSessionCompat
import android.support.v4.media.session.PlaybackStateCompat
import android.view.KeyEvent
import com.bestmafen.baseble.util.BleLog
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.component.BleHandleCallback
import com.szabh.smable3.component.HIDValue
import com.szabh.smable3.entity.BleMusicControl
import com.szabh.smable3.entity.MusicAttr
import com.szabh.smable3.entity.MusicCommand
import com.szabh.smable3.entity.MusicEntity
import java.lang.Exception
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.*

typealias MyState = com.szabh.smable3.entity.PlaybackState

class MusicController : MusicControllerCompat() {


    private var mMediaSessionManager: MediaSessionManager? = null

    /**
     * 用户最近在操作的播放器
     *
     * 第三方的音乐播放器必须按照安卓媒体框架规范来开发，一般主流的播放器问题不大，不按规范开发的播放器播放状态、播放信息可能不能正
     * 常获取，或者回调状态混乱不正常，这样控制效果就差。
     * 因为不同的手机和不同的播放器，获取到的状态信息可能会比较混乱，如果用户多个音乐播放器来回切换，暂时没有很好的方法识别用户最近操作的播放器，
     * 这里使用[autoSwitchActiveController]方法自动切换最近在操作的播放器。
     */
    private var mActiveMediaController: MediaControllerCompat? = null

    private var mLastVolumeTime: Long = 0 //最近一次音量更新时间
    private var mLastVolume: Int = -1 //最近一次音量值

    private val mCallback = object : MediaControllerCompat.Callback() {

        override fun onPlaybackStateChanged(state: PlaybackStateCompat?) {
            updatePlaybackState(state)
        }

        override fun onMetadataChanged(metadata: MediaMetadataCompat?) {
            updateMetadata(metadata)
        }
    }

    private val mBleHandleCallback = object : BleHandleCallback {

        /**
         * 类似[onReceiveMusicCommand]
         */
        override fun onHIDValueChange(value: Int) {
            when (value) {
                HIDValue.NEXT_TRACK, HIDValue.PREVIOUS_TRACK, HIDValue.PLAY_OR_PAUSE -> {
                    BleLog.i("$LOG_HEADER onHIDValueChange $value , current activeMediaController = ${mActiveMediaController?.packageName} playbackState=${mActiveMediaController?.playbackState?.state}")
                    mMediaSessionManager?.getActiveSessions(ComponentName(mContext!!, mContext!!::class.java)).also { controllers ->
                        BleLog.i("$LOG_HEADER onHIDValueChange activeMediaControllers -> ${controllers?.map { "${it.packageName} playbackState=${it.playbackState?.state}" }}")
                        autoSwitchActiveController(controllers, true)
                    }
                }
            }
        }

        override fun onReceiveMusicCommand(musicCommand: MusicCommand) {
            when (musicCommand) {
                MusicCommand.PLAY, MusicCommand.PAUSE, MusicCommand.TOGGLE, MusicCommand.NEXT, MusicCommand.PRE -> {
                    BleLog.i("$LOG_HEADER onReceiveMusicCommand $musicCommand , current activeMediaController = ${mActiveMediaController?.packageName} playbackState=${mActiveMediaController?.playbackState?.state}")
                    /**
                     * 之前用[MediaSessionManager.OnActiveSessionsChangedListener]来切换最近操作的播放器，但是这个方法在不同的手机，不同的播放器回调有点混乱，在不同的播放器上切换，要么不回调，要么一下子回调多次，
                     * 还有因为存在多个播放器可能同时播放的情况，目前暂时还找不到合式的方式获取当前用户最近在操作的播放器，所以收到指令时，判断一下是否需要切换。
                     */
                    mMediaSessionManager?.getActiveSessions(ComponentName(mContext!!, mContext!!::class.java)).also { controllers ->
                        BleLog.i("$LOG_HEADER onReceiveMusicCommand activeMediaControllers -> ${controllers?.map { "${it.packageName} playbackState=${it.playbackState?.state}" }}")
                        autoSwitchActiveController(controllers, true)
                    }
                }
                else -> {}
            }

            //目前测试通过发送媒体按钮事件效果好点
            when (musicCommand) {
                MusicCommand.PLAY -> sendMediaKeyEvent(KeyEvent.KEYCODE_MEDIA_PLAY)
                MusicCommand.PAUSE -> sendMediaKeyEvent(KeyEvent.KEYCODE_MEDIA_PAUSE)
                //部分手机双击暂停/播放可切换下一首属于正常现象，无需处理
                MusicCommand.TOGGLE -> sendMediaKeyEvent(KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
                MusicCommand.NEXT -> sendMediaKeyEvent(KeyEvent.KEYCODE_MEDIA_NEXT)
                MusicCommand.PRE -> sendMediaKeyEvent(KeyEvent.KEYCODE_MEDIA_PREVIOUS)
                MusicCommand.VOLUME_UP -> {
                    //有些手机（已知小米的miui12以上版本）有【媒体音量控制】权限，默认仅在使用中允许调节音量，进入后台无法调节，需要始终允许才可以后台调节
                    mAudioManager?.adjustVolume(AudioManager.ADJUST_RAISE, AudioManager.FX_KEYPRESS_STANDARD)
                }
                MusicCommand.VOLUME_DOWN -> {
                    mAudioManager?.adjustVolume(AudioManager.ADJUST_LOWER, AudioManager.FX_KEYPRESS_STANDARD)
                }
                MusicCommand.UNKNOWN -> {
                }
            }
        }
    }

    override fun launch(context: NotificationListenerService) {
        super.launch(context)
        mMediaSessionManager = context.getSystemService(Context.MEDIA_SESSION_SERVICE) as MediaSessionManager
        mMediaSessionManager?.getActiveSessions(ComponentName(context, context::class.java)).also { controllers ->
            BleLog.i("$LOG_HEADER launch activeMediaControllers -> ${controllers?.map { "${it.packageName} playbackState=${it.playbackState?.state}" }}")
            autoSwitchActiveController(controllers)
        }
        BleConnector.addHandleCallback(mBleHandleCallback)
    }

    /**
     * 用来自动切换用户最近操作的播放器
     */
    private fun autoSwitchActiveController(
        activeMediaControllers: MutableList<MediaController>?,
        isRelease: Boolean = false
    ) {
        if (activeMediaControllers == null || activeMediaControllers.isEmpty()) {
            if (isRelease) {
                releaseActiveController()
            }
            BleConnector.updateMusic(
                BleMusicControl(
                    MusicEntity.TRACK,
                    MusicAttr.TRACK_DURATION,
                    "0"
                )
            )
        } else {
            //如果有多个播放器，存在同时播放的可能，目前测试的手机，一般来说最近开启播放操作的那个会放在第一位，有些不按规范来的播放器或者手机可能不一定放在第一位，暂时还没找到更合适的方式
            if (mActiveMediaController?.packageName != activeMediaControllers[0].packageName) {
                assignActiveController(activeMediaControllers[0])
            } else {
                //如果当前播放器不在播放状态下，但又有其他在播放，则切换到正在播放的
                if(mActiveMediaController?.playbackState?.state != PlaybackState.STATE_PLAYING){
                    activeMediaControllers.forEach {
                        if(it.playbackState?.state == PlaybackState.STATE_PLAYING){
                            assignActiveController(it)
                            return
                        }
                    }
                }
            }
        }
    }

    override fun exit() {
        BleLog.i("$LOG_HEADER exit")
        BleConnector.removeHandleCallback(mBleHandleCallback)
        releaseActiveController()
        super.exit()
    }

    private fun sendMediaKeyEvent(keyCode: Int) {
        mActiveMediaController?.run {
            BleLog.i("$LOG_HEADER keyEvent $keyCode")
            dispatchMediaButtonEvent(KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
            dispatchMediaButtonEvent(KeyEvent(KeyEvent.ACTION_UP, keyCode))
        }
    }

    override fun updateVolume(streamType: Int) {
        val volume = getStreamVolume(streamType)
        val max = getStreamMaxVolume(streamType)
        //过虑音量，避免音量变化太快设备处理不过来, 会导致很多指令响应延迟
        if (System.currentTimeMillis() - mLastVolumeTime <= 150) {
            //用户手动快速滑动手机音量条到最大或最小值时可以不过虑，避免与设备出现不一致的情况
            if (volume != 0 && volume != max) {
                return
            }
            //但是有一些手机，在某些情况下(如华为手机来电时)，会不停的触发音量变化广播，这个时候的音量值总是为0，也不排除不停的返回相同的音量值
            //这里避免短时间内发送大量相同音量值的情况
            if (volume == mLastVolume){
                return
            }
        }
        mLastVolumeTime = System.currentTimeMillis()
        val value = keepTwoDecimal(volume.toFloat() / max)
        if (BleConnector.updateMusic(
                BleMusicControl(MusicEntity.PLAYER, MusicAttr.PLAYER_VOLUME, value)
            )
        ) {
            mLastVolume = volume
        }
    }

    /**
     * 更新状态信息
     */
    fun updatePlaybackState(state: PlaybackStateCompat?) {
        BleLog.i("$LOG_HEADER updatePlaybackState -> state=${getState(state)} $state")
        if (state == null) return

        val s = when (state.state) {
            PlaybackState.STATE_PAUSED, PlaybackState.STATE_STOPPED -> MyState.PAUSED.mState
            PlaybackState.STATE_PLAYING -> MyState.PLAYING.mState
            PlaybackState.STATE_FAST_FORWARDING -> MyState.FAST_FORWARDING.mState
            PlaybackState.STATE_REWINDING -> MyState.REWINDING.mState
            else -> MyState.UNKNOWN.mState
        }

        if (s != MyState.UNKNOWN.mState) {
            val contents = listOf("$s", String.format("%.1f", state.playbackSpeed), ",${state.position / 1000}")
            BleLog.i("$LOG_HEADER updatePlaybackState -> contents=$contents")
            BleConnector.updateMusic(BleMusicControl(MusicEntity.PLAYER, MusicAttr.PLAYER_PLAYBACK_INFO
                , contents))
            updateVolume(AudioManager.STREAM_MUSIC)
        }

        //如果当前播放器是停放状态，有可能用户切换播放器，这里需要自动切换一下，有些手机或播放器不一定能正常切换，目前没更合适的方法，只能让用户尽量不要多个播放器切换
        if (s == MyState.PAUSED.mState) {
            if(mContext != null){
                val activeMediaControllers = mMediaSessionManager?.getActiveSessions(ComponentName(mContext!!, mContext!!::class.java))
                BleLog.i("$LOG_HEADER updatePlaybackState activeMediaControllers -> ${activeMediaControllers?.map { "${it.packageName} playbackState=${it.playbackState?.state}" }}")
                autoSwitchActiveController(activeMediaControllers,true)
            }
        }
    }

    /**
     * 更新播放信息
     */
    fun updateMetadata(metadata: MediaMetadataCompat?) {
        if (metadata == null) return

        val artist = metadata.getString(MediaMetadata.METADATA_KEY_ARTIST) ?: " "
        val album = metadata.getString(MediaMetadata.METADATA_KEY_ALBUM) ?: " "
        val title = metadata.getString(MediaMetadata.METADATA_KEY_TITLE) ?: " "
        val duration = "${metadata.getLong(MediaMetadata.METADATA_KEY_DURATION) / 1000}"
        BleLog.i("$LOG_HEADER updateMetadata -> METADATA_KEY_ARTIST=$artist , METADATA_KEY_ALBUM=$album, METADATA_KEY_TITLE=$title, METADATA_KEY_DURATION=$duration")
        BleConnector.updateMusic(BleMusicControl(MusicEntity.TRACK, MusicAttr.TRACK_ARTIST, artist))
        BleConnector.updateMusic(BleMusicControl(MusicEntity.TRACK, MusicAttr.TRACK_ALBUM, album))
        BleConnector.updateMusic(BleMusicControl(MusicEntity.TRACK, MusicAttr.TRACK_TITLE, title))
        BleConnector.updateMusic(BleMusicControl(MusicEntity.TRACK, MusicAttr.TRACK_DURATION, duration))
        updateVolume(AudioManager.STREAM_MUSIC)
    }

    /**
     * 激活控制器
     */
    private fun assignActiveController(mediaController: MediaController?) {
        try {
            releaseActiveController()
            BleLog.i("$LOG_HEADER assignActiveController -> ${mediaController?.packageName}")
            val token = MediaSessionCompat.Token.fromToken(mediaController?.sessionToken)
            mActiveMediaController = MediaControllerCompat(mContext, token)
            mActiveMediaController?.registerCallback(mCallback)

            //同时更新播放状态和媒体信息
            updatePlaybackState(mActiveMediaController?.playbackState)
            updateMetadata(mActiveMediaController?.metadata)
        } catch (e: Exception) {
            e.printStackTrace()
            BleLog.i("$LOG_HEADER assignActiveController -> error:${e.message}")
        }
    }

    private fun releaseActiveController() {
        BleLog.i("$LOG_HEADER releaseActiveController -> ${mActiveMediaController?.packageName}")
        if (mActiveMediaController != null) {
            mActiveMediaController?.unregisterCallback(mCallback)
            mActiveMediaController = null
        }
    }

    fun keepTwoDecimal(value: Float): String {
        return  if(!value.isFinite()){
            "0.00"
        }else {
            DecimalFormat("#.##", DecimalFormatSymbols.getInstance(Locale.ENGLISH))
                .format(value.toBigDecimal())
        }
    }

    companion object {
        const val LOG_HEADER = "MusicController"

        private fun getState(playbackState: PlaybackStateCompat?): String {
            if (playbackState == null) return "null"

            return when (playbackState.state) {
                PlaybackState.STATE_PAUSED -> "STATE_PAUSED"
                PlaybackState.STATE_PLAYING -> "STATE_PLAYING"
                PlaybackState.STATE_FAST_FORWARDING -> "STATE_FAST_FORWARDING"
                PlaybackState.STATE_REWINDING -> "STATE_REWINDING"
                PlaybackState.STATE_STOPPED -> "STATE_STOPPED"
                else -> "OTHER"
            }
        }
    }
}