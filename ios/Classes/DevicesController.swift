//
//  DeviceTableViewController.swift
//  blesdk3
//
//  Created by Best Mafen on 2019/9/11.
//  Copyright © 2019 szabh. All rights reserved.
//

import UIKit
import CoreBluetooth

class DevicesController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnScan: UIButton!

    let mBleConnector = BleConnector.shared
    let mBleScanner = BleScanner(/*[CBUUID(string: BleConnector.BLE_SERVICE)]*/)
    var mDevices = [BleDevice]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        mBleScanner.mBleScanDelegate = self
        mBleScanner.mBleScanFilter = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mBleConnector.addBleHandleDelegate(String(obj: self), self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if mBleConnector.isBound() {
            present(storyboard!.instantiateViewController(withIdentifier: "nav"), animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mBleConnector.removeBleHandleDelegate(String(obj: self))
    }

    // MARK: - Action
    @IBAction func scan(_ sender: Any) {
        mBleScanner.scan(!mBleScanner.isScanning)
    }
}

extension DevicesController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceCell
        let bleDevice = mDevices[indexPath.row]
        cell.labelName.text = bleDevice.mPeripheral.name
        cell.labelIdentifier.text = "\(bleDevice.address)"
        cell.labelRssi.text = "\(bleDevice.mRssi)"
        return cell
    }
}

extension DevicesController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mBleScanner.exit()
        mBleConnector.setTargetDevice(mDevices[indexPath.row])
        mBleConnector.connect(true)
    }
}

extension DevicesController: BleScanDelegate, BleScanFilter {

    func onBluetoothDisabled() {
        btnScan.setTitle("Please enable the Bluetooth", for: .normal)
    }

    func onBluetoothEnabled() {
        btnScan.setTitle("Scan", for: .normal)
    }

    func onScan(_ scan: Bool) {
        if scan {
            btnScan.setTitle("Scanning", for: .normal)
            mDevices.removeAll()
            tableView.reloadData()
        } else {
            btnScan.setTitle("Scan", for: .normal)
        }
    }

    func onDeviceFound(_ device: BleDevice) {
        if !mDevices.contains(device) {
            mDevices.append(device)
            let newIndexPath = IndexPath(row: mDevices.count - 1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }

    func match(_ device: BleDevice) -> Bool {
        device.mRssi > -82
    }
}

extension DevicesController: BleHandleDelegate {

    func onDeviceConnected(_ peripheral: CBPeripheral) {

    }
    
    func onDeviceConnecting(_ status: Bool) {
//        print("onDeviceConnecting - \(status)")
    }

    func onIdentityCreate(_ status: Bool) {
        if status {
            _ = mBleConnector.sendData(.PAIR, .UPDATE)
            dismiss(animated: true)
            present(storyboard!.instantiateViewController(withIdentifier: "nav"), animated: true)
        }
    }
}
