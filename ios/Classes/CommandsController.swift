////
////  CommandsControllerTableViewController.swift
////  blesdk3
////
////  Created by Best Mafen on 2019/9/24.
////  Copyright © 2019 szabh. All rights reserved.
////
//
//import UIKit
//import CoreBluetooth
//
//class CommandsController: UITableViewController {
//    var mBleCommands: [BleCommand]!
//    var mCommandNames: [String]!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        mBleCommands = BleCommand.allCases
//        mCommandNames = mBleCommands.map({ $0.mDisplayName })
//        let otaButton = UIButton(type: .custom)
//        otaButton.titleLabel?.font = .systemFont(ofSize: 13)
//        otaButton.backgroundColor = .clear
//        otaButton.setTitle("Firmware Update", for: .normal)
//        otaButton.setTitleColor(.black, for: .normal)
//        otaButton.frame = CGRect(x: self.view.frame.size.width - 85, y: 20, width: 80, height: 30)
////        otaButton.addTarget(self, action: #selector(goToOTAController), for: .touchUpInside)
//        let rightBarItem = UIBarButtonItem(customView: otaButton)
//        self.navigationItem.rightBarButtonItem = rightBarItem
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        BleConnector.shared.addBleHandleDelegate(String(obj: self), self)
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        BleConnector.shared.removeBleHandleDelegate(String(obj: self))
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//        if let keysController = segue.destination as? KeysController {
//        if let commandCell = sender as? CommandCell {
//            if let indexPath = tableView.indexPath(for: commandCell) {
//                    keysController.mBleCommand = mBleCommands[indexPath.row]
//                }
//            }
//        }
//    }
//    
////    @objc func goToOTAController(){
////        if !BleConnector.shared.isAvailable() {
////            bleLog("device not connected")
////            return
////        }
////        let otaView = OTAController()
////        self.navigationController?.pushViewController(otaView, animated: true)
////    }
//
//    // MARK: - Table view data source
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        mBleCommands.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "CommandCell", for: indexPath) as! CommandCell
//        cell.label.text = mCommandNames[indexPath.row]
//        return cell
//    }
//}
//
//extension CommandsController: BleHandleDelegate {
//
//    func onSessionStateChange(_ status: Bool) {
//        print("onSessionStateChange \(status)")
//    }
//
//    func onNoDisturbUpdate(_ noDisturbSettings: BleNoDisturbSettings) {
//        print("onNoDisturbUpdate \(noDisturbSettings)")
//    }
//
//    func onAlarmUpdate(_ alarm: BleAlarm) {
//        print("onAlarmUpdate \(alarm)")
//    }
//
//    func onAlarmDelete(_ id: Int) {
//        print("onAlarmDelete \(id)")
//    }
//
//    func onAlarmAdd(_ alarm: BleAlarm) {
//        print("onAlarmAdd \(alarm)")
//    }
//
//    func onFindPhone(_ start: Bool) {
//        print("onFindPhone \(start ? "started" : "stopped")")
//    }
//
//    func onPhoneGPSSport(_ workoutState: Int) {
//        print("onPhoneGPSSport \(WorkoutState.getState(workoutState))")
//    }
//
//    func onDeviceRequestAGpsFile(_ url: String) {
//        print("onDeviceRequestAGpsFile \(url)")
//        // 以下是示例代码，sdk中的文件会过期，只是用于演示
//        if BleCache.shared.mAGpsType == 1 {
//            _ = BleConnector.shared.sendStream(.AGPS_FILE, forResource: "type1_epo_gr_3_1", ofType: "dat")
//        } else if BleCache.shared.mAGpsType == 2 {
//            _ = BleConnector.shared.sendStream(.AGPS_FILE, forResource: "type2_current_1d", ofType: "alp")
//        } else if BleCache.shared.mAGpsType == 6 {
//            _ = BleConnector.shared.sendStream(.AGPS_FILE, forResource: "type6_ble_epo_offline", ofType: "bin")
//        }
//        // 实际工程要从url下载aGps文件，然后发送该aGps文件
//        // let path = download(url)
//        // _ = BleConnector.shared.sendStream(.AGPS_FILE, path)
//    }
//}
