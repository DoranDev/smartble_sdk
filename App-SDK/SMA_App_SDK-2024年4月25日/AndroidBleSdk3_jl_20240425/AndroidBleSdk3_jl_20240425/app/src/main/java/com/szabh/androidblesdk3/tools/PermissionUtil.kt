package com.szabh.androidblesdk3.tools

import com.blankj.utilcode.util.PermissionUtils

/**
 * 请求权限的逻辑为：
 * 1. 请求的权限列表只要有一项被拒绝，且点了不再提醒，将触发 DENIED_FOREVER。这时，可以弹出自定义对话框向用户说明权限用处。
 * 2. 请求的权限列表只要有一项被拒绝，将触发 DENIED。这时，可以继续申请权限，或不做任何操作。
 * 3. 请求的权限列表全部被同意，将触发 GRANTED，可做下一步操作。
 *
 * 调用方式如下：
 * PermissionUtils
 *     .permission(PermissionConstants.MICROPHONE)
 *     .request2 { status ->
 *         ...
 *     }
 */
fun PermissionUtils.request2(action: (PermissionStatus) -> Unit) {
    callback(object : PermissionUtils.FullCallback {

        override fun onGranted(permissionsGranted: MutableList<String>) {
            action(PermissionStatus.GRANTED)
        }

        override fun onDenied(permissionsDeniedForever: MutableList<String>, permissionsDenied: MutableList<String>) {
            if (permissionsDeniedForever.isNotEmpty()) {
                action(PermissionStatus.DENIED_FOREVER)
            } else if (permissionsDenied.isNotEmpty()) {
                action(PermissionStatus.DENIED)
            }
        }
    }).request()
}

enum class PermissionStatus {
    GRANTED, DENIED, DENIED_FOREVER
}