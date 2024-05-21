package com.szabh.androidblesdk3.activity

import android.app.ListActivity
import android.os.Bundle
import android.widget.ArrayAdapter
import com.szabh.androidblesdk3.tools.doBle
import com.szabh.androidblesdk3.tools.toast
import com.szabh.smable3.BleKey
import com.szabh.smable3.BleKeyFlag
import com.szabh.smable3.component.BleConnector
import com.szabh.smable3.component.BleHandleCallback
import com.szabh.smable3.entity.BleFactoryTest
import com.szabh.smable3.entity.FactoryTestType

class FactoryTestActivity : ListActivity() {

    private val mContext by lazy { this }

    private val mBleHandleCallback by lazy {
        object : BleHandleCallback {
            override fun onFactoryTestUpdate(factoryTest: BleFactoryTest) {
                toast(mContext, "onFactoryTestUpdate $factoryTest")
            }
        }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        BleConnector.addHandleCallback(mBleHandleCallback)
        setupList()
    }

    override fun onDestroy() {
        super.onDestroy()
        BleConnector.removeHandleCallback(mBleHandleCallback)
    }
    private fun setupList() {
        val array = FactoryTestType.values()
        listView.apply {
            adapter = ArrayAdapter(mContext, android.R.layout.simple_list_item_1, array.map {
                it.toString()
            })
            setOnItemClickListener { _, _, position, _ ->
                doBle(mContext) {
                    when (val testType = array[position]) {
                        FactoryTestType.QUIT -> BleConnector.sendObject(BleKey.FACTORY_TEST, BleKeyFlag.UPDATE, BleFactoryTest(mType = testType, mResponse = 0))
                        else -> BleConnector.sendInt8(BleKey.FACTORY_TEST, BleKeyFlag.UPDATE, testType.type)
                    }
                }
            }
        }
    }
}