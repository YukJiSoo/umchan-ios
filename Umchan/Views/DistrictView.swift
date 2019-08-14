//
//  DistrictView.swift
//  Umchan
//
//  Created by 육지수 on 8/14/19.
//  Copyright © 2019 JSYuk. All rights reserved.
//

import UIKit

class DistrictView: UIImageView {
    
    var x: CGFloat?
    var y: CGFloat?
    
    @IBInspectable var districtColor: UIColor {
        return #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with disritct: DistrictCoordinate, _ widthRatio: CGFloat, _ heightRatio: CGFloat) {
        guard let name = disritct.name, let image = UIImage(named: name)?.withRenderingMode(.alwaysTemplate) else {
            debugPrint("err: fail convert image")
            return
        }
        
        guard let x = disritct.x else {
            debugPrint("err: fail convert x")
            return
        }
        
        guard let y = disritct.y else {
            debugPrint("err: fail convert y")
            return
        }
        
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        
        self.tintColor = (name == "한강") ? #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) : self.districtColor
        self.image = image
        self.contentMode = .scaleAspectFit
        
        self.setLayout(widthRatio, heightRatio)
    }
    
    func setLayout(_ widthRatio: CGFloat, _ heightRatio: CGFloat) {
        guard let x = self.x, let y = self.y, let image = self.image else {
            debugPrint("err: x or y is nil")
            return
        }
        
        let xCoordinate = CGFloat(x) * widthRatio
        let yCoordinate = CGFloat(y) * heightRatio
        let width = image.size.width * widthRatio
        let height = image.size.height * heightRatio
        
        self.frame = CGRect(x: xCoordinate, y: yCoordinate, width: width, height: height)
        
        self.layoutIfNeeded()
    }
    
}
