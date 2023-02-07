//
//  BlinkingViewTableViewCell.swift
//  Luft
//
//  Created by APPLE on 13/11/19.
//  Copyright © 2019 iMac. All rights reserved.
//

import UIKit
let ANIMATION_DURATION_BLINK = 1.5

class BlinkingViewTableViewCell: UITableViewCell {

    @IBOutlet weak var blinkView: UIView!
    @IBOutlet weak var lblBlinkView: UILabel!
    
    var animationStarted : Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        blinkView.backgroundColor = UIColor().colorFromHexString("#3E82F7")
        blinkView.clipsToBounds = true
        blinkView.layer.cornerRadius = 7
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func startAnimation(){
//        if self.animationStarted == false{
//            self.blinkBlueToWhite(withDuration: ANIMATION_DURATION_BLINK, fromColor:  UIColor.blue, toColor: .white)
//            self.animationStarted = true
//        }
        
    }
    
    public func blinkBlueToWhite(withDuration duration: Double, fromColor: UIColor, toColor: UIColor) {
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
             self.blinkView.backgroundColor = fromColor
             self.blinkView.backgroundColor = toColor
        },
        completion: { [weak self] finished in
              self?.blinkWhiteToBlue(withDuration: ANIMATION_DURATION_BLINK, fromColor: .white, toColor: .blue)
        })
        
    }
    
    public func blinkWhiteToBlue(withDuration duration: Double, fromColor: UIColor, toColor: UIColor) {
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.blinkView.backgroundColor = fromColor
            self.blinkView.backgroundColor = toColor
        },
        completion: { [weak self] finished in
            self?.blinkBlueToWhite(withDuration: ANIMATION_DURATION_BLINK, fromColor:  UIColor.blue, toColor: .white)
        })
        
    }
    
}


//extension UIView{
//    public func blink(withDuration duration: Double = 0.25, color: UIColor? = nil) {
//
//        alpha = 0.2
//        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
//            self.alpha = 1.0
//        })
//
//        guard let newBackgroundColor = color else { return }
//        let oldBackgroundColor = backgroundColor
//
//        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
//            self.backgroundColor = newBackgroundColor
//            self.backgroundColor = oldBackgroundColor
//        })
//
//    }
//}
