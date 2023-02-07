//
//  LTComponents.swift
//  luft
//
//  Created by iMac Augusta on 10/8/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import UIKit
import ACFloatingTextfield_Swift

//MARK: <******************UIView******************>

public class AppHeaderView: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func commonSetup() {
        //self.titleLabel?.font = UIFont.openSansSemiboldFontOfSize(14)
        self.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        //self.setTitleColor(UIColor., for: .normal)
    }
}


public class ViewTopCornerRadius: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.roundCorners(top: true, bottom: false, radius: 6.0, borderColor: UIColor.clear, borderWidth: 0.0)
    }
    
    func roundCorners(top:Bool, bottom: Bool, radius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
        self.layer.cornerRadius = 0.0
        if top && bottom {
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.layer.cornerRadius = radius
        }
        else if top {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.layer.cornerRadius = radius
        }
        else if bottom {
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            self.layer.cornerRadius = radius
        }
    }
}

public class LTView: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        //self.titleLabel?.font = UIFont.openSansSemiboldFontOfSize(14)
        self.backgroundColor = ThemeManager.currentTheme().headerViewBGColor
        //self.setTitleColor(UIColor., for: .normal)
    }
}

//MARK:<******************UIImageView******************>
public class LTImageView: UIImageView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.image = ThemeManager.currentTheme().luftImageIconImage
    }
}

//MARK:- Custom Method for APP Used Font
extension UIFont {
    
    class func setAppFontRegular(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "HelveticaNeue", size: size)!
    }
    
    class func setAppFontMedium(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }
    
    class func setAppFontSemiBold(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "Helvetica Neue Bold", size: size)!
    }
    
    class func setAppFontBold(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "HelveticaNeue-Bold", size: size)!
    }
    
    class func setAppFontHeader(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "HelveticaNeue-Regular", size: size)!
    }
    
    class func setSystemFontRegular(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "HelveticaNeue", size: size)!
    }
    
    class func setSystemFontMedium(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "HelveticaNeue-Medium", size: size)!
    }
    
    class func setSystemFontSemiBold(_ size:CGFloat)->(UIFont) {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.semibold)
    }
    
    class func setSystemFontBold(_ size:CGFloat)->(UIFont) {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.bold)
    }
    
    class func setSystemFFontHeader(_ size:CGFloat)->(UIFont) {
        return UIFont.systemFont(ofSize: size, weight: UIFont.Weight.heavy)
    }
    
    class func setAvnierNextAppFontMedium(_ size:CGFloat)->(UIFont) {
        return UIFont(name: "AvenirNext-Medium", size: size)!
    }
    
    
}

