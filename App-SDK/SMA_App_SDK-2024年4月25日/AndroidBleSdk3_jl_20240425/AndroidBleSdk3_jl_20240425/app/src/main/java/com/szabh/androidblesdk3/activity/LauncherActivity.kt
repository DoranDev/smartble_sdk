package com.szabh.androidblesdk3.activity

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.szabh.androidblesdk3.R
import com.szabh.androidblesdk3.copyAssert
import com.szabh.smable3.component.BleConnector

class LauncherActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_launcher)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        findViewById<View>(R.id.iv).animate().scaleX(1.06f).scaleY(1.06f).setDuration(2000)
            .setListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    copyAssert(this@LauncherActivity) {
                        if (BleConnector.isBound()) {
                            startActivity(Intent(this@LauncherActivity, CommandListActivity::class.java))
                        } else {
                            startActivity(Intent(this@LauncherActivity, MainActivity::class.java))
                        }
                        finish()
                    }
                }
            })
        findViewById<TextView>(R.id.tv).text = getString(R.string.app_des,
            packageManager.getPackageInfo(packageName, PackageManager.GET_CONFIGURATIONS).versionName)
    }
}