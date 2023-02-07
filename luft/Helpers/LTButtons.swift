//
//  LTButtons.swift
//  luft
//
//  Created by iMac Augusta on 10/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import UIKit
import ACFloatingTextfield_Swift

//MARK: <******************Button******************>
public class LTCommonButton: UIButton { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontRegular(14)
        self.backgroundColor = ThemeManager.currentTheme().buttonBackgroundColor
        self.setTitleColor(ThemeManager.currentTheme().buttonCommonTitleColor, for: .normal)
    }
}

public class LTGrayCommonButton: UIButton { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontRegular(14)
        //self.backgroundColor = ThemeManager.currentTheme().buttonBackgroundColor
        self.setTitleColor(ThemeManager.currentTheme().buttonGrayCommonTitleColor, for: .normal)
    }
}

public class LTNormalButton: UIButton { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontRegular(14)
        self.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.setTitleColor(ThemeManager.currentTheme().buttonTitleColor, for: .normal)
        self.layer.borderColor = ThemeManager.currentTheme().borderColor.cgColor
        self.layer.borderWidth = 2.0
    }
}

public class LTBlueTextNormalButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontRegular(14)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.setTitleColor(ThemeManager.currentTheme().blueTextButtonTitleColor, for: .normal)
        self.layer.borderColor = ThemeManager.currentTheme().clearColor.cgColor
    }
}

public class LTBlueTextButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontRegular(14)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.setTitleColor(ThemeManager.currentTheme().blueTextButtonTitleColor, for: .normal)
        self.layer.borderColor = ThemeManager.currentTheme().clearColor.cgColor
        let stringValue:String = self.titleLabel?.text ?? "Forgot password?"
        let titleString = NSMutableAttributedString(string: self.titleLabel?.text ?? "Forgot password?")
        titleString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, stringValue.count))
        self.setAttributedTitle(titleString, for: .normal)
    }
}
public class LTGoogleImageButton: UIButton { //LT Image-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontRegular(14)
        self.backgroundColor = ThemeManager.currentTheme().imgGoogleButtonBGColor
        self.setTitleColor(ThemeManager.currentTheme().imgGoogleButtonTitleColor, for: .normal)
        self.layer.borderColor = UIColor.init(hexString:GOOGLE_COLOR_CODE).cgColor
        self.layer.borderWidth = 2.0
        self.setImage(UIImage.init(named:SINGUP_GMAIL_IMAGE), for: .normal)
        let insetAmount:CGFloat = 20 / 2 // the amount of spacing to appear between image and title
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
}

public class LTFacebookImageButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontRegular(14)
        self.backgroundColor = UIColor.init(hexString:FACEBOOK_COLOR_CODE)
        self.setTitleColor(ThemeManager.currentTheme().imgButtonTitleColor, for: .normal)
        self.layer.borderColor = UIColor.init(hexString:FACEBOOK_COLOR_CODE).cgColor
        self.layer.borderWidth = 2.0
        self.setImage(UIImage.init(named:SINGUP_FACEBOOK_IMAGE), for: .normal)
        let insetAmount:CGFloat = 20 / 2 // the amount of spacing to appear between image and title
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
}

public class LTAppleImageButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontRegular(14)
        self.backgroundColor = UIColor.init(hexString:FACEBOOK_COLOR_CODE)
        self.setTitleColor(ThemeManager.currentTheme().imgButtonTitleColor, for: .normal)
        self.layer.borderColor = UIColor.init(hexString:FACEBOOK_COLOR_CODE).cgColor
        self.layer.borderWidth = 2.0
        self.setImage(UIImage.init(named:SINGUP_FACEBOOK_IMAGE), for: .normal)
        let insetAmount:CGFloat = 20 / 2 // the amount of spacing to appear between image and title
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
    }
}

public class LTBackImageButton: UIButton { //LT Back-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.setImage(ThemeManager.currentTheme().backNewIconImage, for: .normal)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
    }
}

public class LTMenuImageButton: UIButton { //LT Back-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.setImage(ThemeManager.currentTheme().menuIconImage, for: .normal)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}


public class LTAddImageButton: UIButton { //LT Back-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.setImage(ThemeManager.currentTheme().addIconImage, for: .normal)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}

public class LTRefresImageButton: UIButton { //LT Back-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.setImage(ThemeManager.currentTheme().menuRefreshIconImage, for: .normal)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}

public class LTChartButton: UIButton { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontMedium(12)
        self.backgroundColor = UIColor.clear
        self.setTitleColor(ThemeManager.currentTheme().chartButtonTitleColor, for: .normal)
        self.layer.borderColor = ThemeManager.currentTheme().chartBorderColor.cgColor
        self.layer.borderWidth = 16.5
    }
}

public class LTUpdateButton: UIButton { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func commonSetup() {
        self.titleLabel?.font = UIFont.setAppFontRegular(14)
        self.backgroundColor = UIColor.clear
        self.setTitleColor(ThemeManager.currentTheme().buttonTitleColor, for: .normal)
        //self.layer.borderColor = ThemeManager.currentTheme().borderColor.cgColor
        //self.layer.borderWidth = 2.0
    }
}
