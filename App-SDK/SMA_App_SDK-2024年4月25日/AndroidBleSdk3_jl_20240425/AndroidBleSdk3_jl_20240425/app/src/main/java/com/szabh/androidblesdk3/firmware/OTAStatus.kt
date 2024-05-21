package com.szabh.androidblesdk3.firmware

enum class OTAStatus {
    NONE, //未升级未开始
    UPGRADE_SCANNING_START,//扫描开始
    UPGRADE_SCANNING_TIMEOUT,//扫描超时
    UPGRADE_SCANNING_STOP,//扫描停止
    UPGRADE_PREPARE,//升级前准备工作
    UPGRADE_PREPARE_FAILED,//升级前准备工作失败
    UPGRADE_START,//升级开始
    UPGRADE_CHECKING,//文件校验中
    UPGRADEING,//升级中
    UPGRADE_STOP,//升级完成
    UPGRADE_FAILED, //升级失败
}