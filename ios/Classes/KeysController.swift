//
//  KeysController.swift
//  blesdk3
//
//  Created by Best Mafen on 2019/9/25.
//  Copyright © 2019 szabh. All rights reserved.
//

import UIKit

class KeysController: UITableViewController {
    var mBleCommand: BleCommand!
    var mBleKeys: [BleKey]!
    var mKeyNames: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Keys"

        mBleKeys = mBleCommand.getBleKeys()
        // 过滤设备不支持的数据
        if mBleCommand == .DATA {
            let dataKeys = BleCache.shared.mDataKeys
            mBleKeys = mBleKeys.filter {
                dataKeys.contains($0.rawValue)
            }
        }
        mKeyNames = mBleKeys.map({ "\($0.mDisplayName)" })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let keyFlagsController = segue.destination as? KeyFlagsController {
            if let keyFlagCell = sender as? KeyCell {
                if let indexPath = tableView.indexPath(for: keyFlagCell) {
                    keyFlagsController.mBleKey = mBleKeys[indexPath.row]
                }
            }
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        mKeyNames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "KeyCell", for: indexPath) as! KeyCell
        cell.label.text = mKeyNames[indexPath.row]
        return cell
    }
}
