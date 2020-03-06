//
//  DeviceCollectionViewCell.swift
//  Devices View
//
//  Created by Steven Hertz on 3/5/20.
//  Copyright © 2020 DevelopItSolutions. All rights reserved.
//

import UIKit

class DeviceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var appIconView: UIImageView!
    
    @IBOutlet weak var deviceName: UILabel!
    
    @IBOutlet weak var studentPhotoView: UIImageView!
    
    //    @IBOutlet weak var studentImageView: UIImageView!
//
//    @IBOutlet weak var studentNameLabel: UILabel!
//
//    @IBOutlet weak var deviceName: UILabel!
//
//    @IBOutlet weak var checkmarkImageView: UIImageView! {
//        didSet {
//            checkmarkImageView.alpha = 0.0
//            let tintableImage = checkmarkImageView.image?.withRenderingMode(.alwaysTemplate)
//            print("set it tintable")
//            checkmarkImageView.image = tintableImage
//            // checkmarkImageView.tintColor = UIColor(named: "tintcontrast")
//
//            //  checkImage.image = UIImage(systemName: <#T##String#>, withConfiguration: UIImage.Configuration?)  //UIImage(imageLiteralResourceName: "myImageName").withRenderingMode(.alwaysTemplate)
//            // checkImage.tintColor = UIColor.red
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //        let redView = UIView(frame: bounds)
        //        redView.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        //        backgroundView = redView
        //
        let blueView = UIView(frame: bounds)
        blueView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        selectedBackgroundView = blueView
        
        
//        studentImageView.layer.cornerRadius = 60
//        studentImageView.layer.masksToBounds = true
    }
    
    
//    func showIcon() {
//        checkmarkImageView.alpha = 1.0
//        studentImageView.alpha = 0.5
//    }
//    
//    func hideIcon() {
//        checkmarkImageView.alpha = 0.0
//        studentImageView.alpha = 1.0
//    }
    
    func setup(device: Device) {
        print("start setup")
       deviceName.text =  device.name
        print(device.appIcon)
        print(device.studentImage)
        studentPhotoView.image = device.appIcon
        appIconView.image = device.studentImage
        print("end setup")
        
     }

    
}
