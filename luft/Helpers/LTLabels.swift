//
//  LTLabels.swift
//  luft
//
//  Created by iMac Augusta on 10/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import UIKit
import ACFloatingTextfield_Swift

//MARK:<******************UILable******************>
public class LTBorderLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().borderColor
    }
}

public class LTORLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    func commonSetup() {
        self.font = UIFont.setAppFontMedium(12)
        self.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.textColor = ThemeManager.currentTheme().titleTextColor
    }
}

public class LTHeaderBorderLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        //self.backgroundColor = ThemeManager.currentTheme().headerBorderColor
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}

public class LTHeaderTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setAppFontBold(17)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.textColor = ThemeManager.currentTheme().headerTitleTextColor
    }
}

public class LTHeavyTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setAppFontMedium(20)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.textColor = ThemeManager.currentTheme().titleTextColor
    }
}

public class LTTitleLabel: UILabel {
    
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
        self.textColor = ThemeManager.currentTheme().titleTextColor
    }
}

public class LTSubtileLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setAppFontRegular(14)
        self.backgroundColor = ThemeManager.currentTheme().viewBackgroundColor
        self.textColor = ThemeManager.currentTheme().subtitleTextColor
    }
}
