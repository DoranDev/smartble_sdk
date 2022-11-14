package com.szabh.smable3.component

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import com.abupdate.iot_libs.OtaAgentPolicy
import com.abupdate.iot_libs.constant.BroadcastConsts
import com.bestmafen.baseble.connector.AbsBleConnector
import com.bestmafen.baseble.connector.BleGattCallback
import com.bestmafen.baseble.data.*
import com.bestmafen.baseble.messenger.BleMessage
import com.bestmafen.baseble.messenger.ReadMessage
import com.bestmafen.baseble.messenger.WriteMessage
import com.bestmafen.baseble.util.BleLog
import com.realsil.sdk.core.RtkConfigure
import com.realsil.sdk.core.RtkCore
import com.realsil.sdk.dfu.RtkDfu
import com.szabh.smable3.BleCommand
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.MessageFactory.HEADER_NACK
import com.szabh.smable3.component.MessageFactory.HEADER_REPLY
import com.szabh.smable3.component.MessageFactory.LENGTH_BEFORE_CMD
import com.szabh.smable3.component.MessageFactory.LENGTH_BEFORE_DATA
import com.szabh.smable3.entity.*
import id.kakzaki.smartble_sdk.BuildConfig
import no.nordicsemi.android.dfu.DfuServiceInitiator
import java.io.File
import java.io.FileInputStream
import java.io.InputStream
import java.nio.ByteOrder
import java.util.*
import java.util.concurrent.CopyOnWriteArrayList
import kotlin.math.min
import kotlin.random.Random

@SuppressLint("StaticFieldLeak")
object BleConnector : AbsBleConnector() {
    private const val TAG = "BleConnector"

    private const val BLE_SERVICE = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    private const val BLE_CH_WRITE = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    private const val BLE_CH_NOTIFY = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

//    private const val BLE_SERVICE = "0000a00a-0000-1000-8000-00805f9b34fb"
//    private const val BLE_CH_WRITE = "0000b002-0000-1000-8000-00805f9b34fb"
//    private const val BLE_CH_NOTIFY = "0000b003-0000-1000-8000-00805f9b34fb"

    // 用于读取MTK设备的固件信息，即艾拉比平台上相关项目配置。
    const val SERVICE_MTK = "c6a22905-f821-18bf-9704-0266f20e80fd"
    const val CH_MTK_OTA_META = "c6a22916-f821-18bf-9704-0266f20e80fd"

    private const val SERVICE_MTK_OTA = "c6a2b98b-f821-18bf-9704-0266f20e80fd"
    private const val CH_MTK_OTA_SIZE = "c6a22920-f821-18bf-9704-0266f20e80fd"
    private const val CH_MTK_OTA_FLAG = "c6a22922-f821-18bf-9704-0266f20e80fd"
    private const val CH_MTK_OTA_DATA = "c6a22924-f821-18bf-9704-0266f20e80fd"
    private const val CH_MTK_OTA_MD5 = "c6a22926-f821-18bf-9704-0266f20e80fd"

    /**
     * MTK设备Ota时，每包的长度。
     */
    private const val MTK_OTA_PACKET_SIZE = 180

    /**
     * Nordic 设备是否在连接上直接进入OTA模式 -- App测试模式所需
     */
    private var isNordicOtaMode = false

    var mHidState = HIDState.DISCONNECTED

    override val mService: String by lazy { BLE_SERVICE }

    override val mNotify: String by lazy { BLE_CH_NOTIFY }

    override val mBleMessenger: BleMessenger by lazy {
        BleMessenger().apply {
            mMessengerCallback = object : BleMessengerCallback {

                override fun onRetry() {
                    mBleParser.reset()
                }

                override fun onTimeout(message: BleMessage) {
                    if(mBleStream != null){
                        mBleMessenger.reset()
                        mBleStream = null
                    }
                    if (message is WriteMessage) {
                        val bleKey = BleKey.of(message.mData.getInt(LENGTH_BEFORE_CMD, 2))
                        val bleKeyFlag = BleKeyFlag.of(message.mData[LENGTH_BEFORE_CMD + 2].toInt())
                        BleLog.d("$TAG onCommandSendTimeout -> key=$bleKey, keyFlag=$bleKeyFlag")
                        notifyHandlers { it.onCommandSendTimeout(bleKey, bleKeyFlag) }
                    }
                }
            }
        }
    }

    override val mBleParser: BleParser by lazy {
        BleParser.apply {

        }
    }

    private val mBleHandleCallbacks by lazy {
        CopyOnWriteArrayList<BleHandleCallback>()
    }

    private var mBleState: Int = BleState.DISCONNECTED

    private var mDataKeys: MutableList<BleKey> = mutableListOf()
    private val mSyncTimeout = Runnable {
        if (mDataKeys.isNotEmpty()) {
            notifySyncState(SyncState.TIMEOUT, mDataKeys[0])
            mDataKeys.clear()
        } else {
            notifySyncState(SyncState.TIMEOUT, BleKey.NONE)
        }
    }

    private val mMusicSubscriptions: MutableMap<MusicEntity, List<MusicAttr>> = EnumMap(MusicEntity::class.java)

    private var mBleStream: BleStream? = null
        set(value) {
            field = value
            disableStreamLog = value != null
        }

    override var isConnecting = false
        set(value) {
            field = value
            BleLog.d("$TAG onDeviceConnecting -> $value")
            notifyHandlers { it.onDeviceConnecting(value) }
        }

    private var mStreamProgressTotal = -1
    private var mStreamProgressCompleted = -1

    /**
     * 标记是否过滤空数据，特定用户的需求，一般无需设置
     */
    private var mSupportFilterEmpty = true

    /**
     * 批量升级模式下不需要绑定
     */
    var isNeedBind = true

