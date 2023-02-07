//
//  AUPasswordFieldHelper.swift
//  SampleTextFieldHelper
//
//  Created by augusta on 06/08/18.
//  Copyright © 2018 augusta. All rights reserved.
//

import UIKit

public enum AUPasswordHelperValidationParams {
    case minMaxCharacterLimit
    case upperCaseNeeded
    case lowerCaseNeeded
    case numericNeeded
    case specialCharNeeded
    case noBlankSpace
}

public enum AUPasswordHelperPosition{
    case top
    case bottom
}

public class AUPasswordFieldHelper: UIView {
    
    @IBOutlet public weak var helperView: UIView!
    @IBOutlet weak var minMaxCharStackView: UIStackView!
    @IBOutlet weak var upperCaseStackView: UIStackView!
    @IBOutlet weak var lowerCaseStackView: UIStackView!
    @IBOutlet weak var numericStackView: UIStackView!
    @IBOutlet weak var specialCharacterStackView: UIStackView!
    @IBOutlet weak var blankSpaceStackView: UIStackView!
    @IBOutlet weak var minMaxImageView: UIImageView!
    @IBOutlet weak var upperCaseImageView: UIImageView!
    @IBOutlet weak var lowerCaseImageView: UIImageView!
    @IBOutlet weak var numbericImageView: UIImageView!
    @IBOutlet weak var specialCharImageView: UIImageView!
    @IBOutlet weak var blankSpaceImageView: UIImageView!
    @IBOutlet weak var helperViewHeightConstraint: NSLayoutConstraint!
    
    private var mappedTextField: UITextField?
    private var tickMarkImage: UIImage?
    private var unTickImage: UIImage?
    var blurEffectView: UIVisualEffectView?
    public var isHelperShown: Bool = false
    var isAutoEnabled: Bool = true
    
    private var itemsNeededForValidation: [AUPasswordHelperValidationParams]?
    
    //iPhone SE top n botom space handling
    @IBOutlet weak var helperViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var helperViewBottomConstraint: NSLayoutConstraint!
    
    
    public override init(frame: CGRect) { // for using CustomView in code
        super.init(frame: frame)
        self.commonInit()
        helperView.layer.cornerRadius = 10
    }
    
    required public init?(coder aDecoder: NSCoder) { // for using CustomView in IB
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        let bundle1 = Bundle(for: AUPasswordFieldHelper.self)
        bundle1.loadNibNamed("AUPasswordFieldHelper", owner: self, options: nil)
        guard let content = helperView else { return }
        content.frame = self.bounds
        content.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(content)
    }
    
    public var minimumCharLimit : Int = -1
    public var maximumCharLimit : Int = -1
    
    public func configurePasswordHelper(textField: UITextField, position: AUPasswordHelperPosition, isAutoEnable: Bool = true, isInsideTableView: Bool, superView: UIView?, cell: UITableViewCell?, itemsNeeded:[AUPasswordHelperValidationParams], tickImage: UIImage, unTickImage: UIImage){
        self.mappedTextField = textField
        self.isAutoEnabled = isAutoEnable
        if(UIDevice.current.screenType.rawValue ==  "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"){
            self.helperViewHeightConstraint.constant = CGFloat(itemsNeeded.count * 25) + 25
            helperViewTopConstraint.constant = 0
            helperViewBottomConstraint.constant = 0
        }
        else{
            self.helperViewHeightConstraint.constant = CGFloat(itemsNeeded.count * 25) + 45 // (top and bottom height height)
        }
        
        itemsNeededForValidation = itemsNeeded
        if(!itemsNeeded.contains(.minMaxCharacterLimit)){
            minMaxCharStackView.isHidden = true
        }
        if(!itemsNeeded.contains(.upperCaseNeeded)){
            upperCaseStackView.isHidden = true
        }
        if(!itemsNeeded.contains(.lowerCaseNeeded)){
            lowerCaseStackView.isHidden = true
        }
        if(!itemsNeeded.contains(.numericNeeded)){
            numericStackView.isHidden = true
        }
        if(!itemsNeeded.contains(.specialCharNeeded)){
            specialCharacterStackView.isHidden = true
        }
        if(!itemsNeeded.contains(.noBlankSpace)){
            blankSpaceStackView.isHidden = true
        }
        
        minMaxImageView.image = unTickImage
        upperCaseImageView.image = unTickImage
        lowerCaseImageView.image = unTickImage
        numbericImageView.image = unTickImage
        blankSpaceImageView.image = unTickImage
        specialCharImageView.image = unTickImage
        self.unTickImage = unTickImage
        self.tickMarkImage = tickImage
        self.addPasswordHelperViewInView(isInsideTableView: isInsideTableView, superView: superView, cell: cell, position: position)
    }
    
