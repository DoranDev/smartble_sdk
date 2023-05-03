////
////  ABHSelectWatchFaceId.swift
////  SmartV3
////
////  Created by SMA-IOS on 2022/5/19.
////  Copyright © 2022 KingHuang. All rights reserved.
////
//
//import Foundation
//import UIKit
//import SnapKit
///**
// 选择替换表盘位置,索引位置number是在sendStream时的参数
// */
//
//public typealias ABHCollectionViewBlock = (Int) -> Void
//let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//
//class ABHSelectWatchFaceId: UIView{
//    
//    var collectionView :UICollectionView?
//    var collectionCellNumber = 0
//    var watchFaceId : BleWatchFaceId?
//    var selectItem : ABHCollectionViewBlock? = nil
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//       
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func makeView(){
//         
//        collectionCellNumber = watchFaceId?.mIdList.count ?? 0 < 1 ? 4 : watchFaceId!.mIdList.count
//        let collectionLayout = UICollectionViewFlowLayout.init()
//        collectionLayout.itemSize = CGSize(width: 180, height: 260)
//        collectionLayout.scrollDirection = .horizontal
//        let rect = CGRect(x: 0, y: 0, width: MaxWidth, height: 300 )
//        collectionView = UICollectionView(frame: rect, collectionViewLayout: collectionLayout)
//        collectionView!.backgroundColor = .white
//        collectionView!.dataSource = self
//        collectionView!.delegate = self
//        collectionView!.isPagingEnabled = true
//        collectionView!.showsHorizontalScrollIndicator = false
//        collectionView!.showsVerticalScrollIndicator = false
//        collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier:"mSelectWatchFaceIdCell")
//        self.addSubview(collectionView!)
//    }
//    
//    func isFileExists(_ filePath:String) ->Bool {
//        let manager = FileManager.default
//        let exist = manager.fileExists(atPath: filePath)
//        if exist == false{
//            return false
//        }else{
//            return true
//        }
//    }
//}
//
//extension ABHSelectWatchFaceId :UICollectionViewDelegate,UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return collectionCellNumber
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 180, height: 260)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: "mSelectWatchFaceIdCell", for: indexPath)
//        if cell.subviews.count>0 {
//            for item in cell.subviews{
//                item.removeFromSuperview()
//            }
//        }
//        let watchID = (watchFaceId?.mIdList[indexPath.row] ?? 0 < 100 ? 0 : watchFaceId?.mIdList[indexPath.row])!
//        let imageName = documentPath+"/WatchFaceID"+"\(indexPath.row)"
//        bleLog("mSelectWatchFaceIdCell - \(watchID) \(String(describing: watchFaceId?.mIdList[indexPath.row]))")
//        if isFileExists(imageName) && watchID >= 100{
//            let imageBk = UIImageView()
//            imageBk.image = UIImage.init(contentsOfFile: imageName)
//            cell.addSubview(imageBk)
//            imageBk.snp.makeConstraints { make in
//                make.top.equalTo(0)
//                make.left.equalTo(10)
//                make.right.equalTo(-10)
//                make.bottom.equalTo(-10)
//            }
//        }else{
//            let bkLabel = UILabel()
//            bkLabel.backgroundColor = .gray
//            cell.addSubview(bkLabel)
//            bkLabel.snp.makeConstraints { make in
//                make.top.equalTo(0)
//                make.left.equalTo(10)
//                make.right.equalTo(-10)
//                make.bottom.equalTo(-30)
//            }
//            let bottomLab = UILabel()
//            bottomLab.textColor = .gray
//            bottomLab.font = .systemFont(ofSize: 17)
//            bottomLab.textAlignment = .center
//            bottomLab.text = "not Set"
//            cell.addSubview(bottomLab)
//            bottomLab.snp.makeConstraints { make in
//                make.bottom.equalTo(0)
//                make.centerX.equalTo(bkLabel.snp_centerXWithinMargins).offset(0)
//                make.height.equalTo(30)
//            }
//        }
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        bleLog("didSelectItemAt - \(indexPath.row)")
//        if selectItem != nil {
//            selectItem!(indexPath.row)
//        }
//    }
//}
