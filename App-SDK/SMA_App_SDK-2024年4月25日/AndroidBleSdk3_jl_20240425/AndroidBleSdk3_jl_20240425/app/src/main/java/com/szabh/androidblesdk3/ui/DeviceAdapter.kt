package com.szabh.androidblesdk3.ui

import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.ImageView
import android.widget.TextView
import com.bestmafen.baseble.scanner.BleDevice
import com.szabh.androidblesdk3.R

class DeviceAdapter : BaseAdapter() {
    private val mDevices = mutableListOf<BleDevice>()

    override fun getView(position: Int, v: View?, parent: ViewGroup): View {
        return v?.also {
            setUpItem(position, v.tag as ViewHolder)
        } ?: View.inflate(parent.context, R.layout.item_device, null).also { view ->
            setUpItem(position, ViewHolder(view))
        }
    }

    override fun getItem(position: Int): Any = mDevices[position]

    override fun getItemId(position: Int): Long = position.toLong()

    override fun getCount(): Int = mDevices.size

    private fun setUpItem(position: Int, viewHolder: ViewHolder) {
        mDevices[position].let { bleDevice ->
            viewHolder.apply {
                mTvName.text = bleDevice.mBluetoothDevice.name
                mTvAddress.text = bleDevice.mBluetoothDevice.address
                mTvRssi.text = bleDevice.mRssi.toString()
                mIvRssi.setImageLevel(-bleDevice.mRssi)
            }
        }
    }

    fun add(bleDevice: BleDevice) {
        if (mDevices.contains(bleDevice)) return

        mDevices.add(bleDevice)
        mDevices.sortBy { -it.mRssi }
        notifyDataSetChanged()
    }

    fun clear() {
        mDevices.clear()
        notifyDataSetChanged()
    }
}

class ViewHolder(view: View) {
    val mTvName: TextView = view.findViewById(R.id.tv_name)
    val mTvAddress: TextView = view.findViewById(R.id.tv_address)
    val mTvRssi: TextView = view.findViewById(R.id.tv_rssi)
    val mIvRssi: ImageView = view.findViewById(R.id.iv_rssi)

    init {
        view.tag = this
    }
}