    private func addPasswordHelperViewInView(isInsideTableView:Bool, superView: UIView?, cell: UITableViewCell?, position: AUPasswordHelperPosition){
        
        mappedTextField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        mappedTextField?.addTarget(self, action: #selector(textFieldDidBegin(_:)), for: .editingDidBegin)
        mappedTextField?.addTarget(self, action: #selector(textFieldDidEnd(_:)), for: .editingDidEnd)
        if(isInsideTableView){
            self.translatesAutoresizingMaskIntoConstraints = false
            var topOrBottomConstraint : NSLayoutConstraint?
            if(position == .top){
                topOrBottomConstraint = NSLayoutConstraint(item: helperView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1, constant: 0)
                
            }
            else{
                topOrBottomConstraint = NSLayoutConstraint(item: helperView, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1, constant: 0)
                
            }
            let xConstraint = NSLayoutConstraint(item: helperView, attribute: .centerX, relatedBy: .equal, toItem: cell, attribute: .centerX, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: helperView, attribute: .width, relatedBy: .equal, toItem: cell, attribute: .width, multiplier: 0.95, constant: 0)
            superView?.clipsToBounds = false
            
            helperView.isHidden = true
            self.isHelperShown = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                superView?.addSubview(self.helperView)
                superView?.addConstraints([topOrBottomConstraint!, xConstraint, widthConstraint])
                // Blur Effect
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
                    self.blurEffectView = UIVisualEffectView(effect: blurEffect)
                    self.blurEffectView?.frame = self.helperView.frame
                    self.blurEffectView?.clipsToBounds = true
                    self.blurEffectView?.layer.cornerRadius = 10
                    superView?.addSubview(self.blurEffectView!)
                    
                    
                    // Vibrancy Effect
                    let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
                    let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
                    vibrancyEffectView.frame = self.helperView.frame
                    
                    // Add the vibrancy view to the blur view
                    self.blurEffectView?.contentView.addSubview(vibrancyEffectView)
                    
                    superView?.bringSubviewToFront(self.helperView)
                    self.blurEffectView?.isHidden = true
                }
            }
        }
        else{
            self.translatesAutoresizingMaskIntoConstraints = false
            var topOrBottomConstraint : NSLayoutConstraint?
            if(position == .top){
                topOrBottomConstraint = NSLayoutConstraint(item: helperView, attribute: .bottom, relatedBy: .equal, toItem: mappedTextField, attribute: .top, multiplier: 1, constant: 0)
            }
            else{
                topOrBottomConstraint = NSLayoutConstraint(item: helperView, attribute: .top, relatedBy: .equal, toItem: mappedTextField, attribute: .bottom, multiplier: 1, constant: 0)
                
            }
            let xConstraint = NSLayoutConstraint(item: helperView, attribute: .centerX, relatedBy: .equal, toItem: mappedTextField?.superview, attribute: .centerX, multiplier: 1, constant: 0)
            let widthConstraint = NSLayoutConstraint(item: helperView, attribute: .width, relatedBy: .equal, toItem: mappedTextField?.superview, attribute: .width, multiplier: 1, constant: 0)
            mappedTextField?.superview?.addSubview(helperView)
            helperView.isHidden = true
            self.isHelperShown = false
            mappedTextField?.superview?.addConstraints([topOrBottomConstraint!, xConstraint, widthConstraint])
            mappedTextField?.superview?.layoutIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
                self.blurEffectView = UIVisualEffectView(effect: blurEffect)
                self.blurEffectView?.frame = self.helperView.frame
                self.blurEffectView?.clipsToBounds = true
                self.blurEffectView?.layer.cornerRadius = 10
                superView?.addSubview(self.blurEffectView!)
                
                
                // Vibrancy Effect
                let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
                let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
                vibrancyEffectView.frame = self.helperView.frame
                
                // Add the vibrancy view to the blur view
                self.blurEffectView?.contentView.addSubview(vibrancyEffectView)
                
                superView?.bringSubviewToFront(self.helperView)
                self.blurEffectView?.isHidden = true
            }
            self.validateBasedOnText(textString: mappedTextField?.text ?? "")
        }
        
        
        
        
        
        
        //tableView.layoutIfNeeded()
        self.validateBasedOnText(textString: mappedTextField?.text ?? "")
    }
    
    public func showOrHideHelper(show: Bool){
        if(isAutoEnabled){
            if(show){
                if(self.isHelperShown == false){
                    UIView.transition(with: self.blurEffectView!, duration: 0.25, options: .transitionFlipFromBottom, animations: {
                        self.helperView.isHidden = false
                        self.blurEffectView?.isHidden = false
                        self.isHelperShown = true
                        UIView.transition(with: self.helperView!, duration: 0.25, options: .transitionFlipFromBottom, animations: {})
                        
                    })
                }
            }
            else{
                if(self.isHelperShown == true){
                    UIView.transition(with: self.blurEffectView!, duration: 0.25, options: .transitionFlipFromTop, animations: {
                        self.helperView.isHidden = true
                        self.blurEffectView?.isHidden = true
                        self.isHelperShown = false
                        UIView.transition(with: self.helperView!, duration: 0.25, options: .transitionFlipFromTop, animations: {})
                        
                    })
                }
            }
        }
    }
    
    public func toggleHelper(){
        if(self.isHelperShown){
            UIView.transition(with: self.blurEffectView!, duration: 0.25, options: .transitionFlipFromTop, animations: {
                self.helperView.isHidden = true
                self.blurEffectView?.isHidden = true
                self.isHelperShown = false
                UIView.transition(with: self.helperView!, duration: 0.25, options: .transitionFlipFromTop, animations: {})
                
            })
            
        }
        else{
            UIView.transition(with: self.blurEffectView!, duration: 0.25, options: .transitionFlipFromBottom, animations: {
                self.helperView.isHidden = false
                self.blurEffectView?.isHidden = false
                self.isHelperShown = true
                UIView.transition(with: self.helperView!, duration: 0.25, options: .transitionFlipFromBottom, animations: {})
            })
            
        }
    }
    
    public func validateBasedOnText(textString: String){
        
        var validationSuccessCount: Int = 0
        
        charLabel: if(self.itemsNeededForValidation?.contains(.minMaxCharacterLimit))!{
            if(self.minimumCharLimit == -1 || self.maximumCharLimit == -1){
                print("Minimum and maximum char limit is not set. Please set and try again")
                break charLabel
            }
            if(textString.count >= self.minimumCharLimit && textString.count <= self.maximumCharLimit){
                self.minMaxImageView.image = self.tickMarkImage
                validationSuccessCount = validationSuccessCount + 1
            }
            else{
                self.minMaxImageView.image = self.unTickImage
            }
            
        }
        
        if(self.itemsNeededForValidation?.contains(.upperCaseNeeded))!{
            let capitalLetterRegEx  = ".*[A-Z]+.*"
            let texttest = NSPredicate(format:"SELF MATCHES %@", capitalLetterRegEx)
            let capitalresult = texttest.evaluate(with: textString)
            
            if(capitalresult){
                self.upperCaseImageView.image = self.tickMarkImage
                validationSuccessCount = validationSuccessCount + 1
            }
            else{
                self.upperCaseImageView.image = self.unTickImage
            }
        }
        
        if(self.itemsNeededForValidation?.contains(.lowerCaseNeeded))!{
            let lowerLetterRegEx  = ".*[a-z]+.*"
            let texttest = NSPredicate(format:"SELF MATCHES %@", lowerLetterRegEx)
            let capitalresult = texttest.evaluate(with: textString)
            
            if(capitalresult){
                self.lowerCaseImageView.image = self.tickMarkImage
                validationSuccessCount = validationSuccessCount + 1
            }
            else{
                self.lowerCaseImageView.image = self.unTickImage
            }
        }
        
        if(self.itemsNeededForValidation?.contains(.numericNeeded))!{
            let numberRegEx  = ".*[0-9]+.*"
            let texttest = NSPredicate(format:"SELF MATCHES %@", numberRegEx)
            let numberresult = texttest.evaluate(with: textString)
            
            if(numberresult){
                self.numbericImageView.image = self.tickMarkImage
                validationSuccessCount = validationSuccessCount + 1
            }
            else{
                self.numbericImageView.image = self.unTickImage
            }
        }
        
        if(self.itemsNeededForValidation?.contains(.specialCharNeeded))!{
            let specialCharacterRegEx  = ".*[!&^%$#@()/]+.*"
            let texttest = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
            let specialresult = texttest.evaluate(with: textString)
            
            if(specialresult){
                self.specialCharImageView.image = self.tickMarkImage
                validationSuccessCount = validationSuccessCount + 1
            }
            else{
                self.specialCharImageView.image = self.unTickImage
            }
        }
        
        if(self.itemsNeededForValidation?.contains(.noBlankSpace))!{
            let specialCharacterRegEx  = ".*[ ]+.*"
            let texttest = NSPredicate(format:"SELF MATCHES %@", specialCharacterRegEx)
            let specialresult = texttest.evaluate(with: textString)
            if(specialresult){
                self.blankSpaceImageView.image = self.unTickImage
            }
            else{
                self.blankSpaceImageView.image = self.tickMarkImage
                validationSuccessCount = validationSuccessCount + 1
            }
        }
        
        if(validationSuccessCount == self.itemsNeededForValidation?.count){
            self.showOrHideHelper(show: false)
        }
        else{
            if(self.mappedTextField?.text != ""){
                self.showOrHideHelper(show: true)
            }
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.validateBasedOnText(textString: textField.text!)
    }
    
    @objc func textFieldDidBegin(_ textField: UITextField) {
        self.showOrHideHelper(show: true)
    }
    
    @objc func textFieldDidEnd(_ textField: UITextField) {
        self.showOrHideHelper(show: false)
    }
    
    
}

extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    public enum ScreenType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhoneX
        default:
            return .unknown
        }
    }
    
}

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()

}
