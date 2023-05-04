////
////  selectOTAFileController.swift
////  blesdk3
////
////  Created by SMA on 2020/8/31.
////  Copyright © 2020 szabh. All rights reserved.
////
//
//import Foundation
//
//public typealias selectOTAFileBlock = (String) -> Void
//
//let OTAFilePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/"
//
//class selectOTAFileController: UIViewController {
//    
//    var reloadBlock :selectOTAFileBlock?
//    lazy var tableView = UITableView.init(frame: self.view.bounds, style: .grouped)
//    lazy var dataSource :[String] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = .white
//        title = "Select File"
//        let manager = FileManager.default
//        let exist = manager.fileExists(atPath: OTAFilePath)
//        let fileUrl = NSURL.fileURL(withPath: OTAFilePath)
//        if !exist { // 判断是否已存在此文件夹,若不存在则创建文件夹
//           bleLog("创建文件夹")
//            try? manager.createDirectory(at: fileUrl, withIntermediateDirectories: true, attributes: nil)
//        }
//        
//        tableView.backgroundColor = self.view.backgroundColor
//        tableView.dataSource = self
//        tableView.delegate = self
//        tableView.separatorStyle = .none
//        tableView.showsVerticalScrollIndicator = false
//        tableView.showsHorizontalScrollIndicator = false
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SelectFileCell")
//        self.view.addSubview(tableView)
//        
//        do {
//            let array = try FileManager.default.contentsOfDirectory(atPath: OTAFilePath)
//            
//            for fileName in array {
//                var isDir: ObjCBool = true
//                let fullPath = "\(OTAFilePath)\(fileName)"
//                bleLog("fullPath - \(fullPath)")
//                if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDir) {
//                    if !isDir.boolValue {
//                        dataSource.append(fileName)
//                    }
//                }
//            }
//            
//        } catch let error as NSError {
//            print("get file path error: \(error)")
//        }
//    }
//}
//extension selectOTAFileController:UITableViewDelegate,UITableViewDataSource {
//
//    // MARK: - Table view data source
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataSource.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectFileCell", for: indexPath)
//        cell.textLabel?.text = dataSource[indexPath.row]
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        if reloadBlock != nil{
//            let fileUrl = OTAFilePath+String("\(dataSource[indexPath.row])")
//            bleLog("select - \(fileUrl)")
//            reloadBlock!(fileUrl)
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//}
