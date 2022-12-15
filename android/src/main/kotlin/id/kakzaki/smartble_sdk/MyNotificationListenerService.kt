//package id.kakzaki.smartble_sdk
//
//import android.content.ComponentName
//import android.content.Context
//import android.content.Intent
//import android.content.pm.PackageManager
//import android.os.Build
//import android.service.notification.NotificationListenerService
//import android.service.notification.StatusBarNotification
//import androidx.annotation.RequiresApi
//import androidx.core.app.NotificationManagerCompat
//import com.blankj.utilcode.util.LogUtils
//import com.blankj.utilcode.util.ServiceUtils
//import com.szabh.smable3.music.MusicControllerCompat
//
///**
// * 用于音乐控制
// * NotificationListenerService这个系统服务，只有在用户允许了通知栏使用权限之后，才会触发onCreate()
// */
//class MyNotificationListenerService : NotificationListenerService() {
//
//    private var mMusicControlCompat: MusicControllerCompat? = null
//
//    override fun onCreate() {
//        super.onCreate()
//        LogUtils.v("$LOG_HEADER onCreate")
//        mMusicControlCompat = MusicControllerCompat.newInstance().also { it.launch(this) }
//    }
//
//    override fun onDestroy() {
//        LogUtils.v("$LOG_HEADER onDestroy")
//        mMusicControlCompat?.exit()
//        super.onDestroy()
//    }
//
//    @RequiresApi(api = Build.VERSION_CODES.N)
//    override fun onListenerDisconnected() {
//        LogUtils.v("$LOG_HEADER onListenerDisconnected")
//        requestRebind(ComponentName(this, this::class.java))
//    }
//
//    override fun onNotificationPosted(sbn: StatusBarNotification) {
//        super.onNotificationPosted(sbn)
//    }
//
//    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
//    }
//
//    companion object {
//        private const val LOG_HEADER = "MyNotificationListenerService"
//
//        // 用户是否已经允许
//        fun isEnabled(context: Context) =
//            NotificationManagerCompat.getEnabledListenerPackages(context).contains(context.packageName).also {
//               LogUtils.v("$LOG_HEADER isEnabled=$it")
//            }
//
//        // 是否正在运行
//        private fun isRunning() =
//            ServiceUtils.isServiceRunning(MyNotificationListenerService::class.java).also {
//                LogUtils.v("$LOG_HEADER isRunning=$it")
//            }
//
//        // 跳转到通知使用权设置
//        fun toEnable(context: Context) {
////            LogUtils.v("$LOG_HEADER toEnable")
//            context.startActivity(Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS"))
//        }
//
//        // 在小米6上测试时，disable并且等到isRunning()返回false，然后enable，如果用户之前已经允许, 会重新触发onCreate()，
//        // 通知使用权界面会重新出现该服务
//        private fun enable(context: Context) {
////            LogUtils.v("$LOG_HEADER enable")
//            val componentName = ComponentName(context, MyNotificationListenerService::class.java)
//            context.packageManager.setComponentEnabledSetting(
//                componentName, PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
//                PackageManager.DONT_KILL_APP
//            )
//        }
//
//        // 在小米6上测试时，disable后不管该服务有没有运行，都不会触发onListenerDisconnected()和onDestroy()，
//        // 如果用户之前已经允许，isEnabled()会返回true，否则返回false，
//        // 如果该服务已经运行，isRunning()在大约10秒之后才返回false
//        // 并且在通知使用权界面就没有该服务了，
//        private fun disable(context: Context) {
////            LogUtils.v("$LOG_HEADER disable")
//            val componentName = ComponentName(context, MyNotificationListenerService::class.java)
//            context.packageManager.setComponentEnabledSetting(
//                componentName, PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
//                PackageManager.DONT_KILL_APP
//            )
//        }
//
//        // 在小米6上测试时，如果该服务已经运行，reEnable不会触发任何回调，推断可能是因为disable需要一些时间
//        private fun reEnable(context: Context) {
//            LogUtils.v("$LOG_HEADER reEnable")
//            disable(context)
//            enable(context)
//        }
//
//        // 如果用户已经允许，但是没有运行，重启该服务
//        fun checkAndReEnable(context: Context) {
////            LogUtils.v("$LOG_HEADER checkAndReEnable")
//            if (isEnabled(context) && !isRunning()) {
//                reEnable(context)
//            }
//        }
//
//    }
//}