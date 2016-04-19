//
//  ChatMessageCell.swift
//  JodelChat
//
//  Created by David Ganshorn on 3/22/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import UIKit

class myChatMessageCell: BaseCell {
    
    @IBOutlet weak var myMessage: UITextView!
    
    let cellBlueColor = UIColor(hexString: "#45A7E0ff")
    let cellLightBlueColor = UIColor(hexString: "#D0EAF8ff")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func drawRect(rect: CGRect) {

        var bubbleSpace = CGRectMake(58.0, self.bounds.origin.y + 5, self.myMessage.bounds.width, self.bounds.height - 10)
        
        let bubblePath1 = UIBezierPath(roundedRect: bubbleSpace, byRoundingCorners: [UIRectCorner.TopLeft , UIRectCorner.TopRight, UIRectCorner.BottomLeft], cornerRadii: CGSizeMake(20.0, 20.0))
        
        let bubblePath = UIBezierPath(roundedRect: bubbleSpace, cornerRadius: 20.0)
            bubblePath.lineWidth = 3.0
        
        // UIColor.blueColor().setStroke()
        // UIColor.whiteColor().setFill()
        
        cellLightBlueColor?.setFill()
        cellBlueColor!.setStroke()
        
        bubblePath.stroke()
        bubblePath.fill()

    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        var backgroundImage = UIImageView(image: UIImage(named: "star"))
        //        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFit
        //        self.backgroundView = backgroundImage
    }
}

/*
 *  Define color for cells
 */

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.startIndex.advancedBy(1)
            let hexColor = hexString.substringFromIndex(start)
            
            if hexColor.characters.count == 8 {
                let scanner = NSScanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexLongLong(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}

