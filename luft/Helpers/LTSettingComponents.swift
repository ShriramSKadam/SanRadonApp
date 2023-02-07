//
//  LTSettingComponents.swift
//  luft
//
//  Created by iMac Augusta on 10/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import UIKit
import ACFloatingTextfield_Swift

//MARK: <******************UIView - Header******************>
public class LTSettingHeaderView: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltSettingHeaderColor
    }
}

public class LTSettingHeaderLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.textColor = ThemeManager.currentTheme().ltSettingHeaderTitleColor
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.font = UIFont.setSystemFontRegular(13)
    }
}

public class LTInfoSettingHeaderLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.textColor = ThemeManager.currentTheme().ltInfoHeaderTitleColor
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.font = UIFont.setSystemFontRegular(16)
    }
}

public class LTSettingHeaderBorderLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltSettingHeaderBorderColor
    }
}

public class IntialLTAccountHeaderBorderLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setAppFontMedium(14)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.textColor = ThemeManager.currentTheme().ltCellTitleColor
        
    }
}

public class LTSettingTextBackView: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltSettingTxtBackgroundColor
    }
}
public class LTSettingEMailBackView: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltSettingEmailTxtBackgroundColor
    }
}



public class LTSettingTextFiled: UITextField {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.textColor = ThemeManager.currentTheme().ltSettingTxtColor
        self.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.font = UIFont.setAppFontRegular(17)
        self.clearButtonMode = UITextField.ViewMode.always
        if let clearButton = self.value(forKeyPath: "_clearButton") as? UIButton {
            clearButton.setImage(UIImage(named:"clearText"), for: .normal)
            clearButton.setImage(UIImage(named:"clearText"), for: .highlighted)
        }
        self.placeHolderColor = ThemeManager.currentTheme().ltSettingPlaceHolderTxtColor
    }
}


public class LTSettingHintLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setSystemFontRegular(14)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.textColor = ThemeManager.currentTheme().subtitleTextColor
    }
}

public class LTTipLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setSystemFontRegular(14)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.textColor = ThemeManager.currentTheme().subtitleTextColor
    }
}
public class LTInfoSettingHintLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setSystemFontRegular(14)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.textColor = ThemeManager.currentTheme().subtitleTextColor
    }
}
public class LTAddDeviceSettingHintLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setAppFontMedium(14)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.textColor = ThemeManager.currentTheme().buttonGrayCommonTitleColor
    }
}



extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

public class LTSliderHeaderView: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltSliderHeaderColor
    }
}