    private fun init(
        context: Context,
        supportRealtekDfu: Boolean = false,
        supportMtkOta: Boolean = false,
        supportLauncher: Boolean = true,
        supportFilterEmpty: Boolean = true
    ): BleConnector {
        mSupportFilterEmpty = supportFilterEmpty

        super.init(context, object : BleGattCallback {

            override fun onConnectionStateChange(connected: Boolean) {
                val device = mBluetoothGatt!!.device
                if (connected) {
                    BleLog.d("$TAG onDeviceConnected -> $device")
                    mBleState = BleState.CONNECTED
                    notifyHandlers { it.onDeviceConnected(device) }
                    mStreamProgressTotal = -1
                    mStreamProgressCompleted = -1
                } else {
                    BleLog.d("$TAG onSessionStateChange -> false")
                    mBleState = BleState.DISCONNECTED
                    notifyHandlers { it.onSessionStateChange(false) }
                    if (mDataKeys.isNotEmpty()) {
                        notifySyncState(SyncState.DISCONNECTED, mDataKeys[0])
                        mDataKeys.clear()
                        removeSyncTimeout()
                    }
                    if (mBleStream != null) {
                        notifyHandlers { it.onStreamProgress(false, -1, 0, 0) }
                    }
                    checkStreamProgress()
                }
                mBleStream = null
            }

            override fun onCharacteristicRead(
                characteristicUuid: String,
                value: ByteArray,
                text: String
            ) {
                if (characteristicUuid == CH_MTK_OTA_META) {
                    BleCache.putMtkOtaMeta(text)
                    notifyHandlers { it.onReadMtkOtaMeta() }
                }
            }

            override fun onCharacteristicWrite(characteristicUuid: String, value: ByteArray) {
                if (characteristicUuid == CH_MTK_OTA_DATA) {
                    mStreamProgressCompleted++
                    checkStreamProgress()
                }
            }

            override fun onCharacteristicChanged(value: ByteArray) {
                handleData(value)
            }

            override fun onMtuChanged() {
                mBleState = BleState.READY
                if (isNordicOtaMode) {
                    if (isNeedBind) {
                        sendOta()
                    }
                } else {
                    val deviceInfo = BleCache.mDeviceInfo
                    if (deviceInfo != null) {
                        BleLog.v("$TAG DeviceInfo not null -> login")
                        login(deviceInfo.mId)
                    } else {
                        BleLog.v("$TAG DeviceInfo is null -> bind")
                        if (isNeedBind) {
                            bind()
                        }
                    }
                }
            }
        })
        BleCache.mDeviceInfo = BleCache.getObject(BleKey.IDENTITY, BleDeviceInfo::class.java)

        if (supportLauncher) launch()

        // 防止Nordic Dfu时报错
        // android.app.RemoteServiceException
        // Bad notification for startForeground: java.lang.RuntimeException: invalid channel for service
        // notification: Notification(channel=dfu pri=-1 contentView=null vibrate=null sound=null defaults=0x0 flags=0x42 color=0xff888888 vis=PRIVATE)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            DfuServiceInitiator.createDfuNotificationChannel(mContext)
        }
        if (supportRealtekDfu) {
            val configure = RtkConfigure.Builder()
                .debugEnabled(BuildConfig.DEBUG)
                .printLog(BuildConfig.DEBUG)
                .logTag("RealtekDfu")
                .build()
            RtkCore.initialize(context, configure)
            RtkDfu.initialize(context, BuildConfig.DEBUG)
        }
        if (supportMtkOta) {
            BroadcastConsts.PACKAGE_FOTA_UPDATE = context.packageName
            OtaAgentPolicy.init(context)
        }
        return this
    }

    /**
     * 如果已绑定设备，连接该设备
     */
    fun launch() {
        if (BleCache.mDeviceInfo != null) {
            //如果旧版本没有申请这几个权限，更新升级重新进入app需要提醒用户申请权限
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
                && (mContext.checkSelfPermission(Manifest.permission.BLUETOOTH_SCAN) != PackageManager.PERMISSION_GRANTED
                        || mContext.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
                        || mContext.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED)
            ) {
                BleLog.e("$TAG launch -> Need new bluetooth permission!!!")
                return
            }
            BleLog.d("$TAG launch -> deviceInfo=${BleCache.mDeviceInfo}")
            setAddress(BleCache.mDeviceInfo!!.mBleAddress)
            connect(true)
        } else {
            BleLog.d("$TAG launch -> deviceInfo=null")
        }
    }

    fun addHandleCallback(bleHandleCallback: BleHandleCallback) {
        BleLog.d("$TAG addHandleCallback -> $bleHandleCallback")
        if (mBleHandleCallbacks.contains(bleHandleCallback)) {
            throw UnsupportedOperationException("bleHandleCallback already exists")
        }

        mBleHandleCallbacks.add(bleHandleCallback)
    }

    fun removeHandleCallback(bleHandleCallback: BleHandleCallback) {
        BleLog.d("$TAG removeHandleCallback -> $bleHandleCallback")
        if (!mBleHandleCallbacks.contains(bleHandleCallback)) {
            throw UnsupportedOperationException("bleHandleCallback dose not exist")
        }

        mBleHandleCallbacks.remove(bleHandleCallback)
    }

    fun sendData(
        bleKey: BleKey, bleKeyFlag: BleKeyFlag, bytes: ByteArray? = null,
        reply: Boolean = false, nack: Boolean = false
    ): Boolean {
        BleLog.d("$TAG sendData -> $bleKey, $bleKeyFlag")
        if (!isAvailable()) return false

        if (bleKey == BleKey.DATA_ALL && bleKeyFlag == BleKeyFlag.READ) {
            return syncData()
        }

        var headerFlag = 0
        if (reply) {
            headerFlag = headerFlag.or(HEADER_REPLY)
        }
        if (nack) {
            headerFlag = headerFlag.or(HEADER_NACK)
        }
        WriteMessage(BLE_SERVICE, BLE_CH_WRITE, MessageFactory.create(headerFlag, bleKey, bleKeyFlag, bytes)).let {
            if (reply) {
                mBleMessenger.replyMessage(it)
            } else {
                mBleMessenger.enqueueMessage(it)
            }
        }
        return true
    }

    fun sendBoolean(
        bleKey: BleKey, bleKeyFlag: BleKeyFlag, value: Boolean,
        reply: Boolean = false, nack: Boolean = false
    ): Boolean {
        val bytes = byteArrayOfBoolean(value)
        return sendData(bleKey, bleKeyFlag, bytes, reply, nack).also {
            if (it && BleCache.requireCache(bleKey, bleKeyFlag)) {
                BleCache.putBoolean(bleKey, value)
            }
        }
    }

    fun sendInt8(
        bleKey: BleKey, bleKeyFlag: BleKeyFlag, value: Int, reply: Boolean = false,
        nack: Boolean = false
    ): Boolean {
        val bytes = byteArrayOfInt8(value)
        return sendData(bleKey, bleKeyFlag, bytes, reply, nack).also {
            if (it && BleCache.requireCache(bleKey, bleKeyFlag)) {
                if (bleKey.isIdObjectKey()) {
                    val idObjects = BleCache.getIdObjects(bleKey)
                    if (bleKeyFlag == BleKeyFlag.DELETE) {
                        if (value == ID_ALL) {
                            idObjects.clear()
                        } else {
                            val index = idObjects.indexOfFirst { idObject -> idObject.mId == value }
                            if (index > -1) idObjects.removeAt(index)
                        }
                    }
                    BleCache.putList(bleKey, idObjects)
                } else {
                    BleCache.putInt(bleKey, value)
                }
            }
        }
    }

    fun sendInt16(
        bleKey: BleKey, bleKeyFlag: BleKeyFlag, value: Int, order: ByteOrder = ByteOrder.BIG_ENDIAN,
        reply: Boolean = false, nack: Boolean = false
    ): Boolean {
        val bytes = byteArrayOfInt16(value, order)
        return sendData(bleKey, bleKeyFlag, bytes, reply, nack).also {
            if (it && BleCache.requireCache(bleKey, bleKeyFlag)) {
                BleCache.putInt(bleKey, value)
            }
        }
    }

    fun sendInt24(
        bleKey: BleKey, bleKeyFlag: BleKeyFlag, value: Int, order: ByteOrder = ByteOrder.BIG_ENDIAN,
        reply: Boolean = false, nack: Boolean = false
    ): Boolean {
        val bytes = byteArrayOfInt24(value, order)
        return sendData(bleKey, bleKeyFlag, bytes, reply, nack).also {
            if (it && BleCache.requireCache(bleKey, bleKeyFlag)) {
                BleCache.putInt(bleKey, value)
            }
        }
    }

    fun sendInt32(
        bleKey: BleKey, bleKeyFlag: BleKeyFlag, value: Int, order: ByteOrder = ByteOrder.BIG_ENDIAN,
        reply: Boolean = false, nack: Boolean = false
    ): Boolean {
        val bytes = byteArrayOfInt32(value, order)
        return sendData(bleKey, bleKeyFlag, bytes, reply, nack).also {
            if (it && BleCache.requireCache(bleKey, bleKeyFlag)) {
                BleCache.putInt(bleKey, value)
            }
        }
    }

    fun sendObject(
        bleKey: BleKey, bleKeyFlag: BleKeyFlag, buf: BleBuffer?, reply: Boolean = false,
        nack: Boolean = false
    ): Boolean {
        if (!isAvailable()) return false

        var idObjects: MutableList<BleIdObject> = mutableListOf() // 本地缓存的IdObject列表
        if (buf is BleIdObject) {
            idObjects = BleCache.getIdObjects(bleKey)
            if (bleKeyFlag == BleKeyFlag.CREATE) {
                val ids = idObjects.map { it.mId }.toMutableList() // 本地缓存的id
                if (buf is BleCoaching) { // coaching除了本地有缓存，设备端也可能有缓存
                    val coachingIds = BleCache.getObject(
                        BleKey.COACHING, BleCoachingIds::class.java,
                        BleKeyFlag.READ
                    )
                    if (coachingIds != null) {
                        ids.addAll(coachingIds.mIds)
                    }
                }
                for (i in 0 until ID_ALL) { // 分配一个0～0xfe之间还未缓存的id
                    if (!ids.contains(i)) {
                        buf.mId = i
                        break
                    }
                }
                idObjects.add(buf)
            } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
                val index = idObjects.indexOfFirst { it.mId == buf.mId } // 根据id查到本地缓存
                if (index > -1) idObjects[index] = buf
            }
        }
        return sendData(bleKey, bleKeyFlag, buf?.toByteArray(), reply, nack).also {
            if (it && BleCache.requireCache(bleKey, bleKeyFlag)) {
                if (buf is BleIdObject) {
                    BleCache.putList(bleKey, idObjects) // 缓存追加或者修改后的列表
                } else {
                    BleCache.putObject(bleKey, buf)
                }
            }
        }
    }

    // 非IdObject的情况逻辑不一定正确，但是现在还没有非IdObject的情况，如果有的话需要修改相关代码
    fun sendList(
        bleKey: BleKey, bleKeyFlag: BleKeyFlag, list: List<BleBuffer>?,
        reply: Boolean = false, nack: Boolean = false
    ): Boolean {
        if (!isAvailable()) return false

        var bytes: ByteArray? = null // 待发送的数据
        var idObjects: MutableList<BleIdObject> = mutableListOf() // 本地缓存列表
        if (bleKey.isIdObjectKey()) {
            idObjects = BleCache.getIdObjects(bleKey)
            if (bleKeyFlag == BleKeyFlag.CREATE) {
                val ids = idObjects.map { it.mId }.toMutableList() // 本地缓存的id
                list?.forEach { bleBuffer ->
                    if (bleBuffer is BleIdObject) {
                        for (i in 0 until ID_ALL) {
                            if (!ids.contains(i)) {
                                bleBuffer.mId = i
                                bytes = bytes.append(bleBuffer.toByteArray())
                                idObjects.add(bleBuffer)
                                ids.add(i)
                                break
                            }
                        }
                    }
                }
            } else if (bleKeyFlag == BleKeyFlag.RESET) {
                idObjects.clear()
                list?.forEachIndexed { index, bleBuffer ->
                    if (bleBuffer is BleIdObject) {
                        bleBuffer.mId = index
                        bytes = bytes.append(bleBuffer.toByteArray())
                        idObjects.add(bleBuffer)
                    }
                }
                // 发送Delete All会删除设备和本地所有缓存
                sendInt8(bleKey, BleKeyFlag.DELETE, ID_ALL)
            }
        } else {
            if (bleKeyFlag == BleKeyFlag.CREATE) {
                list?.forEach {
                    bytes = bytes.append(it.toByteArray())
                }
            }
        }
        return sendData(
            bleKey, if (bleKeyFlag == BleKeyFlag.RESET) BleKeyFlag.CREATE else bleKeyFlag,
            bytes, reply, nack
        ).also {

            if (it && BleCache.requireCache(bleKey, bleKeyFlag)) {
                if (bleKey.isIdObjectKey()) {
                    if (bleKeyFlag == BleKeyFlag.CREATE || bleKeyFlag == BleKeyFlag.RESET) {
                        BleCache.putList(bleKey, idObjects)
                    }
                } else {
                    BleCache.putList(bleKey, list)
                }
            }
        }
    }

    /**
     * 发送过程中会触发[BleHandleCallback.onStreamProgress]。
     */
    fun sendStream(bleKey: BleKey, bytes: ByteArray, type: Int = 0): Boolean {
        if (bytes.isEmpty()) return false

        mBleStream = BleStream(bleKey, type, bytes)
        val streamPacket = mBleStream?.getPacket(0, BleCache.mIOBufferSize)
        if (streamPacket != null) {
            return sendObject(mBleStream!!.mBleKey, BleKeyFlag.UPDATE, streamPacket)
        }

        return false
    }

    fun sendStream(bleKey: BleKey, inputStream: InputStream, type: Int = 0): Boolean {
        return try {
            val bytes = inputStream.use {
                it.readBytes()
            }
            sendStream(bleKey, bytes, type)
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun sendStream(bleKey: BleKey, file: File, type: Int = 0): Boolean {
        return sendStream(bleKey, file.inputStream(), type)
    }

    fun sendStream(bleKey: BleKey, path: String, type: Int = 0): Boolean {
        return sendStream(bleKey, FileInputStream(path), type)
    }

    fun sendStream(bleKey: BleKey, rawRes: Int, type: Int = 0): Boolean {
        return sendStream(bleKey, mContext.resources.openRawResource(rawRes), type)
    }

    /**
     * MTK设备Ota，发送过程中会触发[BleHandleCallback.onStreamProgress]。
     */
    fun mtkOta(bytes: ByteArray) {
        if (!isAvailable() || bytes.isEmpty()) {
            notifyHandlers { it.onStreamProgress(false, -1, 0, 0) }
            return
        }

        mStreamProgressTotal =
            if (bytes.size % MTK_OTA_PACKET_SIZE == 0)
                bytes.size / 180
            else
                bytes.size / 180 + 1
        mStreamProgressCompleted = 0

        mBleMessenger.enqueueWritePackets(
            WriteMessage(
                SERVICE_MTK_OTA, CH_MTK_OTA_SIZE,
                byteArrayOfInt32(bytes.size, ByteOrder.LITTLE_ENDIAN)
            )
        )
        mBleMessenger.enqueueWritePackets(
            WriteMessage(
                SERVICE_MTK_OTA, CH_MTK_OTA_FLAG,
                byteArrayOf(0x01)
            )
        )
        for (i in 0 until mStreamProgressTotal) {
            val end = min((i + 1) * MTK_OTA_PACKET_SIZE, bytes.size)
            mBleMessenger.enqueueWritePackets(
                WriteMessage(
                    SERVICE_MTK_OTA, CH_MTK_OTA_DATA,
                    bytes.sliceArray(i * MTK_OTA_PACKET_SIZE until end)
                )
            )
        }
        mBleMessenger.enqueueWritePackets(
            WriteMessage(
                SERVICE_MTK_OTA, CH_MTK_OTA_FLAG,
                byteArrayOf(0x02)
            )
        )
        mBleMessenger.enqueueWritePackets(
            WriteMessage(
                SERVICE_MTK_OTA, CH_MTK_OTA_MD5,
                "b3b27696771768c6648f237a43c37a39".toByteArray()
            )
        )
    }

    fun mtkOta(inputStream: InputStream) {
        mtkOta(inputStream.use { it.readBytes() })
    }

    fun mtkOta(file: File) {
        mtkOta(file.inputStream())
    }

    fun mtkOta(path: String) {
        mtkOta(FileInputStream(path))
    }

    fun mtkOta(rawRes: Int) {
        mtkOta(mContext.resources.openRawResource(rawRes))
    }

    /**
     * 连接蓝牙3.0，连接之前开启经典蓝牙扫描可强制让配对提示弹在前台，否则可能弹在通知栏。
     * 就算调用前手机已经与经典蓝牙连接，[BluetoothSocket.connect]也可正常返回。
     */
    fun connectClassic() {
        val isStartBond =
            //目前兼容性还未知，暂时只有杰里平台强制使用TRANSPORT_BREDR方式
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M
                && BleCache.mPlatform == BleDeviceInfo.PLATFORM_JL
            ) {
                createBond(BleCache.mClassicAddress, BluetoothDevice.TRANSPORT_BREDR)
            } else {
                createBond(BleCache.mClassicAddress)
            }
        BleLog.v("connectClassic -> $isStartBond")
    }

    fun connectHID() {
        val isStartBond = createBond(BleCache.mBleAddress)
        BleLog.v("connectHID -> $isStartBond")
    }

    private fun createBond(address: String): Boolean? {
        if (!BluetoothAdapter.checkBluetoothAddress(address)) return false

        val remoteDevice: BluetoothDevice? =
            BluetoothAdapter.getDefaultAdapter()?.getRemoteDevice(address)
        return remoteDevice?.createBond()
    }

    /**
     * 通过反射的方式调用系统配对, 可以指定配对方式
     */
    private fun createBond(address: String, transport: Int): Boolean? {
        if (!BluetoothAdapter.checkBluetoothAddress(address)) return false

        val device: BluetoothDevice? =
            BluetoothAdapter.getDefaultAdapter()?.getRemoteDevice(address)

        if (device != null) {
            try {
                val createBondMethod = device::class.java.getMethod("createBond", Int::class.java)
                createBondMethod.isAccessible = true
                val result = createBondMethod.invoke(device, transport)
                BleLog.v("$TAG invoke createBond -> $result")
                if (result is Boolean) return result else false
            } catch (e: Exception) {
                BleLog.w("$TAG invoke createBond error -> $e")
            }
        }
        return device?.createBond()
    }


    /**
     * 解除经典蓝牙与系统的配对。
     * 以下手机有效：三星S5(10T客户的)
     * 以下手机无效：小米6(肖凯的)
     */
    private fun unbindClassic() {
        removeBond(BleCache.mClassicAddress)
    }

    private fun unbindHID() {
        removeBond(BleCache.mBleAddress)
    }

    private fun removeBond(address: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S
            && ActivityCompat.checkSelfPermission(mContext,
                Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
        ) {
            return
        }
        if (!BluetoothAdapter.checkBluetoothAddress(address)) return

        for (device in BluetoothAdapter.getDefaultAdapter().bondedDevices) {
            if (device.address.equals(address, true)) {
                try {
                    val removeBond = device::class.java.getMethod("removeBond")
                    val result = removeBond.invoke(device)
                    BleLog.v("$TAG removeBond -> $result")
                } catch (e: Exception) {
                    BleLog.w("$TAG removeBond -> $e")
                }
                break
            }
        }
    }

    private fun syncData(): Boolean {
        mDataKeys = BleCache.mDataKeys
            .filter { it != BleKey.DATA_ALL.mKey }
            .map { BleKey.of(it) }
            .toMutableList()
        return if (mDataKeys.isEmpty()) {
            notifySyncState(SyncState.COMPLETED, BleKey.NONE)
            true
        } else {
            postDelaySyncTimeout()
            sendData(mDataKeys[0], BleKeyFlag.READ)
        }
    }

    fun read(service: String, characteristic: String): Boolean {
        if (!isAvailable()) return false

        mBleMessenger.enqueueMessage(ReadMessage(service, characteristic))
        return true
    }

    fun updateMusic(bleMusicControl: BleMusicControl): Boolean {
        if (mMusicSubscriptions[bleMusicControl.mMusicEntity] != null
            && mMusicSubscriptions[bleMusicControl.mMusicEntity]!!.contains(bleMusicControl.mMusicAttr)
        ) {
            return sendObject(BleKey.MUSIC_CONTROL, BleKeyFlag.UPDATE, bleMusicControl)
        }

        return true
    }

    private fun sendOta() {
        sendData(BleKey.OTA, BleKeyFlag.UPDATE)
    }

    private fun bind() {
        sendInt32(BleKey.IDENTITY, BleKeyFlag.CREATE, Random.Default.nextInt())
    }

    fun unbind() {
        unbindClassic()
        //支持HID才解绑，如果支持HID，后续还要观察一下鸿蒙系统是否正常解绑
        if (BleCache.mSupportHID == BleDeviceInfo.SUPPORT_HID_1) {
            unbindHID()
        }
        BleCache.run {
            mDeviceInfo = null
            remove(BleKey.IDENTITY)
        }
        closeConnection(true)
    }

    fun isBound() = BleCache.mDeviceInfo != null

    private fun login(id: Int) {
        sendInt32(BleKey.SESSION, BleKeyFlag.CREATE, id)
    }

    fun isAvailable(): Boolean {
        return mBleState >= BleState.READY
    }

    private fun handleData(data: ByteArray) {
        try {
            val isReply = MessageFactory.isReply(data)
            if (isReply) {
                mBleMessenger.dequeueMessage()
            }

            if (!MessageFactory.isValid(data)) return

            var dataCount = 0
            val bleKey = BleKey.of(data.getInt(LENGTH_BEFORE_CMD, 2))
            val bleKeyFlag = BleKeyFlag.of(data[LENGTH_BEFORE_CMD + 2].toInt())
            BleLog.d("$TAG handleData -> key=$bleKey, keyFlag=$bleKeyFlag, isReply=$isReply")
            when (bleKey) {
                // BleCommand.UPGRADE
                BleKey.OTA -> {
                    if (data.size < LENGTH_BEFORE_DATA + 1) return

                    val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                    BleLog.v("$TAG handleData onOTA -> $status")
                    notifyHandlers { it.onOTA(status) }
                }
                BleKey.XMODEM -> {
//                    if (value.size < LENGTH_BEFORE_DATA + 1) return
//
//                    val status = value[LENGTH_BEFORE_DATA]
//                    L.v("$TAG handleData onXModem -> ${BleUtils.getXModemStatus(status)}")
//                    notifyHandlers { it.onXModem(status) }
                }

                // BleCommand.SET
                BleKey.POWER -> {
                    if (!isReply){
                        sendData(bleKey, bleKeyFlag, null, true)
                    }
                    if (data.size < LENGTH_BEFORE_DATA + 1) return

                    var power = data[LENGTH_BEFORE_DATA].toInt()
                    if (power < 0) power = 0
                    if (power > 100) power = 100
                    BleLog.v("$TAG handleData onReadPower -> $power")
                    notifyHandlers { it.onReadPower(power) }
                }
                BleKey.FIRMWARE_VERSION, BleKey.UI_PACK_VERSION -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        BleReadable.ofObject<BleVersion>(data, LENGTH_BEFORE_DATA).mVersion
                            .let { version ->
                                when (bleKey) {
                                    BleKey.FIRMWARE_VERSION -> {
                                        BleLog.v("$TAG handleData onReadFirmwareVersion -> $version")
                                        val oldVersion = BleCache.getString(bleKey)
                                        if (oldVersion.isNotEmpty() && oldVersion != version
                                            && BleCache.mSupportReadDeviceInfo == BleDeviceInfo.SUPPORT_READ_DEVICE_INFO_1
                                        ) {
                                            sendData(BleKey.IDENTITY, BleKeyFlag.READ)
                                        }
                                        BleCache.putString(bleKey, version)
                                        notifyHandlers { it.onReadFirmwareVersion(version) }
                                    }
                                    BleKey.UI_PACK_VERSION -> {
                                        BleLog.v("$TAG handleData onReadUiPackVersion -> $version")
                                        BleCache.putString(bleKey, version)
                                        notifyHandlers { it.onReadUiPackVersion(version) }
                                    }
                                    else -> {
                                    }
                                }
                            }
                    }
                }
                BleKey.LANGUAGE_PACK_VERSION -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        BleReadable.ofObject<BleLanguagePackVersion>(data, LENGTH_BEFORE_DATA)
                            .let { version ->
                                BleCache.putObject(bleKey, version)
                                BleLog.v("$TAG handleData onReadLanguagePackVersion -> $version")
                                notifyHandlers { it.onReadLanguagePackVersion(version) }
                            }
                    }
                }
                BleKey.BLE_ADDRESS -> {
                    BleReadable.ofObject<BleBleAddress>(data, LENGTH_BEFORE_DATA).mAddress
                        .let { address ->
                            BleLog.v("$TAG handleData onReadBleAddress -> $address")
                            notifyHandlers { it.onReadBleAddress(address) }
                        }
                }
                BleKey.USER_PROFILE -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        BleReadable.ofObject<BleUserProfile>(data, LENGTH_BEFORE_DATA)
                            .let { userProfile ->
                                BleLog.v("$TAG handleData onReadUserProfile -> $userProfile")
                            }
                    }
                }
                BleKey.SEDENTARINESS -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        BleReadable.ofObject<BleSedentarinessSettings>(data, LENGTH_BEFORE_DATA)
                            .let { sedentariness ->
                                BleLog.v("$TAG handleData onReadSedentariness -> $sedentariness")
                                notifyHandlers { it.onReadSedentariness(sedentariness) }
                            }
                    }
                }
                BleKey.NO_DISTURB_RANGE -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        BleReadable.ofObject<BleNoDisturbSettings>(data, LENGTH_BEFORE_DATA)
                            .let { noDisturb ->
                                BleLog.v("$TAG handleData onReadNoDisturb -> $noDisturb")
                                if (noDisturb.mEnabled != 0x1F) {
                                    BleCache.putObject(bleKey, noDisturb)
                                    notifyHandlers { it.onReadNoDisturb(noDisturb) }
                                }
                            }
                    } else if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofObject<BleNoDisturbSettings>(data, LENGTH_BEFORE_DATA)
                            .let { noDisturb ->
                                BleLog.v("$TAG handleData onNoDisturbUpdate -> $noDisturb")
                                BleCache.putObject(bleKey, noDisturb)
                                notifyHandlers { it.onNoDisturbUpdate(noDisturb) }
                            }
                    } else if (isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                        notifyHandlers { it.onCommandReply(bleKey, bleKeyFlag, status) }
                        BleLog.v("$TAG handleData onCommandReply $bleKey,$bleKeyFlag -> $status")
                    }
                }
                BleKey.ALARM -> {
                    if (isReply) {
                        if (bleKeyFlag == BleKeyFlag.READ) {
                            BleReadable.ofList<BleAlarm>(data, BleAlarm.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                                .let { alarms ->
                                    BleLog.v("$TAG handleData onReadAlarm -> $alarms")
                                    // 协议商定，查的时候只支持查所有，所以直接覆盖缓存
                                    BleCache.putList(bleKey, alarms)
                                    notifyHandlers { it.onReadAlarm(alarms) }
                                }
                        }
                    } else {
                        if (bleKeyFlag == BleKeyFlag.UPDATE) {
                            sendData(bleKey, bleKeyFlag, null, true)
                            val alarm = BleReadable.ofObject<BleAlarm>(data, LENGTH_BEFORE_DATA)
                            val alarms = BleCache.getList(bleKey, BleAlarm::class.java)
                            val index = alarms.indexOfFirst { it.mId == alarm.mId }
                            if (index > -1) {
                                alarms[index] = alarm
                            }
                            BleCache.putList(bleKey, alarms)
                            BleLog.v("$TAG handleData onAlarmUpdate -> $alarm")
                            notifyHandlers { it.onAlarmUpdate(alarm) }
                        } else if (bleKeyFlag == BleKeyFlag.DELETE) {
                            if (data.size < LENGTH_BEFORE_DATA + 1) return

                            sendData(bleKey, bleKeyFlag, null, true)
                            val id = data.getInt(LENGTH_BEFORE_DATA, 1)
                            val alarms = BleCache.getList(bleKey, BleAlarm::class.java)
                            if (id == ID_ALL) {
                                alarms.clear()
                            } else {
                                val index = alarms.indexOfFirst { it.mId == id }
                                if (index > -1) alarms.removeAt(index)
                            }
                            BleCache.putList(bleKey, alarms)
                            BleLog.v("$TAG handleData onAlarmDelete -> $id")
                            notifyHandlers { it.onAlarmDelete(id) }
                        } else if (bleKeyFlag == BleKeyFlag.CREATE) {
                            sendData(bleKey, bleKeyFlag, null, true)
                            val alarm = BleReadable.ofObject<BleAlarm>(data, LENGTH_BEFORE_DATA)
                            val alarms = BleCache.getList(bleKey, BleAlarm::class.java)
                            alarms.add(alarm)
                            BleCache.putList(bleKey, alarms)
                            BleLog.v("$TAG handleData onAlarmAdd -> $alarm")
                            notifyHandlers { it.onAlarmAdd(alarm) }
                        }
                    }
                }
                BleKey.COACHING -> {
                    if (isReply) {
                        if (bleKeyFlag == BleKeyFlag.READ) {
                            val coachingIds = BleReadable.ofObject<BleCoachingIds>(data, LENGTH_BEFORE_DATA)
                            BleLog.v("$TAG handleData onReadCoachingIds -> $coachingIds")
                            BleCache.putObject(bleKey, coachingIds, bleKeyFlag)
                            notifyHandlers { it.onReadCoachingIds(coachingIds) }
                        } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
                            val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                            notifyHandlers { it.onCommandReply(bleKey, bleKeyFlag, status) }
                            BleLog.v("$TAG handleData onCommandReply $bleKey,$bleKeyFlag -> $status")
                        }
                    }
                }
                BleKey.FIND_PHONE -> {
                    if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return

                        val start = data[LENGTH_BEFORE_DATA] == BLE_OK
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleLog.v("$TAG handleData onFindPhone -> ${if (start) "started" else "stopped"}")
                        notifyHandlers { it.onFindPhone(start) }
                    }
                }
                BleKey.SLEEP_QUALITY -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        if (data.size < LENGTH_BEFORE_DATA + BleSleepQuality.ITEM_LENGTH) return

                        val sleepQuality = BleReadable.ofObject<BleSleepQuality>(data, LENGTH_BEFORE_DATA)
                        BleLog.v("$TAG handleData onReadSleepQuality -> $sleepQuality")
                        BleCache.putObject(bleKey, sleepQuality, bleKeyFlag)
                        notifyHandlers { it.onReadSleepQuality(sleepQuality) }
                    }
                }
                BleKey.REALTIME_LOG -> {
                    if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofObject<BleRealtimeLog>(data, LENGTH_BEFORE_DATA)
                            .let { realtimeLog ->
                                BleLog.v("$TAG handleData onReceiveRealtimeLog -> $realtimeLog")
                                notifyHandlers { it.onReceiveRealtimeLog(realtimeLog) }
                            }
                    }
                }
                BleKey.AGPS_PREREQUISITE -> {
                    if (!isReply && bleKeyFlag == BleKeyFlag.READ) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleLog.v("$TAG handleData onRequestAgpsPrerequisite")
                        notifyHandlers { it.onRequestAgpsPrerequisite() }
                    }
                }

                BleKey.GSENSOR_RAW -> {
                    if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofList<BleGSensorRaw>(data, BleGSensorRaw.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { raws ->
                                BleLog.v("$TAG handleData onReceiveGSensorRaw -> $raws")
                                notifyHandlers { it.onReceiveGSensorRaw(raws) }
                            }
                    }
                }
                BleKey.HR_RAW -> {
                    if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofList<BleHRRaw>(data, BleHRRaw.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { hrRaw ->
                                BleLog.v("$TAG handleData onReceiveHRRaw -> $hrRaw")
                                notifyHandlers { it.onReceiveHRRaw(hrRaw) }
                            }
                    }
                }
                BleKey.MOTION_DETECT -> {
                    if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofList<BleGSensorMotion>(data, BleGSensorMotion.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { motions ->
                                BleLog.v("$TAG handleData onReceiveGSensorMotion -> $motions")
                                notifyHandlers { it.onReceiveGSensorMotion(motions) }
                            }
                    }
                }
                BleKey.LOCATION_GGA -> {
                    if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofObject<BleLocationGga>(data, LENGTH_BEFORE_DATA)
                            .let { locationGga ->
                                BleLog.v("$TAG handleData onReceiveLocationGga -> $locationGga")
                                notifyHandlers { it.onReceiveLocationGga(locationGga) }
                            }
                    }
                }
                BleKey.LOCATION_GSV -> {
                    if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofList<BleLocationGsv>(data, BleLocationGsv.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { gsv ->
                                BleLog.v("$TAG handleData onReceiveLocationGsv -> $gsv")
                                notifyHandlers { it.onReceiveLocationGsv(gsv) }
                            }
                    }
                }
                BleKey.LANGUAGE -> {
                    //设备语言设置开启跟随手机设置后会向App发送READ或DELETE
                    if (!isReply && (bleKeyFlag == BleKeyFlag.READ || bleKeyFlag == BleKeyFlag.DELETE)) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleLog.v("$TAG handleData onFollowSystemLanguage -> true")
                        notifyHandlers { it.onFollowSystemLanguage(true) }
                    }
                }
                BleKey.TEMPERATURE_UNIT ->{
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return

                        val value = data[LENGTH_BEFORE_DATA].toInt()
                        BleLog.v("$TAG handleData onReadTemperatureUnit -> $value")
                        BleCache.putInt(bleKey, value)
                        notifyHandlers { it.onReadTemperatureUnit(value) }
                    }
                }
                BleKey.DATE_FORMAT ->{
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return

                        val value = data[LENGTH_BEFORE_DATA].toInt()
                        BleLog.v("$TAG handleData onReadDateFormat -> $value")
                        BleCache.putInt(bleKey, value)
                        notifyHandlers { it.onReadDateFormat(value) }
                    }
                }
                BleKey.WATCH_FACE_SWITCH ->{
                    if (isReply) {
                        if (bleKeyFlag == BleKeyFlag.READ) {
                            if (data.size < LENGTH_BEFORE_DATA + 1) return

                            val value = data[LENGTH_BEFORE_DATA].toInt()
                            BleLog.v("$TAG handleData onReadWatchFaceSwitch -> $value")
                            BleCache.putInt(bleKey, value)
                            notifyHandlers { it.onReadWatchFaceSwitch(value) }
                        } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
                            val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                            notifyHandlers { it.onUpdateWatchFaceSwitch(status) }
                            BleLog.v("$TAG handleData onUpdateWatchFaceSwitch -> $status")
                        }
                    }
                }
                BleKey.DRINK_WATER -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        BleReadable.ofObject<BleDrinkWaterSettings>(data, LENGTH_BEFORE_DATA)
                            .let { drinkWater ->
                                BleLog.v("$TAG handleData onReadDrinkWater -> $drinkWater")
                                notifyHandlers { it.onReadDrinkWater(drinkWater) }
                            }
                    }
                }
                BleKey.SHUTDOWN -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                        notifyHandlers { it.onCommandReply(bleKey, bleKeyFlag, status) }
                        BleLog.v("$TAG handleData onCommandReply $bleKey,$bleKeyFlag -> $status")
                    }
                }
                BleKey.VIBRATION -> {
                    if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        if (data.size < LENGTH_BEFORE_DATA + 1) return
                        val value = data[LENGTH_BEFORE_DATA].toInt()
                        BleLog.v("$TAG handleData onVibrationUpdate -> $value")
                        BleCache.putInt(bleKey, value)
                        notifyHandlers { it.onVibrationUpdate(value) }
                    }
                }

                // BleCommand.CONNECT
                BleKey.IDENTITY -> {
                    if (data.size < LENGTH_BEFORE_DATA + 1) return

                    val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                    if (bleKeyFlag == BleKeyFlag.CREATE) {
                        if (!status) {
                            BleLog.v("$TAG handleData onIdentityCreate -> false")
                            notifyHandlers { it.onIdentityCreate(false) }
                        }
                    } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        if (status) {
                            BleCache.mDeviceInfo = BleReadable.ofObject(data, LENGTH_BEFORE_DATA + 1)
                            BleLog.v("$TAG handleData onIdentityCreate -> true, ${BleCache.mDeviceInfo}")
                            BleCache.putObject(bleKey, BleCache.mDeviceInfo)
                            notifyHandlersThen({ it.onIdentityCreate(true, BleCache.mDeviceInfo) }) {
                                login(BleCache.mDeviceInfo!!.mId)
                            }
                        } else {
                            BleLog.v("$TAG handleData onIdentityCreate -> false")
                            notifyHandlers { it.onIdentityCreate(false) }
                        }
                    } else if (bleKeyFlag == BleKeyFlag.DELETE) {
                        BleLog.v("$TAG handleData onIdentityDelete -> status=$status, isReply=$isReply")
                        if (isReply) {
                            if (status) {
                                unbind()
                            }
                            notifyHandlers { it.onIdentityDelete(status) }
                        } else {
                            sendData(bleKey, bleKeyFlag, null, true)
                            notifyHandlers { it.onIdentityDeleteByDevice(isReply) }
                        }
                    } else if (bleKeyFlag == BleKeyFlag.READ) {
                        if (data.size < LENGTH_BEFORE_DATA + 17) return // 这里的17只是大概防呆一下

                        val deviceInfo: BleDeviceInfo = BleReadable.ofObject(data, LENGTH_BEFORE_DATA + 1)
                        BleLog.v("$TAG handleData onReadDeviceInfo -> $status, $deviceInfo")
                        if (status) {
                            BleCache.mDeviceInfo = deviceInfo
                            BleCache.putObject(bleKey, deviceInfo)
                            notifyHandlers { it.onReadDeviceInfo(deviceInfo) }
                        }
                    }
                }
                BleKey.SESSION -> {
                    if (data.size < LENGTH_BEFORE_DATA + 1) return

                    val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                    if (status) {
                        BleLog.v("$TAG handleData onSessionStateChange -> true")
                        notifyHandlers { it.onSessionStateChange(true) }
                    }
                }

                // BleCommand.PUSH
                BleKey.MUSIC_CONTROL -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.READ) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return

                        mMusicSubscriptions.clear()
                        var index = 0
                        val bytes = data.copyOfRange(LENGTH_BEFORE_DATA, data.size)
                        while (index < bytes.size - 1) {
                            val entity = MusicEntity.of(bytes[index])
                            val attrCount = bytes[index + 1].toInt() and 0xff
                            val attrs = bytes.copyOfRange(index + 2, index + 2 + attrCount).map {
                                MusicAttr.of(entity, it)
                            }
                            mMusicSubscriptions[entity] = attrs
                            index += 2 + attrCount
                        }
                        BleLog.v("$TAG handleData mMusicSubscriptions -> $mMusicSubscriptions")
                    }
                    if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return

                        sendData(bleKey, bleKeyFlag, null, true)
                        val musicCommand = MusicCommand.of(data[LENGTH_BEFORE_DATA])
                        BleLog.v("$TAG handleData onReceiveMusicCommand -> $musicCommand")
                        notifyHandlers { it.onReceiveMusicCommand(musicCommand) }
                    }
                }

                // BleCommand.DATA
                BleKey.ACTIVITY -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleActivity>(data, BleActivity.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { activities ->
                                BleLog.v("$TAG handleData onReadActivity -> $activities")
                                dataCount = activities.size
                                if (!mSupportFilterEmpty || activities.isNotEmpty()) {
                                    notifyHandlers { it.onReadActivity(activities) }
                                }
                            }
                    }
                }
                BleKey.HEART_RATE -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleHeartRate>(data, BleHeartRate.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { heartRates ->
                                BleLog.v("$TAG handleData onReadHeartRate -> $heartRates")
                                dataCount = heartRates.size
                                if (!mSupportFilterEmpty || heartRates.isNotEmpty()) {
                                    notifyHandlers { it.onReadHeartRate(heartRates) }
                                }
                            }
                    }
                }
                BleKey.BLOOD_PRESSURE -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleBloodPressure>(data, BleBloodPressure.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { bloodPressures ->
                                BleLog.v("$TAG handleData onReadBloodPressure -> $bloodPressures")
                                dataCount = bloodPressures.size
                                if (!mSupportFilterEmpty || bloodPressures.isNotEmpty()) {
                                    notifyHandlers { it.onReadBloodPressure(bloodPressures) }
                                }
                            }
                    }
                }
                BleKey.SLEEP -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleSleep>(data, BleSleep.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { sleeps ->
                                BleLog.v("$TAG handleData onReadSleep -> $sleeps")
                                dataCount = sleeps.size
                                if (!mSupportFilterEmpty || sleeps.isNotEmpty()) {
                                    notifyHandlers { it.onReadSleep(sleeps) }
                                }
                            }
                    }
                }
                BleKey.WORKOUT -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleWorkout>(data, BleWorkout.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { workouts ->
                                BleLog.v("$TAG handleData onReadWorkout -> $workouts")
                                dataCount = workouts.size
                                if (!mSupportFilterEmpty || workouts.isNotEmpty()) {
                                    notifyHandlers { it.onReadWorkout(workouts) }
                                }
                            }
                    }
                }
                BleKey.LOCATION -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleLocation>(data, BleLocation.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { locations ->
                                BleLog.v("$TAG handleData onReadLocation -> $locations")
                                dataCount = locations.size
                                if (!mSupportFilterEmpty || locations.isNotEmpty()) {
                                    notifyHandlers { it.onReadLocation(locations) }
                                }
                            }
                    }
                }
                BleKey.TEMPERATURE -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleTemperature>(data, BleTemperature.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { temperatures ->
                                BleLog.v("$TAG handleData onReadTemperature -> $temperatures")
                                dataCount = temperatures.size
                                if (!mSupportFilterEmpty || temperatures.isNotEmpty()) {
                                    notifyHandlers { it.onReadTemperature(temperatures) }
                                }
                            }
                    }
                }
                BleKey.BLOOD_OXYGEN -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleBloodOxygen>(data, BleBloodOxygen.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { bloodOxygen ->
                                BleLog.v("$TAG handleData onReadBloodOxygen -> $bloodOxygen")
                                dataCount = bloodOxygen.size
                                if (!mSupportFilterEmpty || bloodOxygen.isNotEmpty()) {
                                    notifyHandlers { it.onReadBloodOxygen(bloodOxygen) }
                                }
                            }
                    }
                }
                BleKey.HRV -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleHrv>(data, BleHrv.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { hrv ->
                                BleLog.v("$TAG handleData onReadBleHrv -> $hrv")
                                dataCount = hrv.size
                                if (!mSupportFilterEmpty || hrv.isNotEmpty()) {
                                    notifyHandlers { it.onReadBleHrv(hrv) }
                                }
                            }
                    }
                }
                BleKey.LOG -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleLogText>(data, BleLogText.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { logs ->
                                BleLog.v("$TAG handleData onReadBleLogText -> $logs")
                                dataCount = logs.size
                                if (logs.isNotEmpty()) {
                                    notifyHandlers { it.onReadBleLogText(logs) }
                                }
                            }
                    }
                }
                BleKey.SLEEP_RAW_DATA, BleKey.RAW_SLEEP -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return

                        val copyOfRange = data.copyOfRange(LENGTH_BEFORE_DATA, data.size)
                        notifyHandlers { it.onReadSleepRaw(copyOfRange) }
                    }
                }
                BleKey.PRESSURE -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BlePressure>(data, BlePressure.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { pressures ->
                                BleLog.v("$TAG handleData onReadPressure -> $pressures")
                                dataCount = pressures.size
                                if (!mSupportFilterEmpty || pressures.isNotEmpty()) {
                                    notifyHandlers { it.onReadPressure(pressures) }
                                }
                            }
                    }
                }
                BleKey.WORKOUT2 -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleWorkout2>(data, BleWorkout2.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { workouts ->
                                BleLog.v("$TAG handleData onReadWorkout2 -> $workouts")
                                dataCount = workouts.size
                                if (!mSupportFilterEmpty || workouts.isNotEmpty()) {
                                    notifyHandlers { it.onReadWorkout2(workouts) }
                                }
                            }
                    }
                }
                BleKey.MATCH_RECORD -> {
                    if (bleKeyFlag == BleKeyFlag.READ && isReply) {
                        BleReadable.ofList<BleMatchRecord>(data, BleMatchRecord.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                            .let { matchRecords ->
                                BleLog.v("$TAG handleData onReadMatchRecord -> $matchRecords")
                                dataCount = matchRecords.size
                                if (!mSupportFilterEmpty || matchRecords.isNotEmpty()) {
                                    notifyHandlers { it.onReadMatchRecord(matchRecords) }
                                }
                            }
                    }
                }

                BleKey.APP_SPORT_DATA -> {
                    if (isReply) {
                        if (data.size < LENGTH_BEFORE_DATA + 2) return

                        val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                        notifyHandlers { it.onAppSportDataResponse(status) }
                    }
                }
                BleKey.REAL_TIME_HEART_RATE -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE && !isReply) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofObject<BleHeartRate>(data, LENGTH_BEFORE_DATA)
                            .let { heartRate ->
                                BleLog.v("$TAG handleData onUpdateHeartRate -> $heartRate")
                                notifyHandlers { it.onUpdateHeartRate(heartRate) }
                            }
                    }
                }
                BleKey.WATCHFACE_ID -> {
                    if (isReply) {
                        if (bleKeyFlag == BleKeyFlag.READ) {
                            BleReadable.ofObject<BleWatchFaceId>(data, LENGTH_BEFORE_DATA)
                                .let { watchFaceId ->
                                    BleLog.v("$TAG handleData onReadWatchFaceId -> $watchFaceId")
                                    notifyHandlers { it.onReadWatchFaceId(watchFaceId) }
                                }
                        } else if (bleKeyFlag == BleKeyFlag.UPDATE) {
                            notifyHandlers { it.onWatchFaceIdUpdate(true) }
                            BleLog.v("$TAG handleData onWatchFaceIdUpdate -> true")
                        }
                    }
                }
                BleKey.REAL_TIME_TEMPERATURE -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE && !isReply) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofObject<BleTemperature>(data, LENGTH_BEFORE_DATA)
                            .let { temperature ->
                                BleLog.v("$TAG handleData onUpdateTemperature -> $temperature")
                                notifyHandlers { it.onUpdateTemperature(temperature) }
                            }
                    }
                }
                BleKey.REAL_TIME_BLOOD_PRESSURE -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE && !isReply) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofObject<BleBloodPressure>(data, LENGTH_BEFORE_DATA)
                            .let { bloodPressure ->
                                BleLog.v("$TAG handleData onUpdateBloodPressure -> $bloodPressure")
                                notifyHandlers { it.onUpdateBloodPressure(bloodPressure) }
                            }
                    }
                }

                BleKey.TEMPERATURE_VALUE -> {
                    if (isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                        notifyHandlers { it.onCommandReply(bleKey, bleKeyFlag, status) }
                        BleLog.v("$TAG handleData onCommandReply $bleKey,$bleKeyFlag -> $status")
                    }
                }

                BleKey.REALTIME_MEASUREMENT -> {
                    if (bleKeyFlag == BleKeyFlag.UPDATE) {
                        if (!isReply) {
                            sendData(bleKey, bleKeyFlag, null, true)
                        }
                        BleReadable.ofObject<BleRealTimeMeasurement>(data, LENGTH_BEFORE_DATA)
                            .let { realTimeMeasurement ->
                                BleLog.v("$TAG handleData onRealTimeMeasurement -> $realTimeMeasurement")
                                notifyHandlers { it.onRealTimeMeasurement(realTimeMeasurement) }
                            }
                    }
                }

                // BleCommand.CONTROL
                BleKey.CAMERA -> {
                    if (isReply) {
                        if (data.size < LENGTH_BEFORE_DATA + 2) return

                        val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                        val cameraState = data[LENGTH_BEFORE_DATA + 1].toInt()
                        BleLog.v(
                            "$TAG handleData onCameraResponse -> status=$status" +
                                ", cameraState=${CameraState.getState(cameraState)}"
                        )
                        notifyHandlers { it.onCameraResponse(status, cameraState) }
                    } else {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return

                        sendData(bleKey, bleKeyFlag, null, true)
                        data[LENGTH_BEFORE_DATA].toInt().let { cameraState ->
                            BleLog.v("$TAG handleData onCameraStateChange -> ${CameraState.getState(cameraState)}")
                            notifyHandlers { it.onCameraStateChange(cameraState) }
                        }
                    }
                }
                BleKey.REQUEST_LOCATION -> {
                    if (!isReply) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return

                        sendData(bleKey, bleKeyFlag, null, true)
                        data[LENGTH_BEFORE_DATA].toInt().let { workoutState ->
                            BleLog.v("$TAG handleData onRequestLocation -> ${WorkoutState.getState(workoutState)}")
                            notifyHandlers { it.onRequestLocation(workoutState) }
                        }
                    }
                }
                BleKey.INCOMING_CALL -> {
                    if (!isReply) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return
                        sendData(bleKey, bleKeyFlag, null, true)
                        data[LENGTH_BEFORE_DATA].toInt().let { status ->
                            BleLog.v("$TAG handleData onIncomingCallResponse -> status=$status")
                            notifyHandlers { it.onIncomingCallStatus(status) }
                        }
                    }
                }
                BleKey.APP_SPORT_STATE -> {
                    if (!isReply) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofObject<BleAppSportState>(data, LENGTH_BEFORE_DATA)
                            .let { appSportState ->
                                BleLog.v("$TAG handleData onUpdateAppSportState -> $appSportState")
                                notifyHandlers { it.onUpdateAppSportState(appSportState) }
                            }
                    }
                }
                BleKey.CLASSIC_BLUETOOTH_STATE -> {
                    if (!isReply) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return
                        sendData(bleKey, bleKeyFlag, null, true)
                        data[LENGTH_BEFORE_DATA].toInt().let { state ->
                            BleLog.v("$TAG handleData onClassicBluetoothStateChange -> ${ClassicBluetoothState.getState(state)}")
                            notifyHandlers { it.onClassicBluetoothStateChange(state) }
                        }
                    }
                }

                // BleCommand.IO
                BleKey.WATCH_FACE, BleKey.AGPS_FILE, BleKey.FONT_FILE, BleKey.CONTACT, BleKey.UI_FILE,
                BleKey.LANGUAGE_FILE, BleKey.BRAND_INFO_FILE -> {
                    if (isReply) {
                        if (bleKeyFlag == BleKeyFlag.UPDATE) {
                            // 出错时可能只返回一个字节
                            if (data.size < LENGTH_BEFORE_DATA + 1) return

                            BleReadable.ofObject<BleStreamProgress>(data, LENGTH_BEFORE_DATA)
                                .let { streamProgress ->
                                    BleLog.v("$TAG onStreamProgress -> $streamProgress")
                                    if (streamProgress.mStatus == BLE_OK.toInt()) {
                                        if (streamProgress.mTotal == streamProgress.mCompleted) {
                                            mBleStream = null
                                        } else {
                                            mBleStream?.getPacket(streamProgress.mCompleted, BleCache.mIOBufferSize)
                                                ?.let { streamPacket ->
                                                    sendObject(
                                                        mBleStream!!.mBleKey,
                                                        BleKeyFlag.UPDATE,
                                                        streamPacket
                                                    )
                                                }
                                        }
                                    } else {
                                        mBleStream = null
                                    }
                                    notifyHandlers {
                                        it.onStreamProgress(
                                            streamProgress.mStatus == BLE_OK.toInt(), streamProgress.mErrorCode,
                                            streamProgress.mTotal, streamProgress.mCompleted
                                        )
                                    }
                                }
                        } else if (bleKeyFlag == BleKeyFlag.DELETE) {
                            val status = data[LENGTH_BEFORE_DATA] == BLE_OK
                            notifyHandlers { it.onCommandReply(bleKey, bleKeyFlag, status) }
                            BleLog.v("$TAG handleData onCommandReply $bleKey,$bleKeyFlag -> $status")
                        }
                    } else {
                        if (bleKey == BleKey.AGPS_FILE && bleKeyFlag == BleKeyFlag.UPDATE) {
                            sendData(bleKey, bleKeyFlag, null, true)
                            BleLog.v("$TAG onDeviceRequestAGpsFile -> ${BleCache.mAGpsFileUrl}")
                            notifyHandlers { it.onDeviceRequestAGpsFile(BleCache.mAGpsFileUrl) }
                        }
                    }
                }
                BleKey.DEVICE_FILE -> {
                    if (isReply && (bleKeyFlag == BleKeyFlag.READ || bleKeyFlag == BleKeyFlag.READ_CONTINUE)) {
                        BleReadable.ofObject<BleDeviceFile>(data, LENGTH_BEFORE_DATA)
                            .let { deviceFile ->
                                BleLog.v("$TAG handleData onReadDeviceFile -> $deviceFile")
                                BleCache.putObject(bleKey, deviceFile)
                                notifyHandlers { it.onReadDeviceFile(deviceFile) }
                            }
                    } else if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofObject<BleDeviceFile>(data, LENGTH_BEFORE_DATA)
                            .let { deviceFile ->
                                BleLog.v("$TAG handleData onDeviceFileUpdate -> $deviceFile")
                                BleCache.putObject(bleKey, deviceFile)
                                notifyHandlers { it.onDeviceFileUpdate(deviceFile) }
                            }
                    }
                }
                BleKey.WEATHER_REALTIME -> {
                    //设备语言设置开启跟随手机设置后会向App发送READ或DELETE
                    if (!isReply && bleKeyFlag == BleKeyFlag.READ) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleLog.v("$TAG handleData onReadWeatherRealTime -> true")
                        notifyHandlers { it.onReadWeatherRealTime(true) }
                    }
                }
                BleKey.HID -> {
                    if (bleKeyFlag == BleKeyFlag.READ) {
                        if(!isReply){
                            sendData(bleKey, bleKeyFlag, null, true)
                        }
                        if (data.size < LENGTH_BEFORE_DATA + 1) return
                        data[LENGTH_BEFORE_DATA].toInt().let { state ->
                            mHidState = state
                            BleLog.v("$TAG handleData onHIDState -> ${HIDState.getState(state)}")
                            notifyHandlers { it.onHIDState(state) }
                        }

                    } else if (!isReply && bleKeyFlag == BleKeyFlag.UPDATE) {
                        sendData(bleKey, bleKeyFlag, null, true)
                        if (data.size < LENGTH_BEFORE_DATA + 1) return
                        data[LENGTH_BEFORE_DATA].toInt().let { value ->
                            BleLog.v("$TAG handleData onHIDValueChange -> ${HIDValue.getValue(value)}")
                            notifyHandlers { it.onHIDValueChange(value) }
                        }
                    }
                }
                BleKey.WORLD_CLOCK -> {
                    if (isReply) {
                        if (bleKeyFlag == BleKeyFlag.READ) {
                            BleReadable.ofList<BleWorldClock>(data, BleWorldClock.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                                .let { clocks ->
                                    BleLog.v("$TAG handleData onReadWorldClock -> $clocks")
                                    // 协议商定，查的时候只支持查所有，所以直接覆盖缓存
                                    BleCache.putList(bleKey, clocks)
                                    notifyHandlers { it.onReadWorldClock(clocks) }
                                }
                        }
                    } else {
                        if (bleKeyFlag == BleKeyFlag.DELETE) {
                            if (data.size < LENGTH_BEFORE_DATA + 1) return

                            sendData(bleKey, bleKeyFlag, null, true)
                            val id = data.getInt(LENGTH_BEFORE_DATA, 1)
                            val clocks = BleCache.getList(bleKey, BleWorldClock::class.java)
                            if (id == ID_ALL) {
                                clocks.clear()
                            } else {
                                val index = clocks.indexOfFirst { it.mId == id }
                                if (index > -1) clocks.removeAt(index)
                            }
                            BleCache.putList(bleKey, clocks)
                            BleLog.v("$TAG handleData onWorldClockDelete -> $id")
                            notifyHandlers { it.onWorldClockDelete(id) }
                        }
                    }
                }
                BleKey.STOCK -> {
                    if (isReply) {
                        if (bleKeyFlag == BleKeyFlag.READ) {
                            BleReadable.ofList<BleStock>(data, BleStock.ITEM_LENGTH, LENGTH_BEFORE_DATA)
                                .let { stocks ->
                                    BleLog.v("$TAG handleData onReadStock -> $stocks")
                                    // 协议商定，查的时候只支持查所有，所以直接覆盖缓存
                                    BleCache.putList(bleKey, stocks)
                                    notifyHandlers { it.onReadStock(stocks) }
                                }
                        }
                    } else {
                        if (bleKeyFlag == BleKeyFlag.DELETE) {
                            if (data.size < LENGTH_BEFORE_DATA + 1) return

                            sendData(bleKey, bleKeyFlag, null, true)
                            val id = data.getInt(LENGTH_BEFORE_DATA, 1)
                            val stocks = BleCache.getList(bleKey, BleStock::class.java)
                            if (id == ID_ALL) {
                                stocks.clear()
                            } else {
                                val index = stocks.indexOfFirst { it.mId == id }
                                if (index > -1) stocks.removeAt(index)
                            }
                            BleCache.putList(bleKey, stocks)
                            BleLog.v("$TAG handleData onStockDelete -> $id")
                            notifyHandlers { it.onStockDelete(id)}
                        } else if (bleKeyFlag == BleKeyFlag.READ) {
                            sendData(bleKey, bleKeyFlag, null, true)
                            BleLog.v("$TAG handleData onReadStock -> true")
                            notifyHandlers { it.onReadStock(true) }
                        }
                    }
                }
                BleKey.DEVICE_SMS_QUICK_REPLY -> {
                    if (!isReply) {
                        if (data.size < LENGTH_BEFORE_DATA + 1) return
                        sendData(bleKey, bleKeyFlag, null, true)
                        BleReadable.ofObject<BleSMSQuickReply>(data, LENGTH_BEFORE_DATA)
                            .let { bleSMSQuickReply ->
                                BleLog.v("$TAG handleData onDeviceSMSQuickReply -> $bleSMSQuickReply")
                                notifyHandlers { it.onDeviceSMSQuickReply(bleSMSQuickReply) }
                            }

                    }
                }
                else -> {
                    if (!isReply) {
                        sendData(bleKey, bleKeyFlag, null, true)
                    }
                }
            }
            if (bleKey.mBleCommand == BleCommand.DATA && bleKeyFlag == BleKeyFlag.READ && isReply) {
                notifySyncState(SyncState.SYNCING, bleKey)
                if (dataCount > 0) {
                    sendData(bleKey, BleKeyFlag.DELETE)
                }
                if (dataCount <= 1) { // 该类型数据已同步完成
                    if (mDataKeys.isNotEmpty()) {
                        mDataKeys.removeAt(0)
                    }
                    if (mDataKeys.isEmpty()) { // 整个数据同步完成
                        removeSyncTimeout()
                        notifySyncState(SyncState.COMPLETED, bleKey)
                    } else { // 同步下个数据类型
                        sendData(mDataKeys[0], BleKeyFlag.READ)
                        postDelaySyncTimeout()
                    }
                } else { // 该类型数据还未同步完成，继续同步
                    if (mDataKeys.isNotEmpty()) {
                        sendData(mDataKeys[0], BleKeyFlag.READ)
                        postDelaySyncTimeout()
                    } else {
                        sendData(bleKey, BleKeyFlag.READ)
                        postDelaySyncTimeout()
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun notifyHandlers(action: (BleHandleCallback) -> Unit) {
        mHandler.post {
            mBleHandleCallbacks.forEach { action(it) }
        }
    }

    private fun notifyHandlersThen(action: (BleHandleCallback) -> Unit, then: () -> Unit) {
        mHandler.post {
            mBleHandleCallbacks.forEach { action(it) }
            then()
        }
    }

    private fun notifySyncState(syncState: Int, bleKey: BleKey) {
        BleLog.v("$TAG onSyncData -> ${SyncState.getState(syncState)}, $bleKey")
        notifyHandlers { it.onSyncData(syncState, bleKey) }
    }

    private fun postDelaySyncTimeout() {
        removeSyncTimeout()
        mHandler.postDelayed(mSyncTimeout, 8000L)
    }

    private fun removeSyncTimeout() {
        mHandler.removeCallbacks(mSyncTimeout)
    }

    /**
     * 设置是否在连接后进入OTA模式,跳过绑定
     */
    fun setOtaMode(isOtaMode: Boolean) {
        isNordicOtaMode = isOtaMode
    }

    /**
     * 检查文件传输进度，用于非[BleCommand.IO]时，比如MTK固件升级。
     */
    private fun checkStreamProgress() {
        if (isAvailable()) {
            if (mStreamProgressTotal > 0 && mStreamProgressCompleted > 0) {
                BleLog.v(
                    "$TAG onStreamProgress -> mStreamProgressTotal=$mStreamProgressTotal, " +
                        "mStreamProgressCompleted=$mStreamProgressCompleted"
                )
                notifyHandlersThen({
                    it.onStreamProgress(true, 0, mStreamProgressTotal, mStreamProgressCompleted)
                }) {
                    if (mStreamProgressTotal == mStreamProgressCompleted) {
                        mStreamProgressTotal = -1
                        mStreamProgressCompleted = -1
                    }
                }
            }
        } else {
            if (mStreamProgressTotal > 0 && mStreamProgressCompleted >= 0
                && mStreamProgressCompleted < mStreamProgressTotal
            ) {
                notifyHandlersThen({
                    it.onStreamProgress(false, -1, mStreamProgressTotal, mStreamProgressCompleted)
                }) {
                    if (mStreamProgressTotal == mStreamProgressCompleted) {
                        mStreamProgressTotal = -1
                        mStreamProgressCompleted = -1
                    }
                }
            }
        }
    }

    class Builder(private val context: Context) {
        private var supportRealtekDfu = false // 是否支持Realtek设备Dfu。
        private var supportMtkOta = false // 是否支持MTK设备Ota。
        private var supportLauncher = true // 是否支持初始化即自动监测连接
        private var supportFilterEmpty = true // 是否过滤空数据的返回

        /**
         * 设置是否支持Realtek设备Dfu。
         */
        fun supportRealtekDfu(supported: Boolean): Builder {
            supportRealtekDfu = supported
            return this
        }

        /**
         * 设置是否支持MTK设备Ota。
         */
        fun supportMtkOta(supported: Boolean): Builder {
            supportMtkOta = supported
            return this
        }

        /**
         * 是否支持初始化后自动检测连接
         */
        fun supportLauncher(supported: Boolean): Builder {
            supportLauncher = supported
            return this
        }

        /**
         * 是否过滤空数据的返回
         */
        fun supportFilterEmpty(supported: Boolean): Builder {
            supportFilterEmpty = supported
            return this
        }

        fun build() = init(
            context,
            supportRealtekDfu = supportRealtekDfu,
            supportMtkOta = supportMtkOta,
            supportLauncher = supportLauncher,
            supportFilterEmpty = supportFilterEmpty
        )
    }
}