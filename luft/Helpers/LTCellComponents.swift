//
//  LTCellComponents.swift
//  luft
//
//  Created by iMac Augusta on 10/10/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import Foundation
import UIKit
import ACFloatingTextfield_Swift

//MARK: <******************UIView - Header******************>
public class LTCellHeaderView: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
    }
}

//MARK:<******************UILable - Header******************>
public class LTCellHeaderBorderLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltCellHeaderBorderColor
    }
}

public class LTCellHeaderTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setAppFontRegular(17)
        self.textColor = ThemeManager.currentTheme().ltCellHeaderTitleColor
        self.backgroundColor = UIColor.clear
    }
}

public class LTFliterButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.setTitleColor(ThemeManager.currentTheme().ltFilterButtonTitleColor, for: .normal)
        self.titleLabel?.font = UIFont.setAppFontMedium(15)
        self.backgroundColor = UIColor.clear
    }
}

public class LTFliterHeaderTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setAppFontMedium(17)
        self.textColor = ThemeManager.currentTheme().ltFilterButtonTitleColor
        self.backgroundColor = UIColor.clear
    }
}

public class LTCellHeaderDataTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setAppFontRegular(17)
    }
}

public class LTCellDataTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.font = UIFont.setAppFontRegular(17)
    }
}
//MARK: <******************UIView******************>

public class LTHeaderCellView: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltCellHeaderViewBackgroudColor
    }
}

public class LTCellView: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltCellViewBackgroudColor
    }
}

public class LTTempOffsetCellView: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltTempOffsetHeaderViewBackgroudColor
    }
}

//MARK:<******************UILable******************>
public class LTCellBorderLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltCellBorderColor
        self.alpha = 1.0
    }
}

public class LTCellTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.textColor = ThemeManager.currentTheme().ltCellTitleColor
        self.font = UIFont.setAppFontRegular(17)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}

public class LTCellSubTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        self.font = UIFont.setAppFontRegular(17)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}

public class LTCellDashBoardBorderLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.backgroundColor = ThemeManager.currentTheme().ltCellDashNBoardBorderColor
        self.alpha = 1.0
    }
}

public class LTFWCellTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        self.font = UIFont.setAppFontRegular(17)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}

public class LTFWCellSubTitleLabel: UILabel {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.textColor = ThemeManager.currentTheme().ltCellSubtitleColor
        self.font = UIFont.setAppFontRegular(13)
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}
//MARK:<******************Cell - UIImageView******************>
public class LTCellDisclosureImageView: UIImageView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.image = ThemeManager.currentTheme().cellDisclousreIconImage
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}

public class LTCellCheckMarkImageView: UIImageView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.image = ThemeManager.currentTheme().cellCheckMarkIconImage
        self.backgroundColor = ThemeManager.currentTheme().clearColor
    }
}

