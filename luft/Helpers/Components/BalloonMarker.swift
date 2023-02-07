//
//  BalloonMarker.swift
//  ChartsDemo-Swift
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import Charts
#if canImport(UIKit)
    import UIKit
#endif

struct BalloonMarkerData {
    var unitString : String = "F"
    var numberPrecision : Int = 0
    var dateFormat: String = "yyyy/MM/dd"
}

var balloonMarkerData: BalloonMarkerData = BalloonMarkerData.init(unitString: "F", numberPrecision: 1, dateFormat: "yyyy/MM/dd")

open class BalloonMarker: MarkerImage
{
    open var color: UIColor
    open var arrowSize = CGSize(width: 15, height: 11)
    open var font: UIFont
    open var textColor: UIColor
    open var insets: UIEdgeInsets
    open var minimumSize = CGSize()
    
    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate var _drawAttributes = [NSAttributedString.Key : Any]()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        super.init()
    }
    
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        var offset = self.offset
        var size = self.size
        
        if size.width == 0.0 && image != nil
        {
            size.width = image!.size.width
        }
        if size.height == 0.0 && image != nil
        {
            size.height = image!.size.height
        }
        
        let width = size.width
        let height = size.height
        let padding: CGFloat = 8.0

        var origin = point
        origin.x -= width / 2
        origin.y -= height

        if origin.x + offset.x < 0.0
        {
            offset.x = -origin.x + padding
        }
        else if let chart = chartView,
            origin.x + width + offset.x > chart.bounds.size.width
        {
            offset.x = chart.bounds.size.width - origin.x - width - padding
        }
        
        if origin.y + offset.y < 0
        {
            offset.y = height + padding;
        }
        else if let chart = chartView,
            origin.y + height + offset.y > chart.bounds.size.height
        {
            offset.y = chart.bounds.size.height - origin.y - height - padding
        }
        offset.y = offset.y - 5
        return offset
    }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        if size == CGSize.zero{
            return
        }
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        context.saveGState()
        
        context.setFillColor(color.cgColor)

        if offset.y > 0
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + arrowSize.height))
            
            context.fillPath()
            
        }
        else
        {
            context.beginPath()
            context.move(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + rect.size.width,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            //arrow vertex
            context.addLine(to: CGPoint(
                x: point.x,
                y: point.y))
            context.addLine(to: CGPoint(
                x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y + rect.size.height - arrowSize.height))
            context.addLine(to: CGPoint(
                x: rect.origin.x,
                y: rect.origin.y))
            context.fillPath()
            
        }

        if offset.y > 0 {
            rect.origin.y += self.insets.top + arrowSize.height
        } else {
            rect.origin.y += self.insets.top
        }

        // Size of rounded rectangle
        let rectWidth = rect.width
        let rectHeight = rect.height
        
        
        
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
//        let clipPath: CGPath = UIBezierPath(roundedRect: rect, cornerRadius: 5).cgPath
//
//        ctx.addPath(clipPath)
        
//        let path = UIBezierPath(roundedRect: rect,
//                                byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
//                                cornerRadii: CGSize(width: 5, height: 5)).cgPath
//
//        ctx.addPath(path)
        
        ctx.closePath()
        ctx.fillPath()
        ctx.restoreGState()
        
        
        rect.size.height -= self.insets.top + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        
        
        switch balloonMarkerData.numberPrecision {
        case 0:
            setLabel(String.init(format: "%.0f", round(entry.y)), data: entry.data)
            break
        case 1:
            setLabel(String.init(format: "%.1f", entry.y), data: entry.data)
            break
        case 2:
            setLabel(String.init(format: "%.2f", entry.y), data: entry.data)
            break
            
        default:
            break
        }
//        setLabel(String.init(format: "%.2f", entry.y), data: entry.data)
    }
    
    open func setLabel(_ newLabel: String, data: Any?)
    {
        let actualData = data as? LineChartModel
        
        if balloonMarkerData.unitString == BQM3Format{
            label = String.init(format: "%@ %@ \n %@", newLabel, "Bq/m\u{00B3}" , self.formatDateString(date: actualData?.date ?? Date()))
        }
        else{
            label = String.init(format: "%@ %@ \n %@", newLabel, balloonMarkerData.unitString , self.formatDateString(date: actualData?.date ?? Date()))
        }
        
        if actualData?.dummyValue == -12345 || actualData?.dummyValue == -123456{
            label = ""
        }
        
        
        
        _drawAttributes.removeAll()
        _drawAttributes[.font] = self.font
        _drawAttributes[.paragraphStyle] = _paragraphStyle
        _drawAttributes[.foregroundColor] = self.textColor
        
        _labelSize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        
        var size = CGSize()
        size.width = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        self.size = size
        if actualData?.dummyValue == -12345 || actualData?.dummyValue == -123456{
            self.size = CGSize.init(width: 0, height: 0)
        }
    }
    
    
    func formatDateString(date: Date)-> String{
        
        let utc = TimeZone(identifier: "UTC")
                
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = utc ?? TimeZone.init(secondsFromGMT: 0)!
        dateFormatter.dateFormat = balloonMarkerData.dateFormat
        if ChartFilterType == .Month{
            return dateFormatter.string(from: date)
        }
        else{
            return dateFormatter.string(from: Helper.shared.addDeviceTimeAndReturnUpdatedDate(date: date, deviceId: GlobalDeviceID))
        }
        
    }
}

extension Character {
    var unicode: String {
        // See table here: https://en.wikipedia.org/wiki/Unicode_subscripts_and_superscripts
        let unicodeChars = [Character("0"):"\u{2070}",
                            Character("1"):"\u{00B9}",
                            Character("2"):"\u{00B2}",
                            Character("3"):"\u{00B3}",
                            Character("4"):"\u{2074}",
                            Character("5"):"\u{2075}",
                            Character("6"):"\u{2076}",
                            Character("7"):"\u{2077}",
                            Character("8"):"\u{2078}",
                            Character("9"):"\u{2079}",
                            Character("i"):"\u{2071}",
                            Character("+"):"\u{207A}",
                            Character("-"):"\u{207B}",
                            Character("="):"\u{207C}",
                            Character("("):"\u{207D}",
                            Character(")"):"\u{207E}",
                            Character("n"):"\u{207F}"]
        
        if let unicode = unicodeChars[self] {
            return unicode
        }
        
        return String(self)
    }
}
