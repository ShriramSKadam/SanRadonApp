//
//  GComponents.swift
//  GreenGram
//
//  Created by iMac Augusta on 3/1/19.
//  Copyright © 2019 augusta-imac6. All rights reserved.
//

import Foundation
import UIKit

var container: UIView = UIView()
var loadingView: UIView = UIView()
var loadingLabel: UILabel = UILabel()
var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
//var activityIndicator: UIImageView = UIImageView()




public class ViewShadowRoundButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setShadowToButton()
    }
    
    func setShadowToButton(){
        self.layer.cornerRadius = 6
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
    }
}

public class ViewBorderButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setShadowToButton()
    }
    
    func setShadowToButton(){
        self.layer.cornerRadius = 1
//        self.layer.borderColor = UIColor.init(hexString: "#E0BF38").cgColor
//        self.layer.borderWidth = 1.0
//        self.backgroundColor = UIColor.init(hexString: "#E0BF38")
    }
}
public class FilterDataTypeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        self.setTitleColor(UIColor.black, for: .normal)
        self.setTitleColor(UIColor.white, for: .selected)
        
    }
    
    override public var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.blue : .white
        }
    }
    

}
public class FilterBasedDaysButton: UIButton {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setShadowToButton()
    }
    
    func setShadowToButton(){
        self.layer.cornerRadius = 1
        self.layer.borderColor = UIColor.init(hexString: "#E0BF38").cgColor
        self.layer.borderWidth = 1.0
        self.backgroundColor = UIColor.init(hexString: "#E0BF38")
    }
}



public class ArticleMoreButton: UIButton {
    var articleString : String = ""
}



public class ViewCornerRadius: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 6.0
        self.layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true
    }
    
}

public class CellViewShadowCornerRadius: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 6
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = CGSize.init(width: 0, height: 5)
        
    }
    
}


public class CommunityCellViewShadowCornerRadius: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        setCornerRadiusToButton(radius: 5)
        self.setShadowToButton()
       
    }
    
    func setShadowToButton(){
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.8
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
    }
    
    func setCornerRadiusToButton(radius: CGFloat){
        layer.cornerRadius = radius
        layer.masksToBounds = true
//        self.layer.cornerRadius = radius
    }
    
}

public class ShadowCellViewWithCornerRadius: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setShadowToButton()
    }
    
    func setShadowToButton(){
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5
        self.layer.cornerRadius = 6.0
    }
  
}

public class NewShadowCellViewWithCornerRadius: UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addShadow()
    }
    
    func addShadow() {
        layer.cornerRadius = 8
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false
        
        updateShadow()
    }
    func updateShadow() {
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds,cornerRadius:8).cgPath
    }
    
}



class ShadowView: UIView {
    
    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }
    
    private func setupShadow() {
        self.layer.cornerRadius = 4
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.3
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height: 8)).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}




public class IMGViewCornerRadiusGray: UIImageView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 6.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
    
}


public class RoundIMGViewCornerRadius: UIImageView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    private func commonSetup() {
        self.layer.cornerRadius = self.frame.width / 2.0
        self.layer.borderColor = UIColor.white.cgColor
        self.clipsToBounds = true

    }
    
}

extension UIViewController {
    
    
    
   
    
    func containsIgnoringCaseComma(find: String) -> Bool{
        // alternative: not case sensitive
        if find.lowercased().range(of:",") != nil {
            return true
        }
        return false
    }
    
    
   
    func showActivityIndicator(_ uiView: UIView,isShow:Bool = false,isShowText:String = "") {
        container.frame = UIScreen.main.bounds
        
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
        //        container.backgroundColor = UIColor.clear
        if isShow == true {
            loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        }else {
            loadingView.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
            loadingLabel.frame = CGRect(x: 0, y: loadingView.frame.height - 30 , width: 300, height: 30)
            if isShowText == ""{
                loadingLabel.text = "Please wait..."
            }else {
                loadingLabel.text = isShowText
            }
            
            loadingLabel.textAlignment = .center
            loadingView.addSubview(loadingLabel)
        }
        
        loadingView.center = container.center
        
        //        loadingView.backgroundColor = UIColor.clear
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);

