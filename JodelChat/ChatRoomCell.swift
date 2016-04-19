//
//  chatRoomCell.swift
//  JodelChat
//
//  Created by David Ganshorn on 4/18/16.
//  Copyright © 2016 David Ganshorn. All rights reserved.
//

import Foundation

class ChatRoomCell: UITableViewCell {
    
    @IBOutlet weak var jodelTextView: UITextView!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var uploadedImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}