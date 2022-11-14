package com.jieli.watchtesttool.tool.upgrade;

import android.app.Application;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.content.Context;

import com.jieli.bluetooth_connect.constant.BluetoothConstant;
import com.jieli.bluetooth_connect.util.BluetoothUtil;
import com.jieli.jl_bt_ota.constant.StateCode;
import com.jieli.jl_bt_ota.impl.BluetoothOTAManager;
import com.jieli.jl_bt_ota.interfaces.IUpgradeCallback;
import com.jieli.jl_bt_ota.model.BluetoothOTAConfigure;
import com.jieli.jl_bt_ota.model.base.BaseError;
import com.jieli.watchtesttool.tool.bluetooth.BluetoothEventListener;
import com.jieli.watchtesttool.tool.bluetooth.BluetoothHelper;
import com.jieli.watchtesttool.util.AppUtil;
import com.jieli.watchtesttool.util.WatchConstant;
import id.kakzaki.smartble_sdk.BuildConfig;

import java.io.File;

/**
 * OTA实现类
 *
 * @author zqjasonZhong
 * @since 2021/3/8
 */
public class OTAManager extends BluetoothOTAManager {
    private BluetoothHelper mBluetoothHelper;

    private BluetoothDevice mTargetDevice; //目标设备

    public final static String OTA_FILE_SUFFIX = ".ufw";
    public final static String OTA_FILE_NAME = "update.ufw";
    public final static String OTA_ZIP_SUFFIX = ".zip";
    private Context mContext;

    public OTAManager(Context context) {
        super(context);
        mContext = context;
        mBluetoothHelper = BluetoothHelper.getInstance((Application) mContext.getApplicationContext());
        mBluetoothHelper.addBluetoothEventListener(mBluetoothEventListener);
        configureOTA();
    }

    @Override
    public BluetoothDevice getConnectedDevice() {
        return mTargetDevice;
    }

    @Override
    public BluetoothGatt getConnectedBluetoothGatt() {
        return mBluetoothHelper.getConnectedBluetoothGatt(mTargetDevice);
    }

    @Override
    public void connectBluetoothDevice(BluetoothDevice bluetoothDevice) {
        mBluetoothHelper.connectDevice(bluetoothDevice);
    }

    @Override
    public void disconnectBluetoothDevice(BluetoothDevice bluetoothDevice) {
        mBluetoothHelper.disconnectDevice(bluetoothDevice);
    }

    @Override
    public boolean sendDataToDevice(BluetoothDevice bluetoothDevice, byte[] bytes) {
        return mBluetoothHelper.sendDataToDevice(bluetoothDevice, bytes);
    }

    @Override
    public void release() {
        super.release();
        mBluetoothHelper.removeBluetoothEventListener(mBluetoothEventListener);
    }

    @Override
    public void startOTA(IUpgradeCallback callback) {
        setTargetDevice(getConnectedDevice());
        super.startOTA(new CustomUpgradeCallback(callback));
    }

    private void configureOTA() {
        BluetoothOTAConfigure configure = BluetoothOTAConfigure.createDefault();
        int connectWay = mBluetoothHelper.getBluetoothOp().getBluetoothOption().getPriority();
        if (mBluetoothHelper.isConnectedDevice()) {
            BluetoothDevice device = mBluetoothHelper.getConnectedBtDevice();
            connectWay = mBluetoothHelper.getBluetoothOp().isConnectedSppDevice(device) ? BluetoothConstant.PROTOCOL_TYPE_SPP : BluetoothConstant.PROTOCOL_TYPE_BLE;
        }
        configure.setPriority(connectWay)
                .setNeedChangeMtu(false)
                .setMtu(BluetoothConstant.BLE_MTU_MIN)
                .setUseAuthDevice(false)
                .setUseReconnect(false);
        String otaDir = AppUtil.createFilePath(mContext, WatchConstant.DIR_UPDATE);
        File dir = new File(otaDir);
        boolean isExistDir = dir.exists();
        if (!isExistDir) {
            isExistDir = dir.mkdir();
        }
        if (isExistDir) {
            String otaFilePath = AppUtil.obtainUpdateFilePath(otaDir, OTA_FILE_SUFFIX);
            if (null == otaFilePath) {
                otaFilePath = otaDir + "/" + OTA_FILE_NAME;
            }
            configure.setFirmwareFilePath(otaFilePath);
        }
        configure(configure);
        if(mBluetoothHelper.isConnectedDevice()){
            onBtDeviceConnection(mBluetoothHelper.getConnectedBtDevice(), StateCode.CONNECTION_OK);
            setTargetDevice(mBluetoothHelper.getConnectedBtDevice());
        }
    }

    private void setTargetDevice(BluetoothDevice device) {
        mTargetDevice = device;
        if (null != device && mBluetoothHelper.getBluetoothOp().isConnectedBLEDevice(device)) {
            int mtu = mBluetoothHelper.getBluetoothOp().getBleMtu(device);
            if (mBluetoothHelper.getBluetoothOp().getDeviceGatt(device) != null) {
                onMtuChanged(mBluetoothHelper.getBluetoothOp().getDeviceGatt(device), mtu + 3, BluetoothGatt.GATT_SUCCESS);
            }
        }
    }


    private final BluetoothEventListener mBluetoothEventListener = new BluetoothEventListener() {

        @Override
        public void onBleMtuChange(BluetoothGatt gatt, int mtu, int status) {
            onMtuChanged(gatt, mtu, status);
        }

        @Override
        public void onConnection(BluetoothDevice device, int status) {
            status = AppUtil.convertOtaConnectStatus(status);
            if (status == StateCode.CONNECTION_OK) {
                if (mTargetDevice == null || mBluetoothHelper.isUsedBtDevice(device)) {
                    setTargetDevice(device);
                }
            }
            if (BluetoothUtil.deviceEquals(device, mTargetDevice)) {
                onBtDeviceConnection(device, status);
                if (status == StateCode.CONNECTION_DISCONNECT) {
                    setTargetDevice(null);
                }
            }
        }

        @Override
        public void onReceiveData(BluetoothDevice device, byte[] data) {
            onReceiveDeviceData(device, data);
        }
    };

    private final class CustomUpgradeCallback implements IUpgradeCallback {
        private final IUpgradeCallback mIUpgradeCallback;

        public CustomUpgradeCallback(IUpgradeCallback callback) {
            mIUpgradeCallback = callback;
        }

        @Override
        public void onStartOTA() {
            if (mIUpgradeCallback != null) mIUpgradeCallback.onStartOTA();
        }

        @Override
        public void onNeedReconnect(String s, boolean var2) {
            if (mIUpgradeCallback != null) mIUpgradeCallback.onNeedReconnect(s, var2);
        }

        @Override
        public void onProgress(int i, float v) {
            if (mIUpgradeCallback != null) mIUpgradeCallback.onProgress(i, v);
        }

        @Override
        public void onStopOTA() {
            if (mIUpgradeCallback != null) mIUpgradeCallback.onStopOTA();
            String otaFilePath = OTAManager.this.getBluetoothOption().getFirmwareFilePath();
            if (null != otaFilePath) {
//                FileUtil.deleteFile(new File(otaFilePath));
            }
        }

        @Override
        public void onCancelOTA() {
            if (mIUpgradeCallback != null) mIUpgradeCallback.onCancelOTA();
        }

        @Override
        public void onError(BaseError baseError) {
            if (mIUpgradeCallback != null) mIUpgradeCallback.onError(baseError);
        }
    }
}