        if ThemeManager.currentTheme() == .theme2 {
            loadingLabel.textColor = UIColor.white
            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            //loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.9)
            loadingView.backgroundColor = UIColor().colorFromHexString("#24272d")
        }else {
            loadingLabel.textColor = UIColor.black
            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            activityIndicator.color = UIColor.black
            loadingView.backgroundColor = UIColor().colorFromHexString("#F5F5FA").withAlphaComponent(0.9)
        }
        
        
//        switch self {
//        case .theme1:
//            return UIColor().colorFromHexString("#F5F5FA")
//        case .theme2:
//            return UIColor().colorFromHexString("#24272d")
//        }
        
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        UIApplication.shared.keyWindow?.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    func showActivityIndicatorForHome(_ uiView: UIView) {
        container.frame = UIScreen.main.bounds
        
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
        //        container.backgroundColor = UIColor.clear
        loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        loadingView.center = container.center
        loadingView.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        //        loadingView.backgroundColor = UIColor.clear
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        
        activityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2);
        
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        UIApplication.shared.keyWindow?.addSubview(container)
        activityIndicator.startAnimating()
    }
    
    public func hideActivityIndicator(_ uiView: UIView) {
        //activityIndicator.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
           container.removeFromSuperview()
        }
        
    }
    
   
    
    public func UIColorFromHex(_ rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    func getFormattedDate(dateStr: String) -> String{
        
        let dateFormatter = DateFormatter() //
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS" //Your date format
        let date = dateFormatter.date(from: dateStr) //according to date format your date string
        if date == nil {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let date1 = dateFormatter.date(from: dateStr)
            if date1 == nil{
                return ""
            }else {
                dateFormatter.dateFormat = "MMM dd, yyyy"
                let newDateString = dateFormatter.string(from: date1!)
                
                return newDateString
            }
        }
        //Convert String to Date
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let newDateString = dateFormatter.string(from: date!)
        return newDateString
    }
    
    public func scaleImageToSize(image : UIImage, newSize : CGSize) -> UIImage{
        var scaledImageRect = CGRect.zero
        let aspectWidth = newSize.width / image.size.width
        let aspectheight = newSize.height / image.size.height
        let aspectRatio = max(aspectWidth, aspectheight)
        scaledImageRect.size.width = image.size.width * aspectRatio
        scaledImageRect.size.height = image.size.height * aspectRatio
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in : scaledImageRect)
        UIGraphicsGetCurrentContext()?.interpolationQuality = .high
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!
    }
    
    
    func isCharValidPassword(password: String) -> Bool {
        let regularExpression = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[_$@$!%*?&])[A-Za-z\\d$@$!%*?&]{8,}"
        let passwordValidation = NSPredicate.init(format: "SELF MATCHES %@", regularExpression)
        
        return passwordValidation.evaluate(with: password)
    }
    
    func isValidURL1(URLString : String) -> (isValidImgeUrl:Bool, updatedImgUrlString:String) {
        let URLStringUpdate = URLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let url = NSURL(string: URLStringUpdate!) {
            return (UIApplication.shared.canOpenURL(url as URL), URLStringUpdate!)
        }
        return (false, URLStringUpdate!)
    }
}

extension UIImage{
    
    func resizeTheImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        switch contentMode {
        case .scaleAspectFit:
            if aspectRatio > 1 {                            // Landscape image
                width = dimension
                height = dimension / aspectRatio
            } else {                                        // Portrait image
                height = dimension
                width = dimension * aspectRatio
            }
            
        default:
            fatalError("UIIMage.resizeToFit(): FATAL: Unimplemented ContentMode")
        }
        
        if #available(iOS 11.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
            UIGraphicsGetCurrentContext()?.interpolationQuality = .high
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
    
    func squareMyImage() -> UIImage {
        UIGraphicsBeginImageContext(CGSize(width: self.size.width, height: self.size.width))
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.width))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if(newImage == nil)
        {
            return UIImage(named: "default_profile")!
        }
        else{
            return newImage!
        }
        
    }
    
    func resizeMyImage(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if(newImage == nil)
        {
            return UIImage(named: "default_profile")!
        }
        else{
            return newImage!
        }
    }
    
    var roundMyImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        if(UIGraphicsGetImageFromCurrentImageContext() == nil)
        {
            return UIImage(named: "default_profile")!
        }
        else
        {
            return UIGraphicsGetImageFromCurrentImageContext()!
        }
        
    }
}

extension UIImage {
    
    public class func gifImageWithData(data: NSData) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source: source)
    }
    
    public class func gifImageWithURL(gifUrl:String) -> UIImage? {
        guard let bundleURL = NSURL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = NSData(contentsOf: bundleURL as URL) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    public class func gifImageWithName(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        
        guard let imageData = NSData(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(data: imageData)
    }
    
    class func delayForImageAtIndex(index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(CFDictionaryGetValue(cfProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()), to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()), to: AnyObject.self)
        
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties, Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a! < b! {
            let c = a!
            a = b!
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b!
                b = rest
            }
        }
    }
    
    class func gcdForArray(array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(a: val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(index: Int(i), source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(array: delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames, duration: Double(duration) / 1000.0)
        
        return animation
    }
}
