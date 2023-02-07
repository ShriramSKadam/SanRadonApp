//
//  LTCellDashBoardComponents.swift
//  luft
//
//  Created by iMac Augusta on 10/14/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import UIKit
import ACFloatingTextfield_Swift

//MARK: <******************Button******************>
public class LTCellSyncButton: UIButton { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.setImage(ThemeManager.currentTheme().luftDashBoardSyncIconImage, for: .normal)
    }
}

public class LTCellSyncHeaderLabel: UILabel { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.font = UIFont.setAppFontMedium(13)
    }
}

public class LTCellSyncLabel: UILabel { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().clearColor
        self.font = UIFont.setAppFontRegular(13)
    }
}

public class LTCellBorderSyncLabel: UILabel { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltSyncBorderLabel
        self.font = UIFont.setAppFontRegular(13)
    }
}
public class LTCellDeviceLabel: UILabel { //LT Common-Button
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.textColor = UIColor.white
        self.font = UIFont.setAppFontRegular(13)
    }
}
