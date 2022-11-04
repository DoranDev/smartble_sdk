package id.kakzaki.smartble_sdk.activity

import android.app.ListActivity
import android.os.Bundle
import android.widget.ArrayAdapter
import id.kakzaki.smartble_sdk.tools.toast
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.component.BleHandleCallback
import com.szabh.smable3.entity.*
import kotlin.random.Random

class MusicControlActivity : ListActivity() {
    private val mContext by lazy { this }
    private val mBleHandleCallback = object : BleHandleCallback {

        override fun onReceiveMusicCommand(musicCommand: MusicCommand) {
            toast(mContext, "$musicCommand")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setupList()
        BleConnector.addHandleCallback(mBleHandleCallback)
    }

    override fun onDestroy() {
        BleConnector.removeHandleCallback(mBleHandleCallback)
        super.onDestroy()
    }

    private fun setupList() {
        val musicControls = arrayOf(
            BleMusicControl(MusicEntity.PLAYER, MusicAttr.PLAYER_NAME, "Music Player"),
            BleMusicControl(MusicEntity.PLAYER, MusicAttr.PLAYER_PLAYBACK_INFO, "${PlaybackState.PAUSED.mState}"),
            BleMusicControl(MusicEntity.PLAYER, MusicAttr.PLAYER_PLAYBACK_INFO, "${PlaybackState.PLAYING.mState}"),
            BleMusicControl(MusicEntity.PLAYER, MusicAttr.PLAYER_PLAYBACK_INFO, "${PlaybackState.REWINDING.mState}"),
            BleMusicControl(MusicEntity.PLAYER, MusicAttr.PLAYER_PLAYBACK_INFO, "${PlaybackState.FAST_FORWARDING.mState}"),
            BleMusicControl(MusicEntity.PLAYER, MusicAttr.PLAYER_VOLUME, String.format("%.2f", Random.nextDouble(0.0, 1.0))),
            BleMusicControl(MusicEntity.QUEUE, MusicAttr.QUEUE_INDEX, "0"),
            BleMusicControl(MusicEntity.QUEUE, MusicAttr.QUEUE_COUNT, "1"),
            BleMusicControl(MusicEntity.QUEUE, MusicAttr.QUEUE_SHUFFLE_MODE, "0"),
            BleMusicControl(MusicEntity.QUEUE, MusicAttr.QUEUE_REPEAT_MODE, "0"),
            BleMusicControl(MusicEntity.TRACK, MusicAttr.TRACK_ARTIST, "周杰伦"),
            BleMusicControl(MusicEntity.TRACK, MusicAttr.TRACK_ALBUM, "叶惠美"),
            BleMusicControl(MusicEntity.TRACK, MusicAttr.TRACK_TITLE, "以父之名"),
            BleMusicControl(MusicEntity.TRACK, MusicAttr.TRACK_DURATION, "342")
        )
        val array = musicControls.map { musicControl ->
            if (musicControl.mMusicEntity == MusicEntity.PLAYER
                && musicControl.mMusicAttr == MusicAttr.PLAYER_PLAYBACK_INFO) {
                "${musicControl.mMusicAttr}_" + when (musicControl.mContent) {
                    "${PlaybackState.PAUSED.mState}" -> "PAUSED"
                    "${PlaybackState.PLAYING.mState}" -> "PLAYING"
                    "${PlaybackState.REWINDING.mState}" -> "REWINDING"
                    "${PlaybackState.FAST_FORWARDING.mState}" -> "FAST_FORWARDING"
                    else -> "UNKNOWN"
                }
            } else {
                "${musicControl.mMusicAttr}"
            }
        }

        listView.apply {
            adapter = ArrayAdapter(mContext, android.R.layout.simple_list_item_1, array)
            setOnItemClickListener { _, _, position, _ ->
                BleConnector.sendObject(BleKey.MUSIC_CONTROL, BleKeyFlag.UPDATE, musicControls[position])
            }
        }
    }
}