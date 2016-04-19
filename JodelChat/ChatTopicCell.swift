//
//  ChatCell.swift
//  JodelChat
//
//  Created by David Ganshorn on 3/22/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation
import UIKit

class ChatTopicCell: UITableViewCell {

    // @IBOutlet weak var message: UILabel!
    // @IBOutlet weak var message: UITextView!
    @IBOutlet weak var message: UITextView!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var likes: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}