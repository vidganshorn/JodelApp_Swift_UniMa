//
//  YourChatMessageCell.swift
//  JodelChat
//
//  Created by David Ganshorn on 3/23/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import UIKit

class yourChatMessageCell: BaseCell {
    
    @IBOutlet weak var yourMessage: UITextView!
    
    let cellGreenColor = UIColor(hexString: "#35D58Bff")
    let cellLightGreenColor = UIColor(hexString: "#CBF5E2ff")
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func drawRect(rect: CGRect) {

        var bubbleSpace = CGRectMake(8, self.bounds.origin.y + 5, self.yourMessage.bounds.width, self.bounds.height - 10)
            
        let bubblePath1 = UIBezierPath(roundedRect: bubbleSpace, byRoundingCorners: [UIRectCorner.TopLeft , UIRectCorner.TopRight, UIRectCorner.BottomLeft], cornerRadii: CGSizeMake(20.0, 20.0))
            
        let bubblePath = UIBezierPath(roundedRect: bubbleSpace, cornerRadius: 20.0)
            bubblePath.lineWidth = 3.0
            
        cellGreenColor!.setStroke()
        cellLightGreenColor!.setFill()
            
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