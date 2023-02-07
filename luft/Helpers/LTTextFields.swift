//
//  LTTextFields.swift
//  luft
//
//  Created by iMac Augusta on 10/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import ACFloatingTextfield_Swift

//MARK:<******************TextField******************>
public class LTCommonTextField: ACFloatingTextfield {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
        //fatalError("init(coder:) has not been implemented")
    }
    
    func commonSetup() {
       // self.textColor = ThemeManager.currentTheme().textFieldTextColor
        self.font = UIFont.setAppFontRegular(14)
        self.selectedLineColor = ThemeManager.currentTheme().borderColor
        self.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.lineColor = ThemeManager.currentTheme().borderColor
        self.placeHolderColor  = ThemeManager.currentTheme().textFieldTextColor
//        self.clearButtonMode = UITextField.ViewMode.always
//        if let clearButton = self.value(forKeyPath: "_clearButton") as? UIButton {
//            clearButton.setImage(UIImage(named:"clearText"), for: .normal)
//            clearButton.setImage(UIImage(named:"clearText"), for: .highlighted)
//        }
        self.textColor = ThemeManager.currentTheme().ltSettingTxtColor
        self.selectedPlaceHolderColor = ThemeManager.currentTheme().ltSettingPlaceHolderTxtColor
    }
}


public class LTCommonSearchView: UISearchBar {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonSetup()
    }
    
    func commonSetup() {
        self.setTextField(color: ThemeManager.currentTheme().viewBackgroundColor)
        self.setTextFieldColor(color: ThemeManager.currentTheme().ltSettingTxtColor)
        self.setPlaceholderTextFieldColor(color: ThemeManager.currentTheme().ltSettingPlaceHolderTxtColor)
    }
}

extension UISearchBar {
    
    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    
    func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }
    
    func setTextFieldColor(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.textColor = color
        @unknown default: break
        }
    }
    
    func setPlaceholderTextFieldColor(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.placeHolderColor = color
        @unknown default: break
        }
    }
    
    func setSearchBorderTextFieldColor(color: UIColor) {
        guard let textField = getTextField() else { return }
        textField.layer.cornerRadius = 5.0
        textField.layer.borderColor = color.cgColor
        textField.layer.borderWidth = 1.0
        textField.clipsToBounds = true
    }
    
    func setSearchBorderImageColor(color: UIColor) {
        guard let textField = getTextField() else { return }
        if let iconView = textField.leftView as? UIImageView {
            iconView.image = iconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            iconView.tintColor = color
        }
    }
}